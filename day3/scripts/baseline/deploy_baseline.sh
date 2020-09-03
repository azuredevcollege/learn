#!/usr/bin/env bash

# Deploy common stuff...

if [ -z $BASE_REGION_NAME ]; then
    echo "Region env name (BASE_REGION_NAME) is empty."
    exit 0
else
    echo "Region env name is: $BASE_REGION_NAME"
fi

if [ -z $BASE_RG_COMMON_NAME ]; then
    echo "Resource Group COMMON env name (BASE_RG_COMMON_NAME) is empty."
    exit 0
else
    echo "Resource Group COMMON env name is: $BASE_RG_COMMON_NAME"
fi

if [ -z $BASE_AI_NAME ]; then
    echo "AppInsights env name (BASE_AI_NAME) is empty."
    exit 0
else
    echo "AppInsights env name is: $BASE_AI_NAME"
fi

if [ -z $BASE_STORAGEACCOUNT_FE_NAME ]; then
    echo "Storage Account Frontend env name (BASE_STORAGEACCOUNT_FE_NAME) is empty."
    exit 0
else
    echo "Storage Account Frontend env name is: $BASE_STORAGEACCOUNT_FE_NAME"
fi

if [ -z $BASE_STORAGEACCOUNT_RES_NAME ]; then
    echo "Storage Account Resources env name (BASE_STORAGEACCOUNT_RES_NAME) is empty."
    exit 0
else
    echo "Storage Account Resources env name is: $BASE_STORAGEACCOUNT_RES_NAME"
fi

if [ -z $BASE_API_WEBAPP_NAME ]; then
    echo "WebApp API env name (BASE_API_WEBAPP_NAME) is empty."
    exit 0
else
    echo "WebApp API env name is: $BASE_API_WEBAPP_NAME"
fi

if [ -z $BASE_RES_WEBAPP_NAME ]; then
    echo "WebApp RES env name (BASE_RES_WEBAPP_NAME) is empty."
    exit 0
else
    echo "WebApp RES env name is: $BASE_RES_WEBAPP_NAME"
fi

if [ -z $BASE_RES_FUNCAPP_NAME ]; then
    echo "FuncApp RES env name (BASE_RES_FUNCAPP_NAME) is empty."
    exit 0
else
    echo "FuncApp RES env name is: $BASE_RES_FUNCAPP_NAME"
fi

rgCommon=( `az group exists -n $BASE_RG_COMMON_NAME` )

if [ "$rgCommon" = "false" ]; then
    echo "Creating COMMON resource group."
    az group create -l $BASE_REGION_NAME -n $BASE_RG_COMMON_NAME
else
    echo "Resource group COMMON exists."
fi

echo "Deploying Common Resources."

az deployment group create -g $BASE_RG_COMMON_NAME --template-file ../../../day2/apps/infrastructure/templates/scm-common.json --parameters applicationInsightsName=$BASE_AI_NAME

echo "Deploying SCM API Resources."

az deployment group create -g $BASE_RG_COMMON_NAME --template-file ../../../day2/apps/infrastructure/templates/scm-api-dotnetcore.json --parameters applicationInsightsName=$BASE_AI_NAME sku=S1 use32bitworker=true alwaysOn=true webAppName=$BASE_API_WEBAPP_NAME

echo "Building and publishing SCM API Resources."

dotnet publish ../../../day2/apps/dotnetcore/Scm/Adc.Scm.Api/Adc.Scm.Api.csproj --configuration=Release -o ./publishContacts /property:GenerateFullPaths=true /property:PublishProfile=Release
cd publishContacts && zip -r package.zip . && az webapp deployment source config-zip --resource-group $BASE_RG_COMMON_NAME --name $BASE_API_WEBAPP_NAME --src ./package.zip && cd ..

echo "Deploying SCM Res Resources."

az deployment group create -g $BASE_RG_COMMON_NAME --template-file ../../../day2/apps/infrastructure/templates/scm-resources-api-dotnetcore.json --parameters applicationInsightsName=$BASE_AI_NAME sku=S1 use32bitworker=true alwaysOn=true webAppName=$BASE_RES_WEBAPP_NAME storageAccountName=$BASE_STORAGEACCOUNT_RES_NAME functionAppName=$BASE_RES_FUNCAPP_NAME

echo "Building and publishing SCM Res Resources."

dotnet publish ../../../day2/apps/dotnetcore/Scm.Resources/Adc.Scm.Resources.Api/Adc.Scm.Resources.Api.csproj --configuration=Release -o ./publishRes /property:GenerateFullPaths=true /property:PublishProfile=Release
cd publishRes && zip -r package.zip . && az webapp deployment source config-zip --resource-group $BASE_RG_COMMON_NAME --name $BASE_RES_WEBAPP_NAME --src ./package.zip && cd ..

dotnet publish ../../../day2/apps/dotnetcore/Scm.Resources/Adc.Scm.Resources.ImageResizer/Adc.Scm.Resources.ImageResizer.csproj --configuration=Release -o ./publishFunc /property:GenerateFullPaths=true /property:PublishProfile=Release
cd publishFunc && zip -r package.zip . && az webapp deployment source config-zip --resource-group $BASE_RG_COMMON_NAME --name $BASE_RES_FUNCAPP_NAME --src ./package.zip && cd ..

echo "Deploying SCM Frontend Resources."

az deployment group create -g $BASE_RG_COMMON_NAME --template-file ../../../day2/apps/infrastructure/templates/scm-fe.json --parameters storageAccountName=$BASE_STORAGEACCOUNT_FE_NAME

echo "Activating Static Web site option in storage account."

az storage blob service-properties update --account-name $BASE_STORAGEACCOUNT_FE_NAME --static-website  --index-document index.html --404-document index.html

aiKey=( `az resource show -g $BASE_RG_COMMON_NAME -n $BASE_AI_NAME --resource-type "microsoft.insights/components" --query "properties.InstrumentationKey" -o tsv` )

echo "Building frontend..."
cd ../../../day2/apps/frontend/scmfe && npm install && npm run build && cd ../../../../day3/scripts/baseline

echo "var uisettings = { \"endpoint\": \"https://$BASE_API_WEBAPP_NAME.azurewebsites.net\", \"resourcesEndpoint\": \"https://$BASE_RES_WEBAPP_NAME.azurewebsites.net\", \"aiKey\": \"$aiKey\" };" > ../../../day2/apps/frontend/scmfe/dist/settings/settings.js
az storage blob upload-batch -d '$web' --account-name $BASE_STORAGEACCOUNT_FE_NAME -s ../../../day2/apps/frontend/scmfe/dist
