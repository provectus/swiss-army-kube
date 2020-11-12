# Cognito
The module creates base resources such as a user pool, Route53 record for a domain, and ACM certificates for it.

## Example
This example demonstrates how you can create an AWS Cognito client for your application.
``` hcl
module cognito {
  source = "<path-to-module>"
  domain = "example.com"
  zone_id = "FOOBAR123456"
}

resource aws_cognito_user_pool_client this {
  name                                 = "foo"
  user_pool_id                         = module.cognito.pool_id
  callback_urls                        = ["https://foo.example.com/oauth2/idpresponse"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  generate_secret                      = true
}
```

## Providers
| Name | Version |
|------|---------|
| aws | n/a |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| cluster\_name | A name of the cluster | `string` | n/a | yes |
| domain | n/a | `string` | n/a | yes |
| tags | A set of tags | `map(string)` | `{}` | no |
| zone\_id | n/a | `string` | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| domain | A custom domain name of the AWS Cognito endpoint |
| pool\_arn | An ARN of the new created AWS Cognito User Pool |
| pool\_id | An ID of the new created AWS Cognito User Pool |


## Known issues
Right now Terraform provider for AWS did not support the creation of users for User Pool, so if you want to start managing users by Terraform need to use the following configuration with `local-exec` provisioner:
``` hcl
resource aws_cognito_user_group this {
  for_each = toset(distinct(values(
    {
      for k, v in var.cognito_users :
      k => lookup(v, "group", "read-only")
    }
  )))
  name         = each.value
  user_pool_id = module.cognito.pool_id
}

resource null_resource cognito_users {
  depends_on = [aws_cognito_user_group.this]
  for_each = {
    for k, v in var.cognito_users :
    v.username => v
  }
  provisioner local-exec {
    command = "aws --region ${var.aws_region} cognito-idp admin-create-user --user-pool-id ${module.cognito.pool_id} --username ${each.key} --user-attributes Name=email,Value=${each.value.email}"
  }
  provisioner local-exec {
    command = "aws --region ${var.aws_region} cognito-idp admin-add-user-to-group --user-pool-id ${module.cognito.pool_id} --username ${each.key} --group-name ${lookup(each.value, "group", "read-only")}"
  }
  provisioner local-exec {
    when    = "destroy"
    command = "aws --region ${var.aws_region} cognito-idp admin-delete-user --user-pool-id ${module.cognito.pool_id} --username ${each.key}"
  }
}

```