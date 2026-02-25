resource "libvirt_network" "network" {
  count     = var.enabled ? 1 : 0
  name      = var.network_settings.name
  autostart = var.network_settings.autostart
  forward = {
    nat = {
      ports = [
        {
          start = var.network_settings.forward.nat.ports.start
          end   = var.network_settings.forward.nat.ports.end
        }
      ]
    }
  }
  dns = {
    enable = var.network_settings.dns
  }
  ips = [{
    address   = var.network_settings.ips.address
    local_ptr = var.network_settings.ips.local_ptr
    netmask   = var.network_settings.ips.netmask
    dhcp = {
      ranges = [
        {
          start = var.network_settings.ips.dhcp.ranges[0].start
          end   = var.network_settings.ips.dhcp.ranges[0].end
          lease = {
            expiry = var.network_settings.ips.dhcp.ranges[0].lease.expiry
            unit   = var.network_settings.ips.dhcp.ranges[0].lease.unit
          }
        }
      ]
    }
  }]
}