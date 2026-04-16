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
