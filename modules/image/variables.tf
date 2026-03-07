variable "pool" {
  description = <<-EOT
    Name of the storage pool for the image.

    Specifies which libvirt storage pool should be used to store the
    Talos image. The pool must exist and be accessible.

    Example: "talos-pool", "default"
  EOT
  type        = string
}

variable "image_url" {
  description = <<-EOT
    URL or path to the Talos image.

    This can be either:
    - A URL pointing to a remote Talos ISO image
    - A local file path to a Talos ISO image
    - A path to an image in the libvirt storage pool

    The image is used as the boot media for cluster nodes.

    Example: "/var/lib/libvirt/images/talos-amd64.iso"
  EOT
  type = string
}

variable "default" {
  description = <<-EOT
    Default provider identifier.

    This value is used to specify the default provider for the image
    resource. It is typically set to "default" but can be customized
    for multi-provider setups.

    Default: "default"
  EOT
  type = string
}

variable "cluster_name" {
  description = <<-EOT
    Name of the Kubernetes cluster.

    This name is used as an identifier for the image and related resources.
    It helps organize and identify cluster-specific resources within
    the infrastructure.

    Example: "production", "staging", "dev-cluster"
  EOT
  type        = string
}
