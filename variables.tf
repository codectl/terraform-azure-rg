variable "groups" {
  description = "Contains all resource group configuration"
  type = map(object({
    name               = optional(string)
    location           = optional(string)
    managed_by         = optional(string)
    tags               = optional(map(string))
    use_existing_group = optional(bool)
    management_lock = optional(object({
      name  = optional(string)
      level = string
      notes = optional(string)
    }))
  }))
}

variable "use_existing_groups" {
  description = "use existing resource groups globally"
  type        = bool
  default     = false
}

variable "location" {
  description = "default azure location to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
