data "talos_image_factory_extensions_versions" "extentions" {
  talos_version = var.talos_image.version
  filters = {
    names = var.talos_image.extentions
  }
}

resource "talos_image_factory_schematic" "schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "url" {
  talos_version = var.talos_image.version
  schematic_id  = output.schematic_id
  platform      = var.talos_image.version.platform
}