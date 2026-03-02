module "talos_cluster" {
  source = "./modules/talos"

  cluster_name       = "talos_lab"
  control_plane_role = local.control_plane_role
  worker_role        = local.worker_role
  default            = local.default

  pool_settings    = null
  network_settings = null

  local_image = {
    name = "talos-local-image"
    path = "path/to/talos-image.iso"
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