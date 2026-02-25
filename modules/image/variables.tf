variable "pool" {
  description = "Define pool name for image"
  type        = string
}

variable "local_image" {
  description = "Provide path to image. You can use local path or url"
  type = object({
    name = string
    path = string
  })
}

variable "default" {
  type = string
}