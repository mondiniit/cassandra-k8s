module "az_rt_a" {
  source = "git::https://github.com/my_hostname/k8s-rt-module.git?ref=0.1.0"

  resource_group   = element(split(",", data.consul_keys.input.var.resource_groups), 0)
  environment      = data.consul_keys.input.var.environment
  name_suffix      = data.consul_keys.input.var.name_suffix_region_a
  vnet_name        = element(split(",", data.consul_keys.input.var.vnet_names), 0)
  subnet_name      = element(split(",", data.consul_keys.input.var.subnet_names), 0)
  route_table_name = data.consul_keys.input.var.cluster_name
  route_names      = ["local-pod-cidr-1", "local-pod-cidr-2", "local-pod-cidr-3", "remote-pod-cidr-1", "remote-pod-cidr-2", "remote-pod-cidr-3"]
  route_prefixes = [
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_a), 0),
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_a), 1),
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_a), 2),
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_b), 0),
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_b), 1),
    element(split(",", data.consul_keys.input.var.node_pod_cidr_region_b), 2)
  ]
  route_nexthop_types = ["VirtualAppliance", "VirtualAppliance", "VirtualAppliance", "VirtualAppliance", "VirtualAppliance", "VirtualAppliance"]
  next_hop_in_ip_address = [
    element(split(",", data.consul_keys.input.var.worker_ips_region_a), 0),
    element(split(",", data.consul_keys.input.var.worker_ips_region_a), 1),
    element(split(",", data.consul_keys.input.var.worker_ips_region_a), 2),
    element(split(",", data.consul_keys.input.var.worker_ips_region_b), 0),
    element(split(",", data.consul_keys.input.var.worker_ips_region_b), 1),
    element(split(",", data.consul_keys.input.var.worker_ips_region_b), 2)
  ]
}

