locals {
  install_disk  = "/dev/sda"
  control_plane = var.control_plane_role
  worker        = var.worker_role
}