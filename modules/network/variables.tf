variable "network_settings" {
  description = "List of networks with specified parameters"
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
  type    = bool
  default = false
}