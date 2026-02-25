output "control_plane_endpoint" {
  value = length(module.vm.control_plane_endpoints_list) > 0 ? module.vm.control_plane_endpoints_list[0] : null
}

output "client_configuration" {
  value     = data.talos_client_configuration.this
  sensitive = true
}

output "kube_config" {
  value     = resource.talos_cluster_kubeconfig.this
  sensitive = true
}

output "machine_config" {
  value = data.talos_machine_configuration.machine_configuration
}
