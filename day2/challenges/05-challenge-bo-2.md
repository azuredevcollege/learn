# 💎 Breakout 2: Add a serverless microservice to our sample app and include messaging 💎

⏲️ _Est. time to complete: 45 min._ ⏲️

## Here is what you will learn 🎯

Time for our second "Break-Out" session!

We now will deploy _all required services_ of our SCM Contacts Management app to Azure, including the _Vue.js Single Page Application_. To host the SPA, which is basically a static website, we make use of the [Static Website Hosting](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal) option of Azure Storage Accounts. This is the cheapest option to host applications built e.g. with Angular, React or like in our case Vue.JS.

We also add a second service, that allows us to save images for our contacts. The service will be implemented in .NET Core and will use _Azure Storage Queues_ (to make you familiar with a messaging service option in Azure) to notify an Azure Function that in turn creates thumbnails of the images. The results will then be saved in an Azure Storage Account.

At the end of the day, this will be the architecture of our SCM Contacts Management application:

![architecture_day2](../images/architecture_day2.png 'architecture_day2')

## Table Of Contents

1. [Services to handle Contact Images](#services-to-handle-contact-images)
2. [Deploy the Azure Function to resize images](#deploy-the-azure-function-to-resize-images)
3. [Deploy the Azure Web App providing the API to store images](#deploy-the-azure-web-app-providing-the-api-to-store-images)
4. [Host the Single Page Application in Azure](#host-the-single-page-application-in-azure)
5. [Wrap-Up](#wrap-up)

## Services to handle Contact Images

We will start implementing our target architecture by adding a Storage Account to save contact images.

### Storage Account (Container/Queue)

Therefore, create a Storage Account in the resource group you took for the first breakout session (should be `scm-breakout-rg`). Create the account having these parameters:

| Parameter                  | Value                     |
| -------------------------- | ------------------------- |
| _Name the storage account_ | <YOUR_PREFIX>scmresources |
| _Location_                 | West Europe               |
| _Performance_              | Standard                  |
| _Account Kind_             | Storage V2                |
| _Replication_              | LRS                       |
| _Access Tier_              | Hot                       |

When the Storage Account has been created, add two containers where we will be storing the images:

| Container Name | Public Access Level |
| -------------- | ------------------- |
| _rawimages_    | Blob                |
| _thumbnails_   | Blob                |

Also, add a new _Queue_ in your Storage Account. Name the queue `thumbnails`.

The infrastructure for handling images regarding storage and messaging is now set up.

### Azure Function for Image Manipulation

In the _Serverless_ challenge, we created the Azure Function via the Visual Studio Code wizard. Now, let's see how the the Portal experience is like.

Go to your resource group (`scm-breakout-rg`) and add an Azure Function. To do so search for **"Function App"** in the wizard.

Follow the wizard and when asked, enter the following information (only important information will be mentioned):

- Basic Tab
  | Parameter | Value |
  | ------------------- | ----------------------------- |
  | _Function App name_ | choose a globally unique name |
  | _Publish_ | Code |
  | _Runtime Stack_ | .NET Core |
  | _Version_ | 6 |
  | _Region:_ | West Europe |
- Hosting Tab
  | Parameter | Value |
  | ------------------ | --------------------------------------------------- |
  | _Storage Account_ | choose the one you created before in this challenge |
  | _Operating System_ | Windows |
  | _Plan Type_ | Consumption (Serverless) |
- Monitoring
  | Parameter | Value |
  | -------------------- | ----- |
  | _Enable AppInsights_ | No |

![portal_bo2_func](./images/portal_bo2_func.png 'portal_bo2_func')

When the Function has been created, we need to add a few _Configuration settings_ that our image manipulation function needs to be working correctly:

- Open the Azure Function and switch to the **Configuration** view.

- Add the following Configuration settings
  | Parameter | Value / Hints |
  | --------------------------------------------------------- | -------------------------------------------------------------------------------- |
  | _QueueName_ | thumbnails |
  | _StorageAccountConnectionString_ | take the _Connection String_ from your Storage Account (under **_Access Keys_**) |
  | _ImageProcessorOptions\_\_StorageAccountConnectionString_ | take the _Connection String_ from your Storage Account (under **_Access Keys_**) |
  | _ImageProcessorOptions\_\_ImageWidth_ | 100 |

  :::tip
  📝 You should open the portal in a second tab in your browser, because you need to switch back and forth copying values from different locations.
  :::

- Save your settings. The Functions app will now restart to apply your changes.

## Deploy the Azure Function to resize images

Now it is time to deploy the Image Resizer Function App to Azure. Therefor, you need to open a new Visual Studio Code Workspace file. Please go to the folder `day2` and run `code day2-breakout2.code-workspace` from the command line. This will open the workspace dedicated to this second breakout challenge.

You will see the following folder structure:

![Day2 Workspace Structure - Breakout 2](./images/bo2_code.png 'bo2_code')

You will see two more projects added to the workspace compared to `Breakout 1` (the remaining folders are the same as in the previous breakout):

- **Resources API** - contains the backend logic for storing images for _contacts_ objects
- **Image Resizer Function** - contains the Azure Function code to handle image resize operations

To deploy the function follow these steps:

- right-click on the `Image Resizer Function` folder and click "Deploy to Function App..."
- select the Azure Function you previously created as the deployment target and confirm the dialog

The deployment of you function starts and after a few seconds, it is running in Azure.

## Deploy the Azure Web App providing the API to store images

We need to add another Azure Web App to host the "Resources API" of our SCM Contacts application:

- Go to your resource group **scm-breakout-rg**
- Create an Azure Web App (you can choose to use the Portal or the Azure CLI: OS - **Windows**, RuntimeStack - **.NET 6 (LTS)**, Size - **S1**, AppInsights is not needed at the moment). You can choose the same settings as for the Contacts API.

When the deployment has finished, we also need to add a few settings. Open the Web App in the Portal and go to the "Configuration" view (under **Settings**):

- add the following parameters:
  | Parameter | Value / Hints |
  | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
  | _ImageStoreOptions\_\_StorageAccountConnectionString_ | take the _Connection String_ from your Storage Account created in this Break Out session (under **_Access Keys_**) |
  | _StorageQueueOptions\_\_StorageAccountConnectionString_ | take the _Connection String_ from your Storage Account created in this Break Out session (under **_Access Keys_**) |
  | _ImageStoreOptions\_\_ImageContainer_ | rawimages |
  | _StorageQueueOptions\_\_ImageContainer_ | rawimages |
  | _ImageStoreOptions\_\_ThumbnailContainer_ | thumbnails |
  | _StorageQueueOptions\_\_Queue_ | thumbnails |
  | _StorageQueueOptions\_\_ThumbnailContainer_ | thumbnails |

:::tip
Now, go back to Visual Studio Code and "right-click deploy" the API from the `Resources API` folder to the Azure Web App.
:::

Time for testing!

### Test with you local Single Page Application

When everything has been deployed to Azure:

- Open the `settings.js` file of your SPA (folder `Frontend` --> `public/settings`)
- Adjust the `resourcesEndpoint` property.
- Make sure, that `endpoint` points to the Contacts API in Azure.
- Enter the value of your newly deployed Resources API for it, e.g. [https://scmimageresource.azurewebsites.net/](https://scmimageresource.azurewebsites.net/).
- Switch to the "Debug" view and start the Single Page Application (dropdown: **Day2 - Launch Frontend**).

To test everything we just set up, create a new _Contact_ and open the details of it afterwards. On the right side box, you should now see a button called "**CHANGE AVATAR**".

![browser_avatar](./images/browser_avatar.png 'browser_avatar')

Upload a picture and **save the Contact**!.

## Host the Single Page Application in Azure

We still run the Single Page Application on our local machine. Time to switch to hosting in Azure. As mentioned before, we make use of the _"Static Website"_ feature of Azure Storage Accounts.

It's very simple to use:

- Create a new Azure Storage Account
- Go to **"Static website"** under **Settings** of your Azure Storage Account and enable it
- Choose `index.html` as _Index document name_ and _Error document path_

![portal_static_website](./images/portal_static_website.png 'portal_static_website')

:::tip
📝 When you save the settings, Azure will create a new container called **\$web** where you can copy static (web) files to. Azure will serve the contents of this containers as "Static Website". See more on the [official documentation](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal).
:::

Now open a command-line for the folder `Frontend`. Right-click on it and choose "Open in Integrated Terminal":

![vscode_integrated_terminal](./images/vscode_integrated_terminal.png 'vscode_integrated_terminal')

Alternatively open a command-line and navigate to the `day2/apps/frontend/scmfe` folder inside the previously cloned repository.

In the shell, run the following command:

```shell
$ npm run build

> scmfe@0.1.0 build /Users/yourname/dev/azure-developer-college/day2/apps/frontend/scmfe
> vue-cli-service build

   Building for production...
   ...
   ...
   ..
   .

 DONE  Build complete. The dist directory is ready to be deployed.
```

This starts a local build of the Vue.JS application, which puts all results/artifacts (the static website itself) into a `dist` folder under `Frontend`. When the build has finished, right-click on that `dist` folder and choose "Deploy to Static Website via Azure Storage" and select the correct storage account.

![vscode_deploy_staticwebsite](./images/vscode_deploy_staticwebsite.png 'vscode_deploy_staticwebsite')

When the deployment to Azure has finished, VS Code will show a popup where you can click on "Browse to website" to open your Vue.JS app running in Azure. You can also find the URL in the settings of the static website under **"Primary Endpoint"**).

## Wrap-Up

🎉 **_Congratulations_** 🎉

You have just created your first modern, multi-service Azure-backed application. You made use of:

- [Azure AppServices](https://docs.microsoft.com/azure/app-service/)
- [Storage Accounts](https://docs.microsoft.com/azure/storage/common/storage-account-overview)
- [Messaging (Azure Storage Queues)](https://docs.microsoft.com/azure/storage/queues/)
- [Serverless aka Azure Function Apps](https://docs.microsoft.com/azure/azure-functions/)
- [Static website hosting](https://docs.microsoft.com/azure/storage/blobs/storage-blob-static-website-how-to?tabs=azure-portal)

All in combination with a modern Vue.JS frontend that is also working on mobile devices!

[◀ Previous challenge](./04-challenge-messaging.md) | [🔼 Day 2](../README.md) | [Next challenge ▶](./06-challenge-bo-3.md)
