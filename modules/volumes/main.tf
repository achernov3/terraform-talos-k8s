locals {
  default = "default"
}

resource "libvirt_volume" "node_volume" {
  name     = "${var.node_volume.name}.${var.node_volume.format}"
  pool     = coalesce(var.node_volume.pool, local.default)
  capacity = var.node_volume.capacity * 1024 * 1024 * 1024
}
