resource "aws_cognito_user_group" "default" {
  name         = "default"
  user_pool_id = var.pool_id
}


locals {
  //constructs a cloudformation template for cognito users
  //TODO add dynamic group construction, currently all users are assigned to "default"

  // todo: add var.tags in UserPoolTags for AWS::Cognito::UserPoolUser

  cloudformation_resources = join(", \n", [
    for user in var.users:
          <<EOF
  "${user.user_hash}": {
    "Type" : "AWS::Cognito::UserPoolUser",
    "Properties" : {
      "UserAttributes" : [
        { "Name": "email", "Value": "${user.email}"},
        { "Name": "email_verified", "Value": "true"}
      ],
      "Username" : "${user.email}",
      "UserPoolId" : "${var.pool_id}"
      }
    },
    "${user.user_group_hash}": {
      "Type" : "AWS::Cognito::UserPoolUserToGroupAttachment",
      "Properties" : {
        "GroupName" : "${aws_cognito_user_group.default.name}",
        "Username" : "${user.email}",
        "UserPoolId" : "${var.pool_id}"
      },
      "DependsOn" : "${user.user_hash}"
    }
EOF
])

  cloudformation_template_body = join("\n", ["{\"Resources\" : \n  {\n",local.cloudformation_resources,"}\n}"])
}

resource "aws_cloudformation_stack" "cognito_users" {
  name = var.cloudformation_stack_name
  template_body = local.cloudformation_template_body
  tags = var.tags
}


