resource "libvirt_pool" "storage_pool" {
  count = var.enabled ? 1 : 0
  name  = var.pool_settings.name
  type  = var.pool_settings.type
  target = {
    path = pathexpand(var.pool_settings.target.path)
    permissions = {
      owner = var.pool_settings.target.permissions.owner
      group = var.pool_settings.target.permissions.group
      mode  = var.pool_settings.target.permissions.mode
    }
  }
}
