locals {
  latest     = "latest"
  siderolabs = "siderolabs"
}

data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = var.talos_image_spec.use_stable
  }

  lifecycle {
    postcondition {
      condition = (
        var.talos_image_spec.version == local.latest ||
        contains(self.talos_versions, var.talos_image_spec.version)
      )
      error_message = <<-EOT
      The provided version '${var.talos_image_spec.version}' of Talos does not exist.
      Available versions: ${join(", ", self.talos_versions)}
      EOT
    }
  }
}

locals {
  talos_image_version = var.talos_image_spec.version == local.latest ? reverse(data.talos_image_factory_versions.this.talos_versions)[0] : var.talos_image_spec.version
}

data "talos_image_factory_extensions_versions" "this" {
  count         = length(var.talos_image_spec.extensions) > 0 ? 1 : 0
  talos_version = local.talos_image_version
  filters = {
    names = var.talos_image_spec.extensions
  }
  lifecycle {
    postcondition {
      condition     = alltrue([for extension in var.talos_image_spec.extensions : contains(self.extensions_info[*].name, "${local.siderolabs}/${extension}")])
      error_message = <<-EOT
      Missing extensions for Talos version ${local.talos_image_version}:
      %{~for extension in var.talos_image_spec.extensions~}
        %{~if !contains(self.extensions_info[*].name, "${local.siderolabs}/${extension}")~}
          - ${extension}
        %{~endif~}
      %{~endfor~}
      EOT
    }
  }
}

locals {
  official_extensions = length(var.talos_image_spec.extensions) > 0 ? data.talos_image_factory_extensions_versions.this[0].extensions_info[*].name : []
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        extraKernelArgs = var.talos_image_spec.extra_kernel_args
        systemExtensions = {
          officialExtensions = local.official_extensions
        }
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  talos_version = local.talos_image_version
  schematic_id  = talos_image_factory_schematic.this.id
  architecture  = var.talos_image_spec.architecture
  platform      = var.talos_image_spec.platform
}