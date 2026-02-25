variable "pool_settings" {
  description = "Declare settings for creating a pool"
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

variable "enabled" {
  type    = bool
  default = false
}