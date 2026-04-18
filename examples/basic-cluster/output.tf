output "client_configuration" {
  value     = module.talos_cluster.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.talos_cluster.kube_config
  sensitive = true
}

output "machine_config" {
  value     = module.talos_cluster.machine_config
  sensitive = true
}

output "control_plane_endpoints_list" {
  value = module.talos_cluster.control_plane_endpoint
}
