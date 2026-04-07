variable "pool_settings" {
  description = <<-EOT
    Storage pool configuration for virtual machine volumes.

    Defines a libvirt storage pool where disk images for virtual machines
    will be stored. The pool must be created before VMs can be provisioned.

    Attributes:

    - name (string)
      Name of the storage pool.

    - type (string)
      Type of storage pool. Common types include:
      - "dir": Directory-based pool (only supports)

    - target (object)
      Storage pool target configuration.

      - target.path (string)
        Path to the storage directory or device.

      - target.permissions (object, optional)
        Permissions for the storage directory.

        - permissions.owner (string, optional)
          Owner UID for the directory.
          Default: "1000"

        - permissions.group (string, optional)
          Owner GID for the directory.
          Default: "1000"

        - permissions.mode (string, optional)
          Directory permissions in octal format.
          Default: "0711"

    Example:
      pool_settings = {
        name = "talos-pool"
        type = "dir"
        target = {
          path = "/var/lib/libvirt/images/talos"
          permissions = {
            owner = "1000"
            group = "1000"
            mode  = "0711"
          }
        }
      }
  EOT
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

variable "enabled" {
  description = <<-EOT
    Enable or disable storage pool creation.

    When set to true, the storage pool defined in pool_settings will be
    created. When set to false, no storage pool will be created and the
    module will use an existing pool or skip pool configuration.

    This is useful for conditional pool creation based on environment
    or user preferences.

    Default: false
  EOT
  type        = bool
  default     = false
}
