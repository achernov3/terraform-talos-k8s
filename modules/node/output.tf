locals {
  control_plane_endpoints = {
    for k, v in data.libvirt_domain_interface_addresses.node_ips :
    k => v.interfaces[0].addrs[0].addr
    if libvirt_domain.node[k].title == local.control_plane
  }
}

data "libvirt_domain_interface_addresses" "node_ips" {
  for_each = libvirt_domain.node
  domain   = each.key
}

output "control_plane_endpoints_list" {
  value = values(local.control_plane_endpoints)
}

output "node_ip_addr" {
  value = {
    for k, v in data.libvirt_domain_interface_addresses.node_ips :
    k => v.interfaces[0].addrs[0].addr
  }
}
