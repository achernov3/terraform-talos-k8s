locals {
  control_plane     = var.control_plane_role
  worker            = var.worker_role
  default           = var.default
  default_pool_path = "/var/lib/libvirt/images"
  localhost         = "127.0.0.1"
  disk_name         = var.disk_name
}