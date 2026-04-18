module "talos_cluster" {
  source = "../../modules/talos"

  cluster_name       = "talos_lab"
  control_plane_role = local.control_plane_role
  worker_role        = local.worker_role
  default            = local.default
  disk_name          = local.disk_name

  pool_settings = {
    name = "talos_lab"
    type = "dir"
    target = {
      path = "~/talos_lab"
      permissions = {
        owner = "1000"
        group = "1000"
        mode  = "0711"
      }
    }
  }
  network_settings = null
  k8s_network = {
    disable_default_cni = true
    disable_kube_proxy  = true
  }

  talos_image = {
    factory = {
      version      = "latest"
      architecture = "amd64"
      platform     = "metal"
      extensions = [
        "iscsi-tools",
        "qemu-guest-agent",
        "util-linux-tools"
      ]
    }
  }

  nodes = {
    "master-1" = {
      role      = local.control_plane_role
      cpu       = 2
      memory    = 2
      disk_size = 10
    },
    "worker-1" = {
      role      = local.worker_role
      cpu       = 2
      memory    = 2
      disk_size = 10
    }
  }
}

resource "local_file" "kubeconfig" {
  content              = module.talos_cluster.kube_config
  filename             = "${pathexpand("~")}/.kube/config.d/${local.cluster_name}.yaml"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "local_file" "talosconfig" {
  content              = module.talos_cluster.talos_config
  filename             = "${pathexpand("~")}/.talos/${local.cluster_name}-config.yaml"
  directory_permission = "0755"
  file_permission      = "0600"
}

resource "local_file" "machineconfig" {
  for_each             = module.talos_cluster.machine_config
  content              = each.value
  filename             = "${pathexpand("~")}/.talos/${local.cluster_name}/${each.key}-machine-config.yaml"
  directory_permission = "0755"
  file_permission      = "0600"
}
