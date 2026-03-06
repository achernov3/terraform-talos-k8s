# variable "nodes" {
#   description = "List of nodes"
#   type = list(object({
#     name      = optional(string, null)
#     role      = string
#     cpu       = number
#     memory    = number
#     disk_size = number
#   }))
# }

variable "nodes" {
  description = "List of nodes"
  type = map(object({
    role      = string
    cpu       = number
    memory    = number
    disk_size = number
  }))
}

variable "cluster_name" {
  description = "Name of kubernetes cluster"
  type        = string
}

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

variable "pool_settings" {
  description = "Declare settings for creating a pool"
  type = object({
    name = string
    type = string
    target = object({
      path = string
      permissions = object({
        owner = optional(string, "1000")
        group = optional(string, "1000")
        mode  = optional(string, "0711")
      })
    })
  })
}

variable "image_url" {
  type = string
}

variable "memory_unit" {
  description = "General memory unit for node"
  type        = string
  default     = "GiB"
}

variable "control_plane_role" {
  type = string
}

variable "worker_role" {
  type = string
}

variable "default" {
  type = string
}