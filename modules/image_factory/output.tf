output "talos_image" {
  value = data.talos_image_factory_urls.this[0].urls
}
