output "pool_settings" {
  value = length(libvirt_pool.storage_pool) > 0 ? libvirt_pool.storage_pool[0] : null
}
