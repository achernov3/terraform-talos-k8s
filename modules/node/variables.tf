variable "nodes" {
  description = <<-EOT
    Map of node definitions for the cluster.

    Each key represents a node name, and the value defines the node's
    configuration including role, CPU, memory, and disk size.

    Attributes:

    - role (string)
      Node role in the cluster. Must be either "controlplane" for master
      nodes or "worker" for worker nodes.

    - cpu (number)
      Number of virtual CPUs to allocate to this node.

    - memory (number)
      Amount of memory to allocate to this node. The unit is specified
      by the memory_unit variable (default: GiB).

    - disk_size (number)
      Size of the primary disk in gigabytes.

    Example:
      nodes = {
        "master-1" = { role = "controlplane", cpu = 2, memory = 4, disk_size = 20 }
        "worker-1" = { role = "worker", cpu = 4, memory = 8, disk_size = 50 }
      }
  EOT
  type = map(object({
    role      = string
    cpu       = number
    memory    = number
    disk_size = number
  }))
}

variable "cluster_name" {
  description = <<-EOT
    Name of the Kubernetes cluster.

    This name is used as an identifier for all cluster resources,
    including virtual machines, volumes, networks, and Talos configurations.
    It should be unique within your infrastructure and follow naming conventions
    (alphanumeric characters and hyphens only recommended).

    Example: "production", "staging", "dev-cluster"
  EOT
  type        = string
}

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
          - end (string): End IP address
          - lease.expiry (number, optional): Lease expiry time
          - lease.unit (string, optional): Lease time unit
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

variable "image_url" {
  description = <<-EOT
    URL or path to the Talos image.

    This can be either:
    - A URL pointing to a remote Talos ISO image
    - A local file path to a Talos ISO image
    - A path to an image in the libvirt storage pool

    The image is used as the boot media for all cluster nodes.

    Example: "/var/lib/libvirt/images/talos-amd64.iso"
  EOT
  type        = string
}

variable "memory_unit" {
  description = <<-EOT
    Unit for memory specification in node definitions.

    Defines the unit used when specifying memory amounts in the nodes map.
    The specified unit will be applied to all node definitions.

    Supported values:
    - "GiB" - Gibibytes (default)
    - "MB" - Megabytes

    Note: This is a global setting applied to all nodes. For most use cases,
    the default "GiB" is recommended.

    Default: "GiB"
  EOT
  type        = string
  default     = "GiB"
}

variable "control_plane_role" {
  description = <<-EOT
    Role identifier for control plane nodes.

    This string is used to identify control plane nodes in the Talos
    machine configuration. Typically set to "controlplane" but can be
    customized if needed for specific configurations.

    Default: "controlplane"
  EOT
  type        = string
}

variable "worker_role" {
  description = <<-EOT
    Role identifier for worker nodes.

    This string is used to identify worker nodes in the Talos
    machine configuration. Typically set to "worker" but can be
    customized if needed for specific configurations.

    Default: "worker"
  EOT
  type        = string
}

variable "default" {
  description = <<-EOT
    Default provider identifier.

    This value is used to specify the default provider for various
    resources in the cluster. It is typically set to "default" but can
    be customized for multi-provider setups.

    Default: "default"
  EOT
  type        = string
}

variable "disk_name" {
  description = <<-EOT
    Name of the primary disk device for the virtual machines.

    This specifies the target device name for the node's primary storage volume
    attached to the libvirt domain. Common values are "vda" for VirtIO block devices
    or "sda" for SCSI/SATA devices.

    Example: "vda"
  EOT
  type = string
}