terraform {
  required_version = ">= 0.12"
}

terraform {
  backend "consul" {}
}

provider "azurerm" {
  version = "=1.31"
}

provider "consul" {
  scheme = "https"
}

provider "cloudflare" {
  email = var.email
  token = data.vault_generic_secret.cf_dns_secrets.data["cloudflare-api-key"]
}

variable "consul_base_path" {
  type = string
}

variable "email" {
  type = string
}

variable "vault_cloudflare_apikey_path" {
  type = string
}

variable "vault_secret_base_path" {
  type = string
}

data "vault_generic_secret" "cf_dns_secrets" {
  path = var.vault_cloudflare_apikey_path
}

data "vault_generic_secret" "ssh_secrets" {
  path = "${var.vault_secret_base_path}/ssh"
}

data "consul_keys" "input" {
  key {
    name = "cluster_name"
    path = "${var.consul_base_path}/input/cluster-name"
  }

  key {
    name = "regions"
    path = "${var.consul_base_path}/input/regions"
  }

  key {
    name = "resource_groups"
    path = "${var.consul_base_path}/input/resource-groups"
  }

  key {
    name = "images_resource_groups"
    path = "${var.consul_base_path}/input/images-resource-groups"
  }

  key {
    name = "environment"
    path = "${var.consul_base_path}/input/environment"
  }

  key {
    name = "vnet_names"
    path = "${var.consul_base_path}/input/vnet-names"
  }

  key {
    name = "subnet_names"
    path = "${var.consul_base_path}/input/subnet-names"
  }

  key {
    name = "root_domain"
    path = "${var.consul_base_path}/input/root-domain"
  }

  key {
    name = "k8s_image_name"
    path = "${var.consul_base_path}/input/k8s-image-name"
  }

  key {
    name = "bastion_image_name"
    path = "${var.consul_base_path}/input/bastion-image-name"
  }

  key {
    name = "worker_count"
    path = "${var.consul_base_path}/input/worker-count"
  }

  key {
    name = "lb_probe_request_path"
    path = "${var.consul_base_path}/input/lb-probe-request-path"
  }

  key {
    name = "lb_rule_port_http"
    path = "${var.consul_base_path}/input/lb-rule-port-http"
  }

  key {
    name = "lb_rule_port_cqlsh"
    path = "${var.consul_base_path}/input/lb-rule-port-cqlsh"
  }

  key {
    name = "lb_rule_port_kube_dns"
    path = "${var.consul_base_path}/input/lb-rule-port-kube-dns"
  }

  key {
    name = "lb_rule_port_kube_dns_probe"
    path = "${var.consul_base_path}/input/lb-rule-port-kube-dns-probe"
  }

  key {
    name = "cluster_cidrs"
    path = "${var.consul_base_path}/input/cluster-cidrs"
  }

  key {
    name = "manager_vm_size"
    path = "${var.consul_base_path}/input/manager-vm-size"
  }

  key {
    name = "worker_vm_size"
    path = "${var.consul_base_path}/input/worker-vm-size"
  }
}
