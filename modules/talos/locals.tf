locals {
  install_disk  = "/dev/${tostring(var.disk_name)}"
  control_plane = var.control_plane_role
  worker        = var.worker_role
}