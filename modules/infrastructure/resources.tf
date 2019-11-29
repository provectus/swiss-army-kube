resource "null_resource" "map_users" {
  count = length(var.admin_arns)

  triggers = {
    user_arn = var.admin_arns[count.index]
    username = "{{UserID}}"
    group    = "system:masters"
  }
}
