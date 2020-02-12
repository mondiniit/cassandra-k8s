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

variable "consul_base_path" {
  type = string
}

data "consul_keys" "input" {
  key {
    name = "cluster_name"
    path = "${var.consul_base_path}/input/cluster-name"
  }

  key {
    name = "resource_groups"
    path = "${var.consul_base_path}/input/resource-groups"
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
    name = "worker_ips_region_a"
    path = "${var.consul_base_path}/output/worker-ips-eastus2"
  }

  key {
    name = "worker_ips_region_b"
    path = "${var.consul_base_path}/output/worker-ips-westus2"
  }

  key {
    name = "name_suffix_region_a"
    path = "${var.consul_base_path}/output/name-suffix-region-a"
  }

  key {
    name = "name_suffix_region_b"
    path = "${var.consul_base_path}/output/name-suffix-region-b"
  }

  key {
    name = "node_pod_cidr_region_a"
    path = "${var.consul_base_path}/output/node-pod-cidr-eastus2"
  }

  key {
    name = "node_pod_cidr_region_b"
    path = "${var.consul_base_path}/output/node-pod-cidr-westus2"
  }
}
