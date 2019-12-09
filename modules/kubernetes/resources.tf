# For depends_on queqe
resource "null_resource" "depends_on" {
  triggers {
    depends_on = "${join("", var.depends_on)}"
  }
}

# Set admin arns
resource "null_resource" "map_users" {
  count = length(var.admin_arns)

  triggers = {
    user_arn = var.admin_arns[count.index]
    username = "{{UserID}}"
    group    = "system:masters"
  }

  depends_on = [
    "null_resource.depends_on"
  ]
}
