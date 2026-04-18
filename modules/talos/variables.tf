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

variable "disk_name" {
  type = string
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

variable "k8s_network" {
  description = <<-EOT
    Kubernetes network configuration for Talos.

    Allows disabling the default CNI (Flannel) and kube-proxy. This is highly
    recommended when you plan to install a custom CNI such as Cilium, which
    typically provides its own routing and kube-proxy replacement.

    Attributes:

    - disable_default_cni (bool, optional)
      If true, Talos will not install its default CNI (Flannel).
      Nodes will remain in NotReady state until a custom CNI is installed.
      Default: true

    - disable_kube_proxy (bool, optional)
      If true, Talos will not run kube-proxy. This requires a CNI that
      provides kube-proxy replacement (like Cilium).
      Note: Cannot be true if disable_default_cni is false.
      Default: true

    Example:
      k8s_network = { disable_default_cni = true, disable_kube_proxy = true }
  EOT
  type = object({
    disable_default_cni = optional(bool, true)
    disable_kube_proxy  = optional(bool, true)
  })
  validation {
    condition = (
      (var.k8s_network.disable_default_cni == true) ||
      (var.k8s_network.disable_default_cni == false && var.k8s_network.disable_kube_proxy == false)
    )
    error_message = "kube-proxy cannot be disabled when using default CNI. Allowed: (true,*), (false,false)."
  }
}