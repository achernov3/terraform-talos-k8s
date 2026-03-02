variable "talos_image_spec" {
  type = object({
    use_stable        = optional(bool, true),
    version           = optional(string, "latest"),
    architecture      = optional(string, "amd64"),
    platform          = optional(string, "metal"),
    extensions        = optional(list(string), []),
    extra_kernel_args = optional(list(string), []),
  })
  description = <<-EOT
  Specification of the Talos image to be built via Image Factory.

  Attributes:

  - use_stable (bool)
    If true, only stable Talos versions will be use.
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
    Target platform type for the image. Only "metal" supports.
    Default: "metal"

  - extensions (list(string))
    List of official system extensions to include in the image.
    Extension names must be specified without registry prefix
    (e.g. "qemu-guest-agent", not "siderolabs/qemu-guest-agent").
    Default: []

  - extra_kernel_args (list(string))
    Additional Linux kernel arguments to append to the Talos boot configuration.
    Default: []
  EOT
}
