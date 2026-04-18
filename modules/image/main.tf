resource "libvirt_volume" "boot_image" {
  name     = var.cluster_name
  pool     = try(var.pool, var.default)

  create = {
    content = {
      url = "${var.image_url}"
    }
  }
}
