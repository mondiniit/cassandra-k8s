# Cassandra Multiregion on a Custom Kubernetes Cluster (Azure)

## Abstract

This repo is about creating a [Kubernetes](https://kubernetes.io) cluster with [Apache Cassandra](http://cassandra.apache.org/) using Azure resources like virtual machines, virtual network, load balancer and storage.

The infrastructure is created using [Terraform](https://www.terraform.io) who needs input variables coming from [Consul](https://www.consul.io).

Then the deployment of Kubernetes and Cassandra itself is automated using [Rancher](https://rancher.com) and [Ansible](https://www.ansible.com).

## Features

- Creates the Kubernetes control plane with 3 nodes.
- Creates the Kubernetes workers with 3 nodes by default, but configurable.
- Creates a bastion host for secure access to the cluster.
- The infrastructure is provisioned using Terraform modules.
- Creates a Cassandra multiregion cluster, initially on two regions (with 3 nodes each), but it's posible to escalate to more regions depending on Consul configuration.
- Dynamically creates SSH key pair and store it in Vault.
- Configuration is centralized on Consul.

## Deployment

### Dependencies

- This deployment depends on the following Terraform modules:
  - [k8s-vms-module](https://github.com/my_hostname/k8s-vms-module) (Virtual Machines)
  - [k8s-lb-module](https://github.com/my_hostname/k8s-lb-module) (Load Balancer)
  - [k8s-nsg-module](https://github.com/my_hostname/k8s-nsg-module) (Network Security Group/Rules)
  - [k8s-rt-module](https://github.com/my_hostname/k8s-rt-module) (Route Tables)
- An Azure service account with the enough privileges for creating resources like virtual machines, network resources, storage, etc.
- A bastion and a Kubernetes custom image previously created on Azure. You can use [this repo](https://bitbucket.org/my_hostname/bastion-image) and [this](https://bitbucket.org/my_hostname/k8s-image), to create them.
- A Resource Group, VNet and SubNet previously created on an Azure region. If you have the enough privileges, you can use the following example commands to create them:

```
az group create -l westus -n production
az network vnet create -g production -n main-vnet
az network vnet subnet create \
  -g production --vnet-name main-vnet \
  -n main-subnet --address-prefix 10.0.0.0/24
```

- A Consul server and an access token with read/write privileges.
- A Vault server and an access token with read/write privileges.
- A Cloudflare account with an API key (for accessing to bastion).

### Infrastructure and Kubernetes

We use [Drone](https://drone.io) for the deployment pipeline so you need to provide the secrets via Drone UI or CLI.

The following variables must be added to the Drone pipeline:

- **backend-config** -> **path**. The path inside Consul where to store the Terraform state.
- **backend-config** -> **datacenter**. The Consul datacenter name.
- **consul_base_path**. The Consul path where to find input variables.
- **vault_cloudflare_apikey_path**. The Vault path where to read Cloudflare access secrets.
- **vault_secret_base_path**. The Vault path where to store/read the SSH key-pair generated.
- **vault_addr**. The Vault HTTPS address.
- **consul_http_addr**. The Consul HTTPS address.

Secrets:

- **vault_token**. The Vault access token with write permissions.
- **consul_http_token**. The Consul access token with write permissions.
- **azure_tenant**. The Azure service account tenant ID.
- **azure_subscription**. The Azure service account subscription ID.
- **azure_client**. The Azure service account client ID.
- **azure_secret**. The Azure service account secret.
