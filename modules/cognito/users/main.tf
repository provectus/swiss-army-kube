resource "aws_cognito_user_group" "default" {
  name         = "default"
  user_pool_id = var.pool_id
}


locals {

  #TODO Jay - we should check here if phone number is provided and conditionally format?
  users = {
    for user in var.users :
    user.user_hash => {
      "Type" = "AWS::Cognito::UserPoolUser"
      "Properties" = {
        "UserAttributes" = [
          {
            "Name"  = "email"
            "Value" = user.email
          },
          {
            "Name"  = "email_verified"
            "Value" = "true"
          }
        ],
        "Username"               = user.email
        "UserPoolId"             = var.pool_id
        "DesiredDeliveryMediums" = ["EMAIL"]
      }
    }
  }

  user_groups = {
    for user in var.users :
    user.user_group_hash => {
      "Type" = "AWS::Cognito::UserPoolUserToGroupAttachment"
      "Properties" = {
        "GroupName"  = aws_cognito_user_group.default.name
        "Username"   = user.email
        "UserPoolId" = var.pool_id
      }
      "DependsOn" = user.user_hash
    }
  }

  template = jsonencode({
    "Resources" = merge(local.users, local.user_groups)
  })


}


resource "aws_cloudformation_stack" "cognito_users" {
  name          = var.cloudformation_stack_name
  template_body = local.template
  tags          = var.tags
}


