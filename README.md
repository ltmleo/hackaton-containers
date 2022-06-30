####
# But First, Containers

Containers have been adopted as a great way to alleviate portability issues. Containers form the core of this OpenHack and underpin everything you&#39;ll be exploring as you progress through the challenges.

The objective of this challenge is to ensure you understand the very basics of containers, can work with them locally, and push them to a container image repository.

**Tip:** If there is not a message indicating logins, you can run the following commands in **PowerShell** via [Cloud Shell](https://shell.azure.com/) or locally with the [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.2.0) installed:

```sh

wget https://bit.ly/GetOHLogins -O pullLogins.ps1

.\pullLogins.ps1

```

##
## Challenge

You have been tasked with improving the local development experience for new developers by using Docker to simplify the building, testing, and running of the application. The CTO would also like to see this become part of the integration testing solution of the build pipeline.

Some of the work has been done for you, but it was during a time when teams were split between operations and development, leaving the code split between multiple codebases. The new CTO believes teams should be a mix of both Ops and Dev and has formed the team you are in now (say hi to your fellow teammates at your table :-)).

###
#### Building and Testing

Since you&#39;re new to this code base, you&#39;re going to verify at least one of the services still works by building and testing locally. In order to do this, you will need to build and run the Points of Interest (POI) container as well as a SQL Server container. The POI container communicates with the SQL Server container over the [Docker network](https://docs.docker.com/v17.09/engine/userguide/networking):

![](RackMultipart20220630-1-rk5lc0_html_395bdaee2f5ded2e.png)_An architecture diagram showing 2 containers, labeled POI and SQL, running via Docker on your local machine. POI is able to communicate with SQL._

To build the POI application, use the [**TripInsights source code**](https://github.com/Microsoft-OpenHack/containers_artifacts) and [**Dockerfile**](https://docs.docker.com/engine/reference/builder/) for each microservice, matching the Dockerfile to the source code.

**Tip** : If you&#39;re having trouble matching the Dockerfile to the source code, remember the services are written in different languages. Take a look inside the Dockerfile, the corresponding service is more obvious than you think.

After setting up a SQL Server container running locally, use an image found in your team&#39;s Azure Container Registry (ACR) (already deployed to your Azure Subscription) in order to add sample data to the database. You&#39;ll need to authenticate to the registry first - reference the Azure Container Registry resource in the Azure portal for registry credentials.

```sh

docker run --network \&lt;networkname\&gt; -e SQLFQDN=\&lt;servername\&gt; -e SQLUSER=\&lt;db-user\&gt; -e SQLPASS=\&lt;password\&gt; -e SQLDB=mydrivingDB \&lt;your-registry\&gt;.azurecr.io/data-load:1.0

```

**Tip** : The dataload image used in the above command expects a database called &quot;mydrivingDB&quot; to exist already in SQL. Find a way to connect to your running SQL container to create this.

Then configure the POI application to connect to this SQL Server so you can test that the application works. You can find the [curl commands](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/poi#testing) to test the applications endpoints in the POI applications README.

IMPORTANT: Set the ASPNETCORE\_ENVIRONMENT environment variable in POI to Local. This configures the application to skip the use of SSL encryption, allowing connection to the local sql server.

###
#### Building and Pushing TripInsights Images

Now that you are sure the POI application works, the team must ensure that all of the TripInsights components are built as Docker images and pushed to the team&#39;s Azure Container Registry (ACR).

If you choose to test the rest of the images, you can run them locally and send an HTTP GET request to the health endpoint. For example, to hit the POI health endpoint on a container running locally on port 8080, curl or visit in-browser [http://localhost:8080/api/poi/healthcheck](http://localhost:8080/api/poi/healthcheck). Endpoints other than the health endpoint may not be functional at this point (due to dependencies on APIs or the SQL database), so don&#39;t worry if you can&#39;t reach them.

##
## Success Criteria

- **Each member** of your team must show your coach a locally running Points of Interest (POI) container connected to a running SQL Server container. Verify that your POI container is serving content via [HTTP commands](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/poi#testing). Explain your setup to your coach and how it could be used for development and testing.
- **Your team** must have built images for all the TripInsights components and pushed them to the team&#39;s ACR. Share your understanding of how each of the images were built and pushed to the registry with your coach.

##
## References

Docker

- [Getting Started with Docker](https://docs.docker.com/get-started/)
- [Docker Networking](https://docs.docker.com/v17.09/engine/userguide/networking)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker CLI reference](https://docs.docker.com/engine/reference/commandline/cli/)

SQL Server

- [Getting Started with SQL Server Container](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017)
- [Configuring SQL server](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-docker)

Azure

- [Azure CLI reference](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Build with ACR](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task)

Trip Insights Source Code

- [Containers OpenHack on GitHub](https://github.com/Microsoft-OpenHack/containers_artifacts)
- [Testing POI API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/poi#testing)

####
# Getting Ready for Orchestration

Containers are extremely useful on their own, but their flexibility and potential is multiplied when deployed to an orchestrator. Some of the advantages of deploying your containers to an orchestrator include:

- Deployment reliability
- Scaling on demand
- Better resource utilization and application density

Before getting into the details of what it takes to bring a cluster to production, your CTO would like you to first do a spike to validate your application can be deployed in a Kubernetes environment.

**Tip:** If there is not a message indicating logins, you can run the following commands in **PowerShell** via [Cloud Shell](https://shell.azure.com/) or locally with the [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.2.0) installed:

```sh

wget https://bit.ly/GetOHLogins -O pullLogins.ps1

.\pullLogins.ps1

```

##
## Challenge

At this point, you&#39;ve built the images for the components of your application and made those images available in your private ACR. Your team&#39;s goal in this challenge is to deploy your application to a test Azure Kubernetes Service (AKS) cluster in your Azure subscription.

Focus on making sure your containers are all up and can communicate and reach the necessary Azure services. In particular:

- tripviewer needs to be able to access the trips and userprofile services
Note: The Swagger API Documentation links on the homepage of tripviewer will not work at this time. You will add this functionality in a later challenge.
- Your POI and User (Java) APIs must be reachable (even though they are not accessed by the Trip Viewer application at this stage). Refer to the application documentation for ways to test the endpoints.
Note: There&#39;s no need to give each API an external IP.
- All APIs must be able to access the SQL database provided in your Azure subscription. Connection details can be found in the **Messages** tab of your OpenHack portal.
- SQL connection information should be stored on the cluster in a Kubernetes Secret and not written directly into the deployment files for each microservice.

##
## Desired Architecture

![](RackMultipart20220630-1-rk5lc0_html_4b7c85d0babeb7b4.png)_An architecture diagram showing a Kubernetes cluster and an Azure SQL database. Within the cluster, the TripViewer (Web) container is able to communicate to 4 other containers: POI, Trips, User, and User-Java. Those 4 containers communicate with the Azure SQL database._

Services will all run in the kubernetes cluster with the TripViewer application making calls to the APIs to get data. Data is stored on an Azure SQL Server which is accessed by the APIs.

##
## Success Criteria

- **Your team** successfully created an AKS cluster in Azure
- **Your team** must demonstrate that at least one pod for each component of the TripInsights application is running
- **Your team** must demonstrate that the components in your cluster can connect to other components or resources:
  - tripviewer is able to access the trips and userprofile services
  - All APIs are able to access the SQL database provided in your Azure subscription
  - The POI and User (Java) APIs are reachable from the TripViewer web app top links (but the APIs do not have to be accessible from outside the AKS cluster)
- **Your team** must demonstrate that the components in your cluster are accessing SQL connection information via a Kubernetes Secret.

##
## References

Kubernetes

- [Kubernetes core concepts](https://docs.microsoft.com/en-us/azure/aks/concepts-clusters-workloads)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)
- [Kubernetes DNS for services and pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Kubernetes Port Forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)
- [Kubernetes External Load Balancers](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubectl overview](https://kubernetes.io/docs/user-guide/kubectl-overview/)

Azure Kubernetes Service (AKS)

- [Deploy an AKS cluster using Azure CLI](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough)
- [Azure CLI: az aks create](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create)

Azure Container Registry (ACR)

- [Authenticate with ACR from AKS](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks)

Azure

- [Azure CLI reference](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli)
- [Resource naming conventions](https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions)

####
# To Orchestration and Beyond

Your CTO was impressed with your ability to show that AKS can easily support your application using a test deployment. However, you agreed that this deployment would not pass muster with your internal security team or meet audit requirements. Going forward, you&#39;ll need to configure a cluster that will ultimately become part of Humongous Insurance&#39;s existing cloud infrastructure.

**Tip:** If there is not a message indicating logins, you can run the following commands in **PowerShell** via [Cloud Shell](https://shell.azure.com/) or locally with the [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.2.0) installed:

```sh

wget https://bit.ly/GetOHLogins -O pullLogins.ps1

.\pullLogins.ps1

```

##
## Challenge

Your team&#39;s goal in this challenge is to create and configure a Kubernetes cluster on Azure with the appropriate security measures in place. Your company deals with sensitive information, so it is imperative that you address security when configuring your cluster. You need to enable cluster authentication managed through your company&#39;s Azure Active Directory (AAD) tenant and implement **Role-Based Access Control (RBAC)**, protect your resources by using a dedicated **Virtual Network (VNet)** and protect the most critical part of your Kubernetes cluster, the **Kubernetes API Server**.

Keep in mind these are just the first steps of securing your cluster. You will be asked to further improve your security in later challenges.

As you configure your cluster, your CTO would like you to consider **Availability** , **Network Requirements** , and **Access**.

###
### Availability

1. Users of TripInsights expect their data to be accurate and up-to-date at all times. It&#39;s important to consider the availability of the application to inform your decision on the number of nodes in your cluster.

###
### Network Requirements

1. Due to the size of Humongous Insurance, many of the private IP address spaces are being used. You were lucky enough to get your networking team to give you an IP range for running applications within Azure. There is an existing VNet in your subscription that represents the IP range that has been allocated for your team (both for your cluster _and_ other resources).
2. Pods on your cluster should be able to directly communicate with other resources on the VNET via private IP addresses.

#### **Protecting Resources with a VNet**

As with many other Azure services, you can protect your Kubernetes nodes by placing them into a VNet. The use of a VNet prevents unauthorized external connections, and can increase the security of corresponding managed services.

#### **Access**

1. Access to the Kubernetes API server should be limited to those who need it, and the level of access should depend on the intended use.
2. You may have noticed the other users in your Active Directory tenant. While you are part of the Admin team and should have permissions to access any resource in the cluster, there are two other users from the Web and API teams in your AAD tenant:
  - **web-dev** user (View access for API resources, Edit access for Web resources).
  - **api-dev** user (View access to Web resources, Edit access to API resources)

**Tip** : Segmenting cluster resources with _namespaces_ will help manage access. Think through how namespaces might change existing configuration details such as service name resolution.

#### **Use of RBAC (Role-Based Access Control)**

RBAC is used to assign **Roles** (a group of permissions to resources) to **Users** (any entity that accesses a resource interactively) or **Service accounts** (any entity that accesses a resource non-interactively and independent of a User).

Using these constructs allows you to separate permissions between different users and engage in the **Principle of Least Privilege**. This principle suggests that any **User** or **Service account** should be assigned **Role(s)** with the minimum privilege necessary to access the resources that they require to complete their operational role against the cluster and for each application.

Note: When working with AKS, it&#39;s important to be aware of both Azure RBAC _and_ Kubernetes RBAC.

##
## Success Criteria

- **Your team** successfully created an RBAC enabled AKS cluster within the address space allocated to you by the network team
- **Your team** successfully redeployed the TripInsights application, now segmented into api and web namespaces, into the cluster
- **Your team** must demonstrate connectivity to and from your cluster by being able to reach the internal-vm (already deployed)
- **Your team** must demonstrate that you are prompted on cluster access to authenticate with AAD
- **Different members** of your team must be able to connect to your cluster using the **api-dev** and **web-dev** AAD users and demonstrate appropriate access levels

##
## References

Networking for AKS

- [Configuring Azure CNI with AKS](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)

Access and Identity for AKS

- [Access and identity options](https://docs.microsoft.com/en-us/azure/aks/concepts-identity)
- [AKS-managed Azure Active Directory integration](https://docs.microsoft.com/en-us/azure/aks/managed-aad)
- [Control Kubeconfig Access](https://docs.microsoft.com/en-us/azure/aks/control-kubeconfig-access)
- [Use Azure AD and Kubernetes RBAC for clusters](https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac)

Availability

- [AKS Uptime SLA](https://docs.microsoft.com/en-us/azure/aks/uptime-sla)

Kubernetes

- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

####
# Putting the Pieces Together

Now that your cluster is connected to your production network and has passed the initial scrutiny of your security team, it&#39;s time to further improve your application&#39;s security and open it up to external traffic.

**Tip:** If there is not a message indicating logins, you can run the following commands in **PowerShell** via [Cloud Shell](https://shell.azure.com/) or locally with the [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.2.0) installed:

```sh

wget https://bit.ly/GetOHLogins -O pullLogins.ps1

.\pullLogins.ps1

```

##
## Challenge

Some security concerns were addressed in the previous challenge, but it&#39;s important to continue to keep security in mind for this challenge (and in the real world!).

###
### Security

To improve secret management, you have additional security requirements mandated by your CTO:

1. Secrets should be secured in an external vault, not on the cluster. This approach prevents values from being accessed directly by any person without permissions or access to the vault itself.
2. Access to the external key vault should not require a secret stored in the cluster.

###
### Ingress

Although you have multiple services deployed to the cluster, you will want a single endpoint for your customers to reach. To do this, create an ingress controller and configure the ingress rules to route to the appropriate services. The **References** section contains more information on the paths for the different components.

In order to validate that your application is working as expected, you will need to submit a single endpoint (http://endpoint.you.provide) to a provided simulator. The simulator will start sending traffic to the APIs once you provide your endpoint. It expects to make calls to the APIs by name (http://endpoint.you.provide/api/trips for example). You can see data start to flow through your app via the Trip Viewer application. The simulator is deployed as a container instance in your subscription and you will find the URL for the simulator in the **Messages** tab of your OpenHack portal.

###
### Desired Architecture

![](RackMultipart20220630-1-rk5lc0_html_f0b559eafa597e3.png)_An architecture diagram showing traffic flow into the Kubernetes cluster directed by an ingress controller. External traffic comes into the ingress controller, and from there is redirected based on path. &quot;/api/poi&quot; is directed to the POI service; &quot;/api/trips&quot; to Trips; &quot;api/user&quot; to User; and &quot;api/user-java&quot; to User-Java. The path &quot;/&quot; is directed to the TripViewer (Web) front end. Arrows indicate communication between TripViewer (Web) and the 4 API microservices as well as between the APIs and Azure SQL._

##
## Success Criteria

- **Your team** secured your Azure SQL Server connection information such that literal values cannot be inappropriately accessed
- **Your team** used an external key vault to store and access secrets inside your cluster, and ensured that access does not require a secret stored in the cluster
- **Your team** ensured that all links on the Trip Viewer site are reachable
- **Your team** ensured the simulator can successfully update the values in the application across all services

##
## References

API paths reference

- [Trip Viewer](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/tripviewer#paths)
- [Points of Interest API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/poi#api-paths)
- [Trip API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/trips#api-paths)
- [User API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/user-java#api-paths)
- [User Profile API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/userprofile#api-paths)

API configuration reference

- [Points of Interest API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/poi#configuration)
- [Trip API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/trips#configuration)
- [User API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/user-java#configuration)
- [User Profile API](https://github.com/Microsoft-OpenHack/containers_artifacts/tree/main/src/userprofile#configuration)

Azure Kubernetes Service (AKS)

- [Secret Store CSI driver](https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)
- [Ingress Controllers](https://docs.microsoft.com/en-us/azure/aks/concepts-network#ingress-controllers)
- [Create an NGINX ingress controller in AKS](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
- [HTTP Application Routing Ingress Controller](https://docs.microsoft.com/en-us/azure/aks/http-application-routing)

Kubernetes

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

Azure

- [Resource naming conventions](https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions)

####
# Wait, What&#39;s Happening

Deploying your applications to a cluster is just the first step for running containers in production, and it&#39;s important to think about operations and scenarios around your deployments. It is valuable to have a holistic understanding of your cluster when it comes to ensuring your applications are reliable, available, and tolerant to failures.

**NOTE:** From this challenge on, your team may only advance if your cluster is in a healthy state.

##
## Challenge

Your CTO is impressed with the speed at which you were able deploy the application but now wants to see you how your application is performing. The task the CTO has given for this challenge is to make sure your cluster is &#39;production ready&#39; by implementing a monitoring solution that improves the observability of your cluster and adding alerts for key metrics so you can get ahead of any issues that will occur.

First, choose and implement a monitoring solution for your team to use. While choosing a monitoring solution, think about the four main components that must be considered to fully understand what is happening with your cluster so you can answer critical questions your CTO will ask.

1. Applications running on the containers
2. Containers
3. Underlying Virtual Machines
4. Kubernetes API

You can use the simulator from the previous step to create load on your application for testing and monitoring purposes.

###
### A new application

Your focus on security and monitoring has encouraged other teams to try out AKS. Your CTO has asked you to run the following deployment in order to test a new project that calculates insurance rates faster and more accurately than ever before. This new project is intended to eventually become part of the TripInsights application. Ensure that you have configured your monitoring solution so you can quickly identify any issues that might arise.

Replace the image reference below with a reference to your ACR. The insurance application image is already deployed into your ACR.

apiVersion: apps/v1

kind: Deployment

metadata:

name: insurance-deployment

labels:

deploy: insurance

spec:

replicas: 2

selector:

matchLabels:

app: insurance

template:

metadata:

labels:

app: insurance

spec:

containers:

- image: &quot;replaceme.io/insurance:1.0&quot;

imagePullPolicy: Always

name: insurance

ports:

- containerPort: 8081

name: http

protocol: TCP

---

apiVersion: v1

kind: Service

metadata:

name: insurance

spec:

type: ClusterIP

selector:

app: insurance

ports:

- protocol: TCP

name: insurance-http

port: 80

targetPort: 8081

You can verify that the app is running by visiting the service endpoint which should return your calculation.

Of course, you didn&#39;t write this application, so it isn&#39;t up to your standards… Using your recently deployed monitoring solution, monitor the behavior of the new application in your cluster and see if you can determine what the runtime behavior of this application is. Additionally, if you find any issues, make sure to fix them in the deployment and create alerts for anything that might cause your application or cluster to experience downtime.

##
## Success Criteria

- **Your team** must create a monitoring solution that shows the runtime behaviors of the application. You must be able to answer the following questions:
  - How many requests are coming to your cluster?
  - How much memory is allocatable per node in your cluster?
  - What is the CPU usage of your workload? What is the CPU usage of internal Kubernetes tools?
  - How many pods are currently pending?
  - Which pod is consuming the most memory?
- **Your team** must deploy a set of tools that will allow you to monitor your cluster and its applications.
- **Your team** must demonstrate where to obtain logs for the 4 main components mentioned in the first section of this page
- **Your team** must successfully implement resource limits on the newly deployed application
- **Your team** must set up an alert that informs you if an application is nearing resource limits in order to prevent cluster-wide issues
- **Your team** must demonstrate your cluster is overall &quot;Healthy&quot; for 15 minutess

##
## References

Monitoring Microservices

- [Overview of Monitoring for microservices](https://docs.microsoft.com/en-us/azure/architecture/microservices/logging-monitoring)

Azure

- [Azure Container Insights reference](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview)
- [Azure Container Insights Agent Config](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-agent-config)
- [Search Logs to Analyze Data](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-log-search#search-logs-to-analyze-data)
- [Kusto Query Language Reference](https://docs.microsoft.com/en-us/azure/kusto)
- [Container Insights Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-alerts)

Prometheus

- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Built-in Prometheus Metrics](https://github.com/helm/charts/tree/master/stable/nginx-ingress#prometheus-metrics)
- [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/)
- [Using Function Operators to Analyze Data from Prometheus](https://prometheus.io/docs/prometheus/latest/querying/examples/#using-functions-operators-etc)

####
# Locking it Down

You&#39;ve done a lot of work so far to make sure your security and monitoring were in place, but there is still work to do to improve the security of your cluster.

##
## Challenge

Your CTO is feeling confident in what your team has been able to accomplish, but there are still some security concerns you will need to address. After all, when dealing with sensitive information, security is one of the top concerns. As part of an effort to limit secrets stored in the cluster and to remove reliance on username and password authentication, the Trip service has been updated to enable SQL access via managed identity. Utilize this by setting up pod identity in your cluster.

In this challenge you must work to increase the security of your cluster by meeting these requirements:

1. Services in your cluster should only be able to make requests to other services if explicitly required.
2. None of the deployed services should be able to communicate with the api server.
3. None of the applications should run as root. This should be enforced by default.
4. Limit the egress traffic to only what is necessary.
5. Limit secrets stored in the cluster by implementing a managed identity for your services.

##
## Success Criteria

- **Your team** restricted access from the deployed services access to kube-apiserver
- **Your team** limited the access to the Kubernetes API Server to only machines from your location
- **Your team** demonstrated that the API applications cannot call each other
- **Your team** restricted ability to deploy applications that have root access
- **Your team** limited the egress traffic from the cluster
- **Your team** enabled sql server access from inside the vnet only
- **Your team** has enabled the trip service access to SQL DB utilizing a managed identity.

##
## References

Kubernetes

- [Kubernetes Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

AKS

- [Azure Policy for Kubernetes clusters](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes)
- [Using Network Policies](https://docs.microsoft.com/en-us/azure/aks/use-network-policies)
- [Secure access to the API server using authorized IP address ranges in AKS](https://docs.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges)
- [Control egress traffic for cluster nodes in AKS](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)
- [Pod Identity](https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity)

Azure SQL Database

- [Use virtual network service endpoints and rules for database servers](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-vnet-service-endpoint-rule-overview)
- [Azure CLI: az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)
- [Azure CLI: az sql server firewall-rule](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest)

####
# Mixed Emotions

We interrupt your regular programming with this special announcement:

Your company has acquired a company and you need to deploy some of its workloads into your cluster. One of the services is a Windows Communication Foundation (WCF) service, which calculates new policy prices based on driver data. Prior to the acquisition, the company experimented with containerizing this service and succeeded in running it on Docker. In order to take advantage of Kubernetes for additional orchestration, you will need to deploy this service alongside the rest of your Linux services and update the web app to communicate with the new service.

##
## Challenge

Your team&#39;s challenge is to deploy this new service along with the rest of the application into a single cluster without making changes to previous deployment files. Your team must also ensure the new service is integrated into the TripInsights application by upgrading the Trip Viewer application to use a different image that has already been deployed to your registry: _tripviewer2:1.0_. This application calls out to the WCF service in your cluster.

###
### Things to think about

Much of what you&#39;ve accomplished so far has given you the tools you need to incorporate this new service, however mixed workloads on Kubernetes and AKS can require you think differently about your overall cluster deployment, making sure it&#39;s configured to support both OS types. Here are some questions to ask yourself when considering the addition of Windows workloads:

- What are the cluster features required to support Windows?
- How do you control the deployment to ensure Windows containers are directed to appropriate nodes?
- Are there changes to your cluster&#39;s networking when adding Windows nodes to AKS?

###
### About the Windows Service

The new service is a Windows Communication Foundation (WCF) service. It is already pushed to your registry as _wcfservice:1.0_ and listens on port 80 for requests.

###
### About Trip Viewer 2

The updated Trip Viewer app expects an environment variable, WCF\_ENDPOINT, in order to communicate with the service. You can test the communication by navigating to the UserProfile page of the app and clicking the ProcessRequest button for a user, which calls out to the WCF service and receives a response. If nothing happens, something isn&#39;t right.

###
### Desired Architecture

![](RackMultipart20220630-1-rk5lc0_html_4d0d3461f6d12bd3.png)_An architecture diagram showing a Kubernetes cluster with both Windows and Linux containers. External traffic comes in via the ingress controller, and is directed in the same manner as was specified in Challenge 4. As before, there is communication between TripViewer (Web) and the 4 API microservices as well as between the APIs and Azure SQL. However, there is now an additional Windows container labeled WCF which communicates directly with TripViewer (Web)._

##
## Success Criteria

- **Your team** successfully deployed the WCF application into the same AKS cluster as your Linux workloads
- **Your team** ensured that previous deployments are unchanged and unaffected
- **Your team** ensured that the updated Trip Viewer web app can successfully communicate with the WCF service
- **Your team** must demonstrate your cluster is overall &quot;Healthy&quot;

##
## References

- [Windows Containers in Kubernetes](https://kubernetes.io/docs/setup/production-environment/windows/intro-windows-in-kubernetes/)
- [Multiple Node Pools in AKS](https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools)
- [Windows on AKS](https://docs.microsoft.com/en-us/azure/aks/windows-container-cli)
- [About Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/about/)

####
# Doing More with Service Mesh

As you add more services to your Kubernetes cluster, operational complexity increases. In modern polyglot distributed application environments, this complexity increases even further. There is an overhead involved in maintaining versions of the same operational capabilities (security, observability, robustness, policy) in different languages for each of your services.

What if there was an approach that could decouple these operational and policy capabilities from our code base? Enter the service mesh!

##
## Service Mesh

Linkerd, Istio, &amp; OpenServiceMesh(OSM) are three popular service meshes.

&quot;Linkerd moves visibility, reliability, and security constraints down to the infrastructure layer, out of the application layer.&quot;

_- William Morgan, CEO, Buoyant_

&quot;Istio decouples operational aspects of the services from the implementation of the services.&quot;

_- Eric Brewer, VP Infrastructure &amp; Google Fellow, Google Cloud_

&quot;OSM is a vendor neutral service mesh solution for Kubernetes with an explicit focus on simplicity&quot;

_- Matt Klein, creator of Envoy_

A service mesh typically provides the following set of capabilities:

- **Traffic Management**
  - Protocol Support – http/s, grpc, tcp
  - Dynamic Routing – conditional, weighting, mirroring
  - Resiliency – timeouts, retries, circuit breakers
  - Policy – access control, rate limits, quotas
  - Testing - fault injection
- **Security**
  - Encryption – mTLS, certificate management
  - Strong Identity – SPIFFE or similar
  - Auth – authentication, authorisation
- **Observability**
  - Metrics – golden metrics
  - Tracing - traces across workloads

##
## Challenge

Your team&#39;s goal in this challenge is to deploy a service mesh into your AKS cluster. The service mesh will augment and expand the capabilities you have already explored and added to your Trip Insights services as part of the previous challenges. None of the aspects of this challenge will require changes to your currently deployed code.

First, your team must build on the security foundations laid in previous challenges. The team must enable mutual TLS for all intra-cluster communication within the Trip Insights platform. Ensure that you also understand how you can verify that your traffic is now secure.

Next, your team must expand on the observability we introduced in a previous challenge. Service meshes provide you with the capability to generate additional application level metrics. The team must show latency, traffic, and error metrics in a dashboard to provide additional insight into the operational health of the Trip Insights services.

Finally, your team must leverage the service mesh to make your services more robust. Intermittent network or service errors can be mitigated by using retry and timeout policies. Ensure that your team has configured these appropriately for each service.

Your team has been offered the following guidance. Istio is a feature rich, customisable and extensible service mesh, and can be more difficult to configure and get running successfully. Linkerd is an easy to use and lightweight service mesh, and makes it very easy to get up and running quickly.

##
## Success Criteria

- **Your team** must have successfully deployed a service mesh into your Kubernetes cluster. Share your understanding of each of the relevant components of the service mesh and what capability they support.
- **Your team** has secured all intra-cluster communication with mutual TLS. Demonstrate to your coach how you can verify that secure communication has been established.
- **Your team** must show a dashboard to your coach that provides the following 3 metrics for the TripInsights services. These 3 metrics are a subset of the four golden signals:
  - Latency - The time it takes to service a request. Show latency between P50 and P99.
  - Traffic - A measure of how much demand is being placed on the service. Show http requests per second.
  - Errors - The rate of requests that fail. This can also be expressed inversely as the success rate. Show errors per second.
- **Your team** , if your service supports it, has added retry and timeout policies to the TripInsights services. Demonstrate these in action to your coach.
- **Your team** must demonstrate your cluster is overall &quot;Healthy&quot;

##
## References

Service Meshes

- [About Service Meshes](https://docs.microsoft.com/en-us/azure/aks/servicemesh-about)

Linkerd

- [Linkerd - Getting Started](https://linkerd.io/2/getting-started/)
- [Linkerd - Overview](https://docs.microsoft.com/en-us/azure/aks/servicemesh-linkerd-about)
- [Install Linkerd in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/servicemesh-linkerd-install)

Istio

- [What is Istio?](https://istio.io/docs/concepts/what-is-istio/)
- [Istio - Overview](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-about)
- [Install and use Istio in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install)

OpenServiceMesh(OSM)

- [OpenServiceMesh](https://docs.openservicemesh.io/)
- [AKS about OpenServiceMesh](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-about)
- [Install and use OSM via Azure Kubernetes Service (AKS) OSM Add-on](https://docs.microsoft.com/en-us/azure/aks/open-service-mesh-deploy-add-on)
- [OSM Dashboards](https://github.com/openservicemesh/osm/tree/main/charts/osm/grafana/dashboards)

Distributed Systems