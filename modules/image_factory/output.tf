output "schematic_id" {
  value = talos_image_factory_schematic.schematic.id
}

output "installer_url" {
  # Использовать дальше
  value = data.talos_image_factory_urls.url.urls.installer
}