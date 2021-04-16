variable "cloudformation_stack_name" {
  description = "Unique name for the cloudformation stack that will be managed by terraform"
  type        = string
}
variable "pool_id" {
  description = "ID for cognito user pool to which to add resources"
  type        = string
}

variable "user_groups" {
  description = "Cognito user-groups to be created"
  type        = list(string)
}

variable "users" {
  description = "A mapping of users to groups, with unique hashes "
  type = list(object({
    username        = string
    email           = string
    group           = string //TODO current this entry will have no effect. All users are assigned to "default"
    user_hash       = string // a unique has representation of the user. Must be alphanumeric and max 64 chars. For example sha("user@${username}").
    user_group_hash = string // a unique has representation of the user. Must be alphanumeric and max 64 chars. For example sha("user-group@${username}"). Must differ from user_hash as each must be unique
  }))
  default = []
}


variable "tags" {
  type        = map(string)
  description = "A set of tags"
  default     = {}
}