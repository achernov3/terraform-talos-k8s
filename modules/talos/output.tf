output "control_plane_endpoint" {
  value = length(module.vm.control_plane_endpoints_list) > 0 ? module.vm.control_plane_endpoints_list[0] : null
}

output "client_configuration" {
  value     = talos_machine_secrets.this.client_configuration
  sensitive = true
}

output "talos_config" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "machine_config" {
  value = { for k, v in data.talos_machine_configuration.machine_configuration : k => v.machine_configuration }
}
