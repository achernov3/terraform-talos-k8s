module "image_factory" {
  source = "../image_factory"

  enabled     = var.talos_image.factory != null
  talos_image = var.talos_image
}

module "vm" {
  source = "../node"

  control_plane_role = var.control_plane_role
  worker_role        = var.worker_role
  default            = var.default

  pool_settings = var.pool_settings

  image_url = try(module.image_factory.talos_image.iso, var.talos_image.local.path)

  network_settings = var.network_settings

  nodes = var.nodes
}