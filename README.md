# Azure Cloud Resume Challenge

This is my experience going through the Cloud Resume Challenge where I will highlight

* What I did
* What I learned, and
* Challenges that I have faced

## Context

Before starting this challenge, I did not have any experience using the cloud and Azure. Everything in this challenge was new to me and I suggest beginners give it a try.
Overall, it was very fun for me and rewarding to see everything come together at the end. Hopefully, this guide and code may help someone in need. :D

## Resources

I have stumbled upon a few blog posts but they did not provide much information for me to work on as everyone has different methods. I mainly relied on:

* Documentations
* Youtube videos
* ChatGPT (for learning purposes)

### Certification

Although I did not take the AZ-900 (Azure fundamentals) certificate, I have covered the contents to learn some terms and services of Azure using this [Youtube video](https://www.youtube.com/watch?v=5abffC-K40c).
Instead of using a free tier account, I am using an Azure for Students subscription.

### HTML and CSS

As HTML and CSS are not the main focus of this project, I did not want to waste a lot of time on this step. I used ChatGPT to help me generate a simple HTML and CSS template but feel free to make your own or get a template from an online resource.

At this point, I have not changed the contents of the template and have not created a javascript file for the page counter.

### Static Websites

Using the portal, I created a resource group as well as a storage account for this step. There weren't any issues as long as I followed the [documentation](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website).

### HTTPS

To enable HTTPS, a CDN profile and endpoint are needed. Other than providing https, CDN provides other benefits such as improving performance by caching the contents of the static website across several servers which allows for quicker load times and lesser bandwidth usage. To create a CDN profile and endpoint, I followed this [documentation](https://learn.microsoft.com/en-us/azure/cdn/cdn-create-new-endpoint).

HTTPS will be configured in the next step along with DNS.

### DNS

To point a custom domain name to the Azure CDN endpoint, I purchased one from [Namecheap](https://www.namecheap.com/) for a few dollars that lasts for a year.

After the purchase, I delegated the custom domain to Azure DNS following this [documentation](https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns), where they
will go through how to:

* Create a DNS zone
* Retrieve a list of name servers
* Delegate the domain
* Verify it is working

The purpose of delegating the domain to Azure DNS is to let Azure handle all the DNS queries for that domain by updating the Name Server records at the domain registrar. In my case,
it will be Namecheap.

Once it is working, I added the custom domain to the endpoint following this [documentation](https://learn.microsoft.com/en-us/azure/cdn/cdn-map-content-to-custom-domain?tabs=azure-dns%2Cazure-portal%2Cazure-portal-cleanup#create-a-cname-dns-record).
In this step, in addition to creating a CNAME record, I have created an A record as well so that the website can be accessed without specifying "www". Finally, I enabled HTTPS through the endpoint.

### Database

Following the instructions, I have created a Cosmos DB account for Table. It took me a while to understand the terms such as Entities, PartitionKey, and RowKey. To better understand PartitionKey, you can check out this [video](https://www.youtube.com/watch?v=QLgK8yhKd5U). Through the portal, I manually created a table "Table1", an Entity with PartitionKey "PageCounter", RowKey "HomePage", and the count set to 0. Even though I have manually created the table and entity, my function app will also check if the table and entity exist.

### API and Python

This is where the real challenge began for me. Initially, I was coding the API through the Azure portal. Choosing HTTP trigger and Python was straightforward but the confusing part came when I had to select the programming model for Python (v1 and v2). Different models have different methods to query the data from Cosmos DB. I tried different ways through the portal but eventually gave up as it does not provide information on the errors I am getting (Only shows 500 Internal Server Error).


In the end, I wrote the function app locally and deployed it through visual studio code by following this [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=node-v4%2Cpython-v1%2Cisolated-process&pivots=programming-language-python). It provides more benefits such as local testing as well as logs to see the error message. 


For my Python model, I have selected v1 which provides files such as host.json, local.settings.json, etc., but feel free to try the v2. The biggest issue I had with this challenge was connecting to the Cosmos DB to access the count value. I struggled for an entire day to try to get the bindings to work, which was the better way to access other services. For more details, you can read it up [here](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=isolated-process%2Cpython-v2&pivots=programming-language-python).


The reason why I struggled with the bindings was because I was using the wrong bindings the whole time. I was too focused on the bindings for Azure Cosmos DB from this [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2?tabs=isolated-process%2Cextensionv4&pivots=programming-language-python) and this input binding [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2-input?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv4&pivots=programming-language-python) that I have missed out on a section that said: "Azure Cosmos DB bindings are only supported for use with Azure Cosmos DB for NoSQL. Support for Azure Cosmos DB for Table is provided by using the Table storage bindings, starting with extension 5.x.".


Shifting the focus to Table storage bindings from this [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-table?tabs=in-process%2Ctable-api%2Cextensionv3&pivots=programming-language-python#table-api-extension), I manage to get the input and output bindings to work rather easily. However, a new problem came up where the output bindings only support creating a new Entity instead of updating an existing Entity. To update an existing Entity, it is required to use the Azure Tables SDK.  (ㆆ _ ㆆ)


After deciding to use the Azure Tables SDK, I removed both the input and output bindings from my code. **One thing to take note of** is the use of the connection string. By default, the "AzureWebJobsStorage" connection string is to access the Tables in the **storage account**. What I wanted was to access the Tables in the **Cosmos DB**. When testing locally, the connection string can be easily changed/added in the local.settings.json. In my case, I added a "CosmosDbString" with Cosmos DB primary connection string, and called the "CosmosDbString" as an environment variable. However, there is another issue which I will share more in the Infrastructure as Code section below.


### Javascript

This section was supposed to be done before the database section, but I decided to do it after my Function App so I could test both together. In the HTML file, I added a reference to the javascript file which will call the API and update the page counter. When testing locally, I used the link provided by the "func start" command in my javascript file. After deploying the function app, remember to get the link and update the javascript file before updating/uploading the files to the web container in the storage account. During my tests, I realised that the API was working properly when being called by Postman, but it did not work both locally and on Azure. This is due to the CORS setting. 


### Infrastructure as Code

Although the challenge stated to use Azure Resource Manager (ARM), I decided to use Terraform instead. Since I did not have any prior experience, I only knew what Terraform does but I did not know how to use it. To understand the basics, I followed this [tutorial](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli) and tested it out on a new resource group.


Since I already have my infrastructure ready by creating them through the portal, I have to import them into Terraform for me to manage instead of creating new resources. This [Youtube video](https://www.youtube.com/watch?v=HMlDtXTitEg) is great for learning how to import resources into Terraform. The basic idea is:

1. Write the template in Terraform
2. Import the resource using "terraform import"
3. Use "terraform plan" to see which configuration needs to be added or modified to match the infrastructure
4. Ensure that there are "No changes" between Terraform and Azure


This is where I faced another challenge. Remember there was an issue with the connection string in the API section? When testing my API locally, I can easily specify the connection string "CosmosDbString" in my local.settings.json. However, when deploying the function app to Azure, the environment variables are references from "Application settings" which can be found in the portal (function app -> Configuration -> Application Settings). To make "CosmosDbString" work, I have to add it as an Application setting but this means I have to also add it in my function app block in Terraform under "app_settings". The only problem is that the "CosmosDbString" connection string will be visible in plaintext which is dangerous.


To solve this, I can specify the connection string in the Terraform variables file, but that means I won't be able to publish it on GitHub. Instead, I made use of Azure Key Vault to store my connection string.


### Keyvault

By making use of Azure key vault, I can safely store my connection string and reference them in Terraform without displaying it in plaintext. After creating a keyvault, I need to give myself the "Key Vault Administrator" role in Access Control (IAM) to add my connection string in "Secrets". After adding the connection string, I imported Azure key vault resources and data into my Terraform.


### Source Control

At this point, everything was working normally as expected. In normal practices, I would have created a GitHub repository before starting any development work but I decided to follow the challenge step by step. Instead of creating two separate repositories for frontend and backend, I created one and put my codes in their respective folders with their .gitignore files so that it is easier to maintain.


### CI/CD

Setting up GitHub actions was quite simple with the template given (GitHub repo -> Actions -> New workflow -> Configure). I created two workflows, one for my Azure function app, and the other for my static webpage in the storage account. One small change I made was to run the workflow depending on which folder was updated. For workflow authentication with Azure, I added the credentials to GitHub secrets (Settings -> Secret and variables -> Actions). To test it out, I modified the HTML template to my resume and pushed it to the repository. Sure enough, the changes were automatically deployed and updated.


### Conclusion/Reflection

This project was a success and it took me around 2 weeks to complete it during my spare time. The only part I skipped out was writing some tests for my Python code. I may try it out when I have more free time in the future. At the start of the project, I had a constant worry about whether I was doing the right thing and afraid of making mistakes. In the end, I decided to try whatever I wanted as failures will only become learning opportunities and I could easily restart the project as needed. Overall, I had a lot of fun doing this and hopefully, this will be the start of my cloud journey and career. To check out my website, here is the link [www.cmkand.me](https://www.cmkand.me/).



