variable "talos_image" {
  type = object({
    version    = string
    platform   = string
    extentions = list(string)
  })
}