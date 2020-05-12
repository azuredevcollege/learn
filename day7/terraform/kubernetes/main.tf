provider "azurerm" {
  version = "~> 2.6.0"
  features {}
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}k8s${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "${var.prefix}k8s${var.env}"
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = "1.16.7"

  tags = {
    environment = "${var.env}"
  }
}

provider "kubernetes" {
  load_config_file       = "false"
  host                   = "${azurerm_kubernetes_cluster.k8s.fqdn}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_namespace" "appns" {
  metadata {
    name = "${var.env}"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "azurerm_public_ip" "ingress_ip" {
  name                = "${var.prefix}ingressip${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_kubernetes_cluster.k8s.node_resource_group}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "local_file" "kubeconfig" {
  sensitive_content = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
  filename          = "./kubecfg"
}


provider "helm" {
  kubernetes {
    config_path = "${local_file.kubeconfig.filename}"
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "ingress" {
  name      = "clstr-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "${kubernetes_namespace.ingress.metadata[0].name}"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.ingress_ip.ip_address}"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = "${azurerm_kubernetes_cluster.k8s.node_resource_group}"
  }
}

resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "jetstack/cert-manager"
  namespace = "${kubernetes_namespace.cert_manager.metadata[0].name}"
  version   = "v0.15.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set {
    name  = "ingressShim.defaultIssuerGroup"
    value = "cert-manager.io"
  }
}

output "nip_hostname" {
  value = "${replace(azurerm_public_ip.ingress_ip.ip_address, ".", "-")}.nip.io"
}
