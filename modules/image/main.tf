resource "libvirt_volume" "boot_image" {
  provider = libvirt
  name     = var.local_image.name
  pool     = try(var.pool, var.default)

  create = {
    content = {
      url = "${var.local_image.path}"
    }
  }
}
