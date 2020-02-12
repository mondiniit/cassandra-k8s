module "az_nsg_b" {
  source = "git::https://github.com/my_hostname/k8s-nsg-module.git?ref=0.2.0"

  resource_group = element(split(",", data.consul_keys.input.var.resource_groups), 1)
  cluster_name   = data.consul_keys.input.var.cluster_name
  environment    = data.consul_keys.input.var.environment
  name_suffix    = random_string.id_b.result

  ns_rules = [
    {
      name                   = "k8s-services"
      priority               = "150"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "30000-32767"
      destination_address_prefix = "VirtualNetwork"
      description                = "Port range for Kubernetes services"
    },
  ]
}

module "az_lb_b" {
  source = "git::https://github.com/my_hostname/k8s-lb-module.git?ref=0.3.0"

  resource_group = element(split(",", data.consul_keys.input.var.resource_groups), 1)
  cluster_name   = data.consul_keys.input.var.cluster_name
  environment    = data.consul_keys.input.var.environment
  name_suffix    = random_string.id_b.result

  lb_ports = {
    dns   = ["53", "Udp", data.consul_keys.input.var.lb_rule_port_kube_dns, data.consul_keys.input.var.lb_rule_port_kube_dns_probe, ""]
    cqlsh = ["9042", "Tcp", data.consul_keys.input.var.lb_rule_port_cqlsh, data.consul_keys.input.var.lb_rule_port_cqlsh, ""]
  }
}

module "az_vms_b" {
  source = "git::https://github.com/my_hostname/k8s-vms-module.git?ref=0.3.0"

  cluster_name              = data.consul_keys.input.var.cluster_name
  environment               = data.consul_keys.input.var.environment
  name_suffix               = random_string.id_b.result
  main_resource_group       = element(split(",", data.consul_keys.input.var.resource_groups), 1)
  vnet_name                 = element(split(",", data.consul_keys.input.var.vnet_names), 1)
  subnet_name               = element(split(",", data.consul_keys.input.var.subnet_names), 1)
  images_resource_group     = element(split(",", data.consul_keys.input.var.images_resource_groups), 1)
  k8s_image_name            = data.consul_keys.input.var.k8s_image_name
  bastion_image_name        = data.consul_keys.input.var.bastion_image_name
  ssh_public_key            = data.vault_generic_secret.ssh_secrets.data["id_rsa_pub"]
  worker_count              = data.consul_keys.input.var.worker_count
  network_security_group_id = module.az_nsg_b.network_security_group_id
  lb_address_pool_id        = module.az_lb_b.lb_address_pool_id
  add_bastion               = "no"
  worker_vm_size            = data.consul_keys.input.var.worker_vm_size
  manager_vm_size           = data.consul_keys.input.var.manager_vm_size
}

resource "random_string" "id_b" {
  length  = 6
  lower   = true
  upper   = false
  number  = false
  special = false
}

resource "cloudflare_record" "cassandra_b" {
  domain  = "${data.consul_keys.input.var.root_domain}"
  name    = "cassandra.${data.consul_keys.input.var.environment}-${random_string.id_b.result}"
  value   = "${element(module.az_lb_b.load_balancer_public_ip, 0)}"
  type    = "A"
  proxied = false
}

resource "consul_keys" "output_b" {
  key {
    path  = "${var.consul_base_path}/output/worker-ips-${element(split(",", data.consul_keys.input.var.regions), 1)}"
    value = data.consul_keys.input.var.worker_count == "0" ? "" : module.az_vms_b.worker_ips
  }

  key {
    path  = "${var.consul_base_path}/output/manager-ips-${element(split(",", data.consul_keys.input.var.regions), 1)}"
    value = module.az_vms_b.manager_ips
  }

  key {
    path  = "${var.consul_base_path}/output/load-balancer-ip-region-b"
    value = element(module.az_lb_b.load_balancer_public_ip, 0)
  }

  key {
    path  = "${var.consul_base_path}/output/name-suffix-region-b"
    value = random_string.id_b.result
  }
}
