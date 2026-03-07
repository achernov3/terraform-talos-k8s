variable "pool" {
  description = "Define pool name for image"
  type        = string
}

variable "image_url" {
  type = string
}

variable "default" {
  type = string
}

variable "cluster_name" {
  description = "Name of kubernetes cluster"
  type        = string
}
