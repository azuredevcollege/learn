# Challenge 3: Docker Objects

## Here is what you'll learn 🎯

In this challenge, we' play with Volume and Network objects which are the most important Docker objects after Images and Containers.

In this challenge you will:

- Create Volumes
- Inspect Volumes
- Create Networks
- Check connection differences between different networks

## Table Of Contents

1. [Creating the First Volume](#creating-the-first-volume)
2. [Other Volume Options](#other-volume-options)
3. [Default Networks - Bridge](#default-networks-bridge)
4. [Default Networks - Host](#default-networks-host)
5. [Default Networks - None](#default-networks-none)
6. [User-defined Bridge Network](#user-defined-bridge-network)
7. [Port Publishing](#port-publishing)
8. [Wrap-Up](#wrap-up)

## Creating the First Volume

_Docker volumes_ are docker objects like containers and images. We create them like when we create images or containers. By default, we create them on the host where the Docker daemon is running. But we can also create them by using various volume plug-ins- These plug-ins allow us to store the data, for example on a nfs drive or on the cloud.

After the volume is created, we can mount the volume to any folder inside the container. After that, any file written to the folder will be _physically stored_ in the mounted volume. Any file in the container is deleted and lost, when container is deleted. Using volumes we can keep files longer than i.e. independent from the container's lifetime.

Let's create our first volume and see that in action. First let's check if there is any volume has been created on the host before.

Type:

```shell
docker volume ls
```

The output will be something like:

```shell
DRIVER              VOLUME NAME
 ```

We don't have any volume at the moment. Let's create the first one. For that, we use the ```docker volume create``` command without any option. If we want to use a specific volume driver, we must use the ```-d``` option. We want to create a local volume so we don't have to specify a driver.

Type:

```shell
docker volume create first_volume
```

The output will be something like:

```shell
first_volume
 ```

We've just created our first volume. Now it's time to inspect it and look into the details.

Type:

```shell
docker volume inspect first_volume
```

The output will be something like:

```shell
[
    {
        "CreatedAt": "2020-06-04T13:33:47Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/first_volume/_data",
        "Name": "first_volume",
        "Options": {},
        "Scope": "local"
    }
]
```

Let us pay attention to  ```"Mountpoint":``` section of this output. This is literally the path where this volume is located. Any file in this volume is stored in this path.

Docker Desktop for Windows and Docker Desktop for Mac spin up a lightweight VM and run the Docker daemon inside it. Therefore we can't access this path. If you run the Docker daemon on a Linux VM, you can cd to that path and see the files stored in it.

We have an empty volume, so we can mount it to a container. The option that we'll use is ```-v```. The syntax is ```volume-name``` ```:``` ```container-path```.

Assume we want to mount the volume called ```first_volume``` to the folder ```/test```. Our option would then be ```-v first_volume:/test```. If this folder doesn't exist in the image, the folder will be created when the container is created.

Now it's time to create a container and mount the volume. We create a new interactive container from the ubuntu image and connect to its bash shell. The ```first_volume``` will be mounted to the container's ```/test``` folder. After it's created, we'll switch to the ```/test``` directory, create a file called ```test.txt``` and exit.

::: tip
📝 We will use another useful option too, which is ```--rm```. If you create a Docker container with ```--rm```, container will be automatically deleted when it's exited. Therefore you don't need to manually clean later. Please use with caution.)
:::

Type:

```shell
docker container run -it --rm -v first_volume:/test ubuntu bash
```

The output will be something like:

```shell
root@666540d6384b:/#
```

Now we're connected to the container. Let's jump to the /test folder and create a file in it.

```shell
root@666540d6384b:/# cd test
root@666540d6384b:/test# echo "this is a test line" > test.txt
root@666540d6384b:/test# ls
test.txt
root@666540d6384b:/test# exit
exit
```

When we exited, the container stopped working. We created the container with ```--rm``` therefore the container is deleted. You can check this by typing ```docker ps -a```. There shouldn't be any running or stopped container.

The ```first_volume``` has been mounted to this container's ```/test``` folder. Therefore anything was written to that folder actually was written to the volume. The container was deleted but the volume remains including our data.

Let's create another container and check that. This time we create another container from the alpine image. We will see that it doesn't matter which image we use.

Type:

```shell
docker container run -it --rm -v first_volume:/test2 alpine sh
```

The output will be something like:

```shell
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
df20fa9351a1: Pull complete
Digest: sha256:185518070891758909c9f839cf4ca393ee977ac378609f700f60a771a2dfe321
Status: Downloaded newer image for alpine:latest
/ #
```

We're connected to the container. Let's jump to the ```/test2``` folder and check if the file is there.  

```shell
/ # cd /test2
/test2 # ls
test.txt
/test2 # cat test.txt
this is a test line
/test2 # exit
```

Yes! The file is there. As you can see, we kept our data longer than the container's lifetime.

::: tip
📝 Don't forget, containers are disposable and can be deleted but your data doesn't need to be.
:::

## Other Volume Options

Another use case of the volumes is that you can mount the same volume to multiple containers at the same time. Let's try that.

Type:

```shell
docker container run -it --rm --name con1 -v first_volume:/test ubuntu bash
```

The output will be something like:

```shell
root@70fd46786a11:/#
```

We've created a new container and connected to its bash shell. The ```first_volume``` is mounted to the ```/test``` folder. While it is running let's open a second terminal window, create another container and mount the same volume too.

Type:

```shell
docker container run -it --rm --name con2 -v first_volume:/test2 ubuntu bash
```

The output will be something like:

```shell
root@7c697541e9ed:/#
```

Now we have two containers: ```con1``` and ```con2```. ```first_volume``` is mounted to ```con1```'s ```/test``` folder and also it's mounted to ```con2```'s ```/test2``` folder.

Let's create a file in the ```/test2``` folder of ```con2```.

```shell
root@7c697541e9ed:/# cd /test2
root@7c697541e9ed:/test2# touch from-con2.txt
root@7c697541e9ed:/test2# ls
from-con2.txt  test.txt
root@7c697541e9ed:/test2#
```

After that switch back to first terminal window. It's connected to ```con1```'s bash shell. Jump to the ```/test``` folder and see that the file is visible there too.

```shell
root@70fd46786a11:/# cd /test
root@70fd46786a11:/test# ls
from-con2.txt  test.txt
root@70fd46786a11:/test#
```

This time, we'll create another container and mount ```first_volume``` to the ```/test3``` folder but this time the volume will be mounted_read only_. For that, we use the ```:ro``` option.

Open another terminal window and type:

```shell
docker container run -it --rm --name con3 -v first_volume:/test3:ro ubuntu bash
```

The output will be something like:

```shell
root@0f00f388b5e8:/#
```

cd to ```/test3``` and try to create or delete any file. You will get an error message because the volume is mounted as read-only.

```shell
root@0f00f388b5e8:/# cd /test3
root@0f00f388b5e8:/test3# ls
from-con2.txt  test.txt
root@0f00f388b5e8:/test3# rm test.txt
rm: cannot remove 'test.txt': Read-only file system
root@0f00f388b5e8:/test3# touch newfile.txt
touch: cannot touch 'newfile.txt': Read-only file system
root@0f00f388b5e8:/test3#
```

Type ```exit``` in all three terminals. This will close the containers and they'll be automatically deleted. But the volume will not be deleted. Therefore we will keep the files that we need.

As we're done with our exercise we can delete the volume too. Type:

```shell
docker volume rm first_volume
```

The output will be something like:

```shell
first_volume
```

## Default Networks - Bridge

Let's get started with _networks_. First we list the current network objects.

Type:

```shell
docker network ls
```

The output will be something like:

```shell
NETWORK ID          NAME                DRIVER              SCOPE
0a63e660c39f        bridge              bridge              local
a4c8780d68f4        host                host                local
3f2520a5781c        none                null                local
```

When the Docker engine is installed, a _default bridge network_ (also called _bridge_) is created automatically and newly-started containers connect to it unless otherwise specified. In addition, two other networks are created which are called _host_ and _none_.

All containers without a ```--network``` option specified are attached to the default bridge network. Containers on the default bridge network can access each other by their IP addresses. You can also create user-defined custom bridge networks. But we'll come to that later. For now, let's inspect the default bridge network.

Type:

```shell
docker network inspect bridge
```

The output will be something like:

```shell
[
    {
        "Name": "bridge",
        "Id": "0a63e660c39f21b42b1c7722edf80667036af813820a743e900b65cf4d245314",
        "Created": "2020-07-29T18:01:01.192938Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

The "Subnet" is "172.17.0.0/16" and The "Gateway" is "172.17.0.1". This means that all containers without a ```--network``` specified will be attached to this bridge network and get an IP address from that subnet. Also each container that is connected to this network can communicate with each other.

It's time to try that. First we create two containers with ```-d``` and ```-it``` options, in short ```-dit```. This allows us to create a container interactive and connected (```-it```) but also detached (```-d```). The connection will be opened to this container but we'll get our terminal back. In this way, we can continue to work.

Type:

```shell
docker container run -dit --rm --name con1 ubuntu bash
```

The output will be something like:

```shell
bb1dcc608811c3d7d5dd63f09fc23424bb188c2053df618861887321c8043cee
```

Type:

```shell
docker container run -dit --rm --name con2 ubuntu bash
```

The output will be something like:

```shell
f89a73c7d38d6bad0d14b68cc629e8e4fd2f32e8f274ce20cbbb8f116efe5887
```

 In the mean time we will learn another docker command which is ```docker attach```. This command allows us to attach our terminal’s standard input, output, and error (or any combination of the three) to a running container using the container’s ID or name. This allows us to see its ongoing output or control it interactively, as though the commands were running directly in your terminal.

 This is how we will attach to running connection on these containers. But before that let's inspect the bridge network object one more time.

 Type:

```shell
docker network inspect bridge
```

The output will be something like:

```shell
[
    {
        "Name": "bridge",
        "Id": "0a63e660c39f21b42b1c7722edf80667036af813820a743e900b65cf4d245314",
        "Created": "2020-07-29T18:01:01.192938Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "bb1dcc608811c3d7d5dd63f09fc23424bb188c2053df618861887321c8043cee": {
                "Name": "con1",
                "EndpointID": "76ca82059a18dad551283a9a8804791bea97138065d1ec8f104381a9d79a6454",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "f89a73c7d38d6bad0d14b68cc629e8e4fd2f32e8f274ce20cbbb8f116efe5887": {
                "Name": "con2",
                "EndpointID": "844f3d3c8f07e29170c8742ed59ea47b0bb01bb80c25e36122eaa981a2c1322e",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

This time, the container section of the output is not empty. We have created two containers that are running. We didn't use ```--network``` when we created them so both are connected to default bridge network.

You can see their names, IDs and IP addresses above. Let's attach to ```con1``` and check the network details.

 Type:

```shell
docker attach con1
```

The output will be something like:

```shell
root@bb1dcc608811:/#
```

We are in ```con1```. First we check the network details by typing ```ifconfig```.

When you do that, you will get an error ```bash: ifconfig: command not found```. Another important thing you have to know about container images is that most of them are minimal builds and don't have even the most basic tools like ifconfig and ping. We need to install them first.

 Type:

```shell
root@bb1dcc608811:/# apt update -y && apt install -y net-tools iputils-ping
```

The output will be something like:

```shell
root@bb1dcc608811:/#
```

We've installed ifconfig and ping utilities. Now we can check the container's IP address.

Type:

```shell
root@bb1dcc608811:/# ifconfig
```

The output will be something like:

```shell
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.2  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:ac:11:00:02  txqueuelen 0  (Ethernet)
        RX packets 10482  bytes 15220468 (15.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4994  bytes 274694 (274.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

As you can see, ```con1``` got the IP address "172.17.0.2".

Let's try to ping ```con2```. Its IP address is "172.17.0.3".

Type:

```shell
root@bb1dcc608811:/# ping -c 4 172.17.0.3
```

The output will be something like:

```shell
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=4.85 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.105 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.090 ms
64 bytes from 172.17.0.3: icmp_seq=4 ttl=64 time=0.156 ms

--- 172.17.0.3 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3086ms
rtt min/avg/max/mdev = 0.090/1.299/4.848/2.048 ms
```

It seems that the connection between ```con1``` and ```con2``` is possible because they're connected to same default bridge network. They can communicate directly without exposing their ports. They're on the same network and there isn't any rule that blocks this communication.

Let us find out if they can resolve each other's name via a DNS mechanism running behind the scenes. First we try to ping www.bing.com and see if container can solve public domain names.

Type:

```shell
root@bb1dcc608811:/# ping -c 2 www.bing.com
```

The output will be something like:

```shell
PING dual-a-0001.a-msedge.net (13.107.21.200) 56(84) bytes of data.
64 bytes from 13.107.21.200 (13.107.21.200): icmp_seq=1 ttl=37 time=11.4 ms
64 bytes from 13.107.21.200 (13.107.21.200): icmp_seq=2 ttl=37 time=15.1 ms

--- dual-a-0001.a-msedge.net ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 11.420/13.259/15.099/1.839 ms
```

It is working. Now let's try to ping ```con2```.

Type:

```shell
root@bb1dcc608811:/# ping -c 2 con2
```

The output will be something like:

```shell
ping: con2: Name or service not known
```

Containers on the default bridge network can only access each other by their IP addresses. Unless you use the ```--link``` option, which is considered legacy.

On a _user-defined bridge_ network, containers can resolve each other by name or alias. That's the main benefit of user defined bridge networks. In addition using a user-defined network provides a scoped network in which only containers attached to that network are able to communicate. We'll come to that later.

You can detach from a container and leave it running using the **CTRL-p** **CTRL-q** key sequence. Let's type that and detach from the container.

You can connect to and disconnect from networks any time you wish. Let's try this and disconnect ```con1``` from the bridge network.

Type:

```shell
docker network disconnect bridge con1
```

Now the ```con1``` is disconnected from bridge network. Attach again to the container's shell and check that it's disconnected.

Type:

```shell
docker attach con1
```

The output will be something like:

```shell
root@bb1dcc608811:/# ifconfig
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

As you can see, only the loopback adapter remains. Let's type **CTRL-p** **CTRL-q** and detach from the container again.

Delete the containers by typing ```docker container rm -f con1 con2```

## Default Networks - Host

Another network that has been created when Docker starts is the _host_ network. If you attach a container to the "host" network, that container’s network stack is not isolated from Docker host's network stack (the container shares the host’s networking namespace), and the container does not get its own IP-address allocated.

Let's create another container and connect that to the host network.

Type:

```shell
docker container run --rm --network host --name con3 -it ubuntu bash
```

The output will be something like:

```shell
root@docker-desktop:/#
```

Again we install ifconfig and ping by typing ```apt update -y && apt install -y net-tools iputils-ping``` . When this is done, type ```ifconfig```

Type:

```shell
root@docker-desktop:/# ifconfig
```

The output will be something like:

```shell
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:b5ff:fe4d:9a9  prefixlen 64  scopeid 0x20<link>
        ether 02:42:b5:4d:09:a9  txqueuelen 0  (Ethernet)
        RX packets 12681  bytes 525430 (525.4 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 27654  bytes 39770860 (39.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.65.3  netmask 255.255.255.240  broadcast 192.168.65.15
        inet6 fe80::50:ff:fe00:1  prefixlen 64  scopeid 0x20<link>
        ether 02:50:00:00:00:01  txqueuelen 1000  (Ethernet)
        RX packets 229369  bytes 337542126 (337.5 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 65774  bytes 3733334 (3.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1251  bytes 75612 (75.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1251  bytes 75612 (75.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

veth9f4c8b5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::40f7:4eff:feb1:3cc1  prefixlen 64  scopeid 0x20<link>
        ether 42:f7:4e:b1:3c:c1  txqueuelen 0  (Ethernet)
        RX packets 5290  bytes 291759 (291.7 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 10508  bytes 15222922 (15.2 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Next check the eth0 adapter. It's exactly the same adapter that the host has. So there isn't any network isolation. The container is running like a process on the host and uses the network infrastructure of the host without any bridge or something like that in between.

Type exit and close the connection. The container will be automatically deleted.

## Default Networks - None

If you want to disable the networking stack completely on a container, you can use the ```--network none``` flag. Within the container, only the loopback device will be created. Let's try that.

Type:

```shell
docker container run --rm -it --network none alpine ash
```

The output will be something like:

```shell
/ #
```

Type:

```shell
/ # ip link show
```

The output will be something like:

```shell
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
```

As you can see, there isn't any eth device that has created. This container can't communicate with any endpoint. Type exit, the container will be automatically deleted.

## User-Defined Bridge Network

All containers without a ```--network``` specified are connected to the default bridge network. This can be a risk, as unrelated stacks/services/containers are then able to communicate. Using a user-defined network provides a scoped network in which only containers attached to that network are able to communicate.

If your containers use the default bridge network, you can configure it, but all the containers use the same settings, such as MTU and iptables rules. In addition, configuring the default bridge network happens outside of Docker itself, and requires a restart of Docker. User-defined bridge networks are created by using ```docker network create``` command. If different group of applications have different network requirements, you can configure each user-defined bridge network separately while creating them.

Containers connected to the same user-defined bridge network effectively expose all ports to each other. For a port to be accessible to containers or non-Docker hosts on different networks, that port must be published using the -p or --publish flag which we will come later. For now let's create our first user-defined bridge network.

Type:

```shell
docker network create first_network
```

The output will be something like:

```shell
6bb87b6c22ea7dceee3cf87367aee2bd9045c1f255d98c4c01cac00ab6478d13
```

It has been created. Now it's time to check and see its details.

Type:

```shell
docker network ls
```

The output will be something like:

```shell
NETWORK ID          NAME                DRIVER              SCOPE
0a63e660c39f        bridge              bridge              local
6bb87b6c22ea        first_network       bridge              local
a4c8780d68f4        host                host                local
3f2520a5781c        none                null                local
```

Type:

```shell
docker network inspect first_network
```

The output will be something like:

```shell
[
    {
        "Name": "first_network",
        "Id": "6bb87b6c22ea7dceee3cf87367aee2bd9045c1f255d98c4c01cac00ab6478d13",
        "Created": "2020-08-05T12:12:44.2681958Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

Notice the ```Gateway``` and ```Subnet``` section of this output. We've created a user-defined bridge network and did not specify any subnet option. That is why it got the next IP block after default bridge network. So subnet is "172.18.0.0/16".

If we create another one, it will get "172.19.0.0/16" and this goes like that. Let's create two containers and connect them to this newly created network.

Type:

```shell
docker container run -dit --rm --name web --network first_network busybox sh
```

The output will be something like:

```shell
ad1a7086a97b8ea6acbf203a7df2b17c1d276ffb46464a79b439208a527380e7
```

Type:

```shell
docker container run -dit --rm --name database --network first_network busybox sh
```

The output will be something like:

```shell
2e93b1d08ac6f35043e417e3e15116ca7100f85020d59b24107805580417ef3b
```

Two containers have been created and connected to the ```first_network```. The user-defined bridge networks allow containers to resolve each other's name. We do that now.

Type:

```shell
docker attach web
```

The output will be something like:

```shell
/ #
```

We're connected to the "web" container. Let's try to ping the "database" container by its name.

Type:

```shell
ping -c 4 database
```

The output will be something like:

```shell
PING database (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.104 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.117 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.158 ms
64 bytes from 172.18.0.3: seq=3 ttl=64 time=0.069 ms

--- database ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.069/0.112/0.158 ms
```

As you can see, containers that are connected to the same user-defined bridge network can communicate with each other and resolve each other's name. Let us create another container on the default bridge network and try to access this container.

Open a second terminal window and type:

```shell
docker container run -it --rm --name test busybox sh
```

The output will be something like:

```shell
/ #
```

The "test" container has been created and you're connected to its shell. Try to ping the "database" container by its name and IP address.

```shell
/ # ping database
ping: bad address 'database'
/ # ping -c 4 172.18.0.3
PING 172.18.0.3 (172.18.0.3): 56 data bytes

--- 172.18.0.3 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
/ #
```

You shouldn't be able to neither resolve its name nor access the container by its IP address. Containers that are running on different networks can't communicate with each other without exposed ports. Only the containers that are running on the same network can communicate with each other and if they are running on the same user-defined bridge network, they can resolve each other's name too.

Close this connection by typing exit and delete the other containers by typing ```docker container rm -f web database```

As the last part of this exercise, let's create a second bridge network. This time we will specify the subnet and IP ranges.

Type:

```shell
docker network create --driver=bridge --subnet=10.10.0.0/16 --ip-range=10.10.10.0/24 --gateway=10.10.10.10 second_network 
```

The output will be something like:

```shell
34d051989f2a578ba704d5b8019db59fd195a6ba96d53bfd6ceaa7195a854f5b
```

Type:

```shell
docker network ls
```

The output will be something like:

```shell
NETWORK ID          NAME                DRIVER              SCOPE
0a63e660c39f        bridge              bridge              local
6bb87b6c22ea        first_network       bridge              local
a4c8780d68f4        host                host                local
3f2520a5781c        none                null                local
34d051989f2a        second_network      bridge              local
```

## Port Publishing

By default, when you create a container, it does not publish any of its ports to outside world. To make a port available to clients outside the Docker, or to Docker containers which are not connected to the same network, we use the ```--publish``` or ```-p``` flags.

This creates a firewall rule which maps a container port to a port on the Docker host. Any package that reaches to that port on the host will be forwarded to the port that listens on the container. So you can access to services inside the container from outside.

Also containers which are not connected to the container’s network can reach this container via that published port. Let's try this. We're gonna create two containers connected to two different networks. The first one will be "web" and will be published TCP Port 80. The other one is just a busybox container that we'll connect to "web" container.

Type:

```shell
docker container run -d --name webserver --network first_network -p 5000:80 nginx
```

The output will be something like:

```shell
d20a67de0c86993f07dbc0774a883e5d6414693b5fdd9f2b183426bf4a5835c3
```

If you open a browser on your computer and visit ```127.0.0.1:5000```, you will reach to the web daemon which is running inside the container. Somehow, we mapped the host's TCP 5000 to the container's TCP 80.

![Nginx2](./images/nginx2.png)

Now, let's create a second container, connect that to the ```second_network``` and try to reach webserver.

First let's get the webserver's IP address. Type ```docker container inspect webserver``` and check the IP address section. In my case it's ```"IPAddress": "172.18.0.4"```. Now we are ready to create the second container.

Type:

```shell
docker container run --rm -it --name test_container --network second_network centos sh
```

The output will be something like:

```shell
sh-4.4#
```

Let's try to reach webserver. We use curl and try to access 172.18.0.4:80.

Type:

```shell
sh-4.4# curl 172.18.0.4:80
```

The output will be something like:

```shell
curl: (7) Failed to connect to 172.18.0.4 port 80: Connection timed out
```

We got a "connection time-out" message, because we were trying to reach a container which is connected to another network. Remember that, containers that are running on different networks can't communicate with each other.

Instead of that, if we try to reach 172.18.0.1 "which is the gateway of the first_network" on port 5000 we can reach to the container, because, we have exposed that port.

Type:

```shell
sh-4.4# curl 172.18.0.1:5000
```

The output will be something like:

```shell
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Type ```exit``` and the container will be automatically deleted.

::: tip
📝 You can expose UDP ports via ```-p 8080:80/udp```
:::

Let's delete the containers and networks that we've created so far.

Type:

```shell
docker container rm -f webserver database
```

Type:

```shell
docker network rm first_network second_network
```

## Wrap-up

🎉 **_Congratulations_** 🎉

You have completed the Docker Objects challenge and learned how to create and manage Docker Volume and Network objects.

:::details
🔍 Reference: <https://docs.docker.com>
:::

[◀ Previous challenge](./challenge2.md) | [🔼 Day 6](../README.md) | [Next challenge ▶](./challenge4.md)
