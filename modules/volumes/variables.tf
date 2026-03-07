variable "node_volume" {
  description = <<-EOT
    Volume configuration for a virtual machine node.

    Defines a disk volume that will be attached to a virtual machine.
    This is the primary storage device for the node's operating system
    and data.

    Attributes:

    - name (string)
      Name of the volume. This name must be unique within the storage pool.

    - pool (string)
      Name of the storage pool where this volume will be created.
      The pool must already exist.

    - format (string, optional)
      Disk image format. Common formats include:
      - "qcow2": QEMU Copy-on-Write v2 (recommended, supports snapshots)
      - "raw": Raw disk image (no overhead, no snapshots)
      - "qed": QEMU Enhanced Disk format
      Default: "qcow2"

    - capacity (number)
      Capacity of the volume in gigabytes. This is the size of the
      virtual disk that will be presented to the VM.

    Example:
      node_volume = {
        name     = "master-1-disk"
        pool     = "talos-pool"
        format   = "qcow2"
        capacity = 40
      }
  EOT
  type = object({
    name     = string
    pool     = string
    format   = optional(string, "qcow2")
    capacity = number
  })
}
