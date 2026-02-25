variable "node_volume" {
  description = "Declare settings for node volume"
  type = object({
    name     = string
    pool     = string
    format   = optional(string, "qcow2")
    capacity = number
  })
}
