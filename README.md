# Azure Cloud Resume Challenge

This is my experience going through the Cloud Resume Challenge where I will highlight

* What I did
* What I learned, and
* Challenges that I have faced

## Context

Before starting this challenge, I did not have any experience using the cloud and Azure. Everything in this challenge was new to me and I suggest beginners give it a try.
Overall, it was very fun for me and rewarding to see everything come together at the end.

## Resources

I have stumbled upon a few blog posts but they did not provide much information for me to work on as everyone has different methods. I mainly relied on:

* Documentations
* Youtube videos
* ChatGPT (for learning purposes)

### Certification

Although I did not take the AZ-900 (Azure fundamentals) certificate, I have covered the contents to learn some terms and services of Azure using this [Youtube video](https://www.youtube.com/watch?v=5abffC-K40c).
Instead of using a free tier account, I am using a Azure for Students subscription.

### HTML and CSS

As HTML and CSS is not the main focus of this project, I did not want to waste a lot of time on this step. I used ChatGPT to help me generate a simple HTML and CSS template for me but feel
free to make your own or get a template from an online resource.

At this point, I have not change the contents of the template and have not created a javascript file for the page counter.

### Static Websites

Using the portal, I created a resource group as well as a storage account for this step. There wasn't any issues as long as I follow the [documentation](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website).

### HTTPS

To enable HTTPS, a CDN profile and endpoint is needed. Other than providing https, CDN provides other benefits such as improving performance by caching the contents of the static website
across several servers which allows for quicker load times and lesser bandwidth usage. To create CDN profile and endpoint, I followed this [documentation](https://learn.microsoft.com/en-us/azure/cdn/cdn-create-new-endpoint).

HTTPS will be configured in the next step along with DNS.

### DNS

To point a custom domain name to the Azure CDN endpoint, I purchased one from [Namecheap](https://www.namecheap.com/) for a few dollars that last for a year.

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

Following the instructions, I have created a Cosmos DB account for Table


