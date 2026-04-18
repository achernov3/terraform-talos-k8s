resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "machine_configuration" {
  for_each         = var.nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${module.vm.control_plane_endpoints_list[0]}:6443"
  machine_type     = each.value.role
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = each.value.role == local.control_plane ? [
    templatefile("${path.module}/files/control-plane.yaml.tftpl", {
      install_disk        = local.install_disk
      disable_default_cni = var.k8s_network.disable_default_cni
      disable_kube_proxy  = var.k8s_network.disable_kube_proxy
    })
    ] : [
    templatefile("${path.module}/files/worker.yaml.tftpl", {
      install_disk        = local.install_disk
      disable_default_cni = var.k8s_network.disable_default_cni
      disable_kube_proxy  = var.k8s_network.disable_kube_proxy
    })
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = module.vm.control_plane_endpoints_list
}

resource "talos_machine_configuration_apply" "machine_configuration_apply" {
  for_each                    = var.nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machine_configuration[each.key].machine_configuration
  node                        = module.vm.node_ip_addr[each.key]

  depends_on = [module.vm]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.machine_configuration_apply]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = module.vm.control_plane_endpoints_list[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = module.vm.control_plane_endpoints_list[0]
}
