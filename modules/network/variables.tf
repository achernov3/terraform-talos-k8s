variable "network_settings" {
  description = <<-EOT
    Network configuration for the cluster.

    Defines a libvirt network with NAT forwarding and DHCP capabilities.
    If set to null, default network will be used.

    Attributes:

    - name (string)
      Name of the libvirt network.

    - autostart (bool, optional)
      Whether to start the network automatically when libvirt starts.
      Default: true

    - dns (string, optional)
      Enable or disable DNS. Set to "yes" to enable.
      Default: "yes"

    - forward.nat (object, optional)
      NAT forwarding configuration for external connectivity.

      - nat.ports (object)
        Port range for NAT forwarding.

        - ports.start (string)
          Start of the port range.

        - ports.end (string)
          End of the port range.

    - ips (object)
      IP address configuration for the network.

      - address (string)
        Network base address (e.g., "192.168.100.1").

      - family (string, optional)
        IP address family. Currently only "ipv4" is supported.
        Default: "ipv4"

      - local_ptr (string, optional)
        Local PTR record for reverse DNS.

      - netmask (string, optional)
        Network netmask.
        Default: "255.255.255.0"

      - dhcp (object)
        DHCP server configuration.

        - dhcp.ranges (list(object))
          List of DHCP address ranges.

          Each range has:
          - start (string): Start IP address
          - End IP address
 end (string):          - lease.expiry (number, optional): Lease expiry time
          - lease.unit (string, optional): Lease time unit

    Example:
      network_settings = {
        name      = "talos-network"
        autostart = true
        forward = {
          nat = {
            ports = { start = "10000", end = "20000" }
          }
        }
        ips = {
          address = "192.168.100.1"
          netmask = "255.255.255.0"
          dhcp = {
            ranges = [{
              start = "192.168.100.128"
              end   = "192.168.100.254"
              lease = { expiry = 86400, unit = "seconds" }
            }]
          }
        }
      }
  EOT
  type = object({
    name      = string,
    autostart = optional(bool, true),
    dns       = optional(string, "yes"),
    forward = optional(object({
      nat = object({
        ports = object({
          start = string
          end   = string
        })
      })
    }), null)
    ips = object({
      address   = string
      family    = optional(string, "ipv4")
      local_ptr = optional(string, null)
      netmask   = optional(string, "255.255.255.0")
      dhcp = object({
        ranges = list(object({
          start = string
          end   = string
          lease = object({
            expiry = optional(number, 86400)
            unit   = optional(string, "seconds")
          })
        }))
      })
    })
  })
}

variable "enabled" {
  description = <<-EOT
    Enable or disable network creation.

    When set to true, the network defined in network_settings will be
    created. When set to false, no network will be created and the
    module will use an existing network or skip network configuration.

    This is useful for conditional network creation based on environment
    or user preferences.

    Default: false
  EOT
  type    = bool
  default = false
}
