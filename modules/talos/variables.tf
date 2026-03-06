variable "cluster_name" {
  description = "Name of kubernetes cluster"
  type        = string
}

variable "nodes" {
  description = "List of nodes"
  type = map(object({
    role      = string
    cpu       = number
    memory    = number
    disk_size = number
  }))
}

variable "control_plane_role" {
  type = string
}

variable "worker_role" {
  type = string
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

variable "talos_image" {
  type = object({
    local = optional(object({
      name = string
      path = string
    }), null)
    factory = optional(object({
      use_stable        = optional(bool, true),
      version           = optional(string, "latest"),
      architecture      = optional(string, "amd64"),
      platform          = optional(string, "metal"),
      extensions        = optional(list(string), []),
      extra_kernel_args = optional(list(string), []),
    }), null)
  })
  validation {
    condition = (
      (var.talos_image.local != null && var.talos_image.factory == null) ||
      (var.talos_image.local == null && var.talos_image.factory != null)
    )
    error_message = "You must specify either talos_image.local or talos_image.factory, but not both."
  }
  description = <<-EOT
    Specification of the Talos image.

    Exactly one of `local` or `factory` must be specified.

    Attributes:

    local:
      Use an existing Talos image from the local filesystem.

      - name (string)
        Logical name of the Talos image.

      - path (string)
        Path to the Talos ISO image on the local filesystem.

    factory:
      Build a Talos image using the Image Factory.

      - use_stable (bool)
        If true, only stable Talos releases will be used.
        Default: true

      - version (string)
        Talos version to use. Can be an explicit version (e.g. "v1.6.5")
        or "latest" to automatically select the most recent available version.
        Default: "latest"

      - architecture (string)
        Target CPU architecture of the image.
        Supported values typically include: "amd64", "arm64".
        Default: "amd64"

      - platform (string)
        Target platform type for the image. Currently only "metal" is supported.
        Default: "metal"

      - extensions (list(string))
        List of official system extensions to include in the image.
        Extension names must be specified without the registry prefix
        (e.g. "qemu-guest-agent", not "siderolabs/qemu-guest-agent").
        Default: []

      - extra_kernel_args (list(string))
        Additional Linux kernel arguments to append to the Talos boot configuration.
        Default: []
    EOT
}

variable "memory_unit" {
  description = "General memory unit for node"
  type        = string
  default     = "GiB"
}

variable "default" {
  type = string
}