# deploying a functioning wordpress web page in 30 minutes (including three coffee breaks in the middle!).

## you have decided to launch your first wordpress web page and attach a mysql data base but you don't know where to start? this is your lucky day. here is all you need to know.

## warning: this task uses a lot of highly toxic current devops technologies such as aws ec2, terraform, bash script, docker, rancher, kubernetes, aws eks, etc.

## this task is to deploy kubernetes cluster on aws eks using rancher. rancher container will run on an aws ec2 instance. for provisioning rancher server ec2, we will use terraform. 

## tasks:
### provisioning ec2 instance for rancher server with terraform
### install docker, docker compose, kubectl, rancher etc using user data with terraform
### provision eks cluster, kubernetes infrastructure using rancher user interface
### deploy wordpress, deploy mysql data base, deploy and mount persistent volume using rancher user interface command line

### note 1: ec2 must have sufficient resources to run rancher. min 2 vcpus and 8 gb ram required. (t2.large or a larger ec2 instance.)
### note 2: we will tag the ec2 name as rancher.
### note 3: according to rancher documentation https://rancher.com/docs/rancher/v2.5/en/installation/ current terminology is as follows:
### - The Rancher server manages and provisions Kubernetes clusters. You can interact with downstream Kubernetes clusters through the Rancher server’s user interface.
### - RKE (Rancher Kubernetes Engine) is a certified Kubernetes distribution and CLI/library which creates and manages a Kubernetes cluster.
### - K3s (Lightweight Kubernetes) is also a fully compliant Kubernetes distribution. It is newer than RKE, easier to use, and more lightweight, with a binary size of less than 100 MB.
### - RKE2 is a fully conformant Kubernetes distribution that focuses on security and compliance within the U.S. Federal Government sector.
### - RancherD is a new tool for installing Rancher, which is available as of Rancher v2.5.4. It is an experimental feature. RancherD is a single binary that first launches an RKE2 Kubernetes cluster, then installs the Rancher server Helm chart on the cluster.
### note 4: according to rancher documentation web page, rancher v2.x described as:
### - Rancher was originally built to work with multiple orchestrators, and it included its own orchestrator called Cattle. With the rise of Kubernetes in the marketplace, Rancher 2 exclusively deploys and manages Kubernetes clusters running anywhere, on any provider.
### - Rancher can provision Kubernetes from a hosted provider, provision compute nodes and then install Kubernetes onto them, or import existing Kubernetes clusters running anywhere.
### - One Rancher server installation can manage thousands of Kubernetes clusters and thousands of nodes from the same user interface.
### - Rancher adds significant value on top of Kubernetes, first by centralizing authentication and role-based access control (RBAC) for all of the clusters, giving global admins the ability to control cluster access from one location.
### - It then enables detailed monitoring and alerting for clusters and their resources, ships logs to external providers, and integrates directly with Helm via the Application Catalog. If you have an external CI/CD system, you can plug it into Rancher, but if you don’t, Rancher even includes Fleet to help you automatically deploy and upgrade workloads.
### - Rancher is a complete container management platform for Kubernetes, giving you the tools to successfully run Kubernetes anywhere.

### create folder
```
$ mkdir rancher
$ cd rancher
```
### .tf file for deploying ec2 instance which will run as rancher server
```
$ vim ec2.tf
```
### for sample content please see: https://github.com/E2415Matt/rancher

### user data will install docker, docker compose, kubectl, rancher in the ec2
```
$ vim user-data-rancher.sh
```
### for sample content please see: https://github.com/E2415Matt/rancher

### run the script to provision infrastructure on aws with terraform
```
$ terraform init
$ terraform fmt
$ terraform validate
$ terraform plan
$ terraform apply -auto-approve
```
# take your first break

### when you are back, copy the ip address and make connection to the instance and see the hello world run
### once terraform script run, ec2 started, output / display ec2 instance public ip
### copy and paste rancher server ec2 public ip address displayed on the screen to your internet browser you should see: (please also see screen shot 1) 

```
Howdy!

Welcome to Rancher
It looks like this is your first time visiting Rancher; if you pre-set your own bootstrap password, enter it here. Otherwise a random one has been generated for you. To find it:

For a "docker run" installation:
Find your container ID with docker ps, then run:
docker logs container-id <container id> | grep "Bootstrap Password:"

For a Helm installation, run:

kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'
```

### you can use your own password if you like to. rancher gives you default admin username as admin.
### once user credentials recorded you can start deploying kubernetes cluster using rancher.
### we have k8s and k3s option. we are using latest image for rancher container therefore it should come up as k3s. k3s use less resources to do the same job. 
### secrets, security and hardened kubernetes practices need to be considered.
### go to rancher control panel and click: create and amazon eks and continue as desired
### try runing wordpress and mysql deployments with horizontal pod autoscaling



### connect to ec 2 instance, and from ec2 comand line 
```
$ docker ps
```
### and copy container id
### use the container id of rancher container for finding bootstrap password following command
```
$ docker logs <container id> | grep "Bootstrap Password:"
```
### find the password highlighted in red, which should look like: gtvzw46prlwdtj0cwp67z4d8dlsv57tlm65cdd52f548nvhphw2dgx
### copy the password and paste the same to password section on the welcome to rancher page. and click "Log in with Local User"

### at the next screen make sure to take copy and note the new password, and click continue and you should see screenshot 2

### create a cluster using rancher control panel: create, amazon eks, give cluster name (we have decided name the cluster as wp1), click labels&annotations, click add label, key=name, value=wp1, click account access, region eu-west-2, enter your amazon aws access key and secret key, click create, cluster options, add tag, key=name, value=rancher, configure network, click custom, select subnets, instance type t3.medium, node volume size 8 gb, node group name=wp1, desired asg size=1, maximum asg size=5, minimum asg size=1, click create

### click wp1, click kubectl shell, when shell command line in the bottom window ready to use;
```
$ vi kustomization.yaml
```
### for sample content please see: https://github.com/E2415Matt/rancher

### then yaml files for kubernetes deployments of wordpress and mysql each as follows:
```
$ vi wordpress-deployment.yaml
```
```
$ vi mysql-deployment.yaml
```
### for sample content please see: https://github.com/E2415Matt/rancher

### run the yaml files to deploy wordpress and mysql, and check the resources as follows:
```
$ kubectl apply -k ./
```
# take your second break

```
kubectl get secrets
kubectl get pvc
kubectl get pods
kubectl get svc
```
### copy wordpress external ip from the screen and paste the same to internet browser and you should see screen shot 3. when prompted give a user name and password(and record them). see screenshot 4. once you entered and saved credentials you should see the main page of wordpress as shown on screenshot 5.
###  click workload, click pods, see wordpress and wordpress-mysql pods are running (screenshot 6)
### and continue as desired, 

### remark: bear in mind that we have picked a minimal ec2 instance as rancher server therefore we have not been able to install monitoring. we are using 2 vcpus and 4 gib memory, if you want to install monitoring (prometheus, grafana) you would need to use bigger instances such as t2.2xlarge. If you have the bigger instance, You can follows: install monitoring, monitoring, install. and customise as rerquired.

## bonus: you can do the same using rancher control panel or you can use terraform scripts to deploy cluster and services. if you want to use rancher user interface, you can do as follows:

### go to rancher control panel and click: create, amazon eks, give cluster name, we have decided name the cluster as wp1, click labels&annotations, click add label, key=name, value=wp1, click account access, region eu-west-2, enter amazon aws access key and secret key, click create, cluster options, add tag, key=name, value=rancher, configure network, click custom, select subnets, instance type t3.medium, node volume size 8 gb, node group name=wp1, desired asg size=1, maximum asg size=5, minimum asg size=1, click create

### now when you click home, click cluster namagement, click clusters, you should see two of them namely local and wp1. 

# take your third break
### or, wait few minutes until state of the cluster changes to "provisioning", "waiting", and then to "active", once cluster become active, click explore, 

### in order to run micro services you may need persistent volumes, make sure to create necessary number and size persistent volumes first and then you can go and create deployments along with persistent volume claims for each.

### from home screen click cluster management, click explore of wp1, click perojects/namespaces, create a project, name=wppg1, description=wordpress postgres 1, click create, go to wppg1, create namespace, name=dev, description=dev, create, click storage, persistentvolumes, click create, name=wppv1, description=wppv1, volume plucgin=hostpath, capacity=1, path on the node=/tmp/, the path on the node must be=a dorectory or create if does not exist, click create, click storage, persistent volume claim, namescpace=dev, name=wppvc1, description=wordpress persistentvolumeclaim 1, use existing persistent volume, persistent volume, from pull down list wppv1, click create

### click workload, deployments, create, namespace=dev, name=wppg1, description=worpress postgresql, replicas=1, general, standard container, contaner image=ntninja/wordpress-postgresql, pull policy=ifnotpresent, labels&annotations, add label, key=name, value=wppg1, storage, add volume, persistent volume claim, volume name=vol0, persistent volume claim=wppvc1, click create


### in order to avoid unnecessary cost destroy the resources
### 1- on rancher command line
```
$ kubectl delete -k ./
```
### 2- delete whatever resources deployed with rancher user panel from rancher user panel

### 3- from inside the rancher folder 
```
$ terraform destroy -auto-approve
```
### I hope this guided tour of rancher helps you boost your confidence around rancher user interface.

### if you want see similar articles, please visit: https://ivymatt2017.medium.com/
