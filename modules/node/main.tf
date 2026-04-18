module "network" {
  source = "../network"

  enabled          = var.network_settings != null
  network_settings = var.network_settings
}

module "pool" {
  source = "../pool"

  enabled       = var.pool_settings != null
  pool_settings = var.pool_settings
}

module "image" {
  source = "../image"

  default      = local.default
  cluster_name = var.cluster_name
  image_url    = var.image_url
  pool         = try(module.pool.pool_settings.name, local.default)

  depends_on = [module.pool]
}

module "volume" {
  source = "../volumes"

  for_each = var.nodes

  node_volume = {
    name     = each.key
    pool     = try(module.pool.pool_settings.name, local.default)
    capacity = each.value.disk_size
  }

  depends_on = [module.pool]
}

resource "libvirt_domain" "node" {
  for_each    = var.nodes
  type        = "kvm"
  autostart   = true
  title       = each.value.role
  name        = each.key
  memory      = each.value.memory
  memory_unit = var.memory_unit
  vcpu        = each.value.cpu

  cpu = {
    mode = "host-passthrough"
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      {
        dev = "cdrom"
      }
    ]
  }

  devices = {
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = try(module.network.network_settings.name, local.default)
          }
        }
        wait_for_ip = {
          source = "lease"
        }
      },
    ]
    graphics = [
      {
        vnc = {
          autoport = "yes"
          listen   = local.localhost
        }
      }
    ]
    disks = [
      {
        device = "cdrom"
        source = {
          file = {
            file = try("${module.pool.pool_settings.target.path}/${module.image.image.name}", "${local.default_pool_path}/${module.image.image.name}")
          }
        }
        target = {
          dev = "sda"
          bus = "scsi"
        }
      },
      {
        source = {
          file = {
            file = try("${module.pool.pool_settings.target.path}/${module.volume[each.key].node_volume.name}", "${local.default_pool_path}/${module.volume[each.key].node_volume.name}")
          }
        }
        target = {
          dev = local.disk_name
          bus = "virtio"
        }
      },
    ]
  }
  depends_on = [module.pool, module.network]
  running    = true
}
