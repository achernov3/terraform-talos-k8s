module "vm" {
  source = "../node"

  control_plane_role = var.control_plane_role
  worker_role        = var.worker_role
  default            = var.default

  pool_settings = var.pool_settings

  local_image = var.local_image

  network_settings = var.network_settings

  nodes = var.nodes
}