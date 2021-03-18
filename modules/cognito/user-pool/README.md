## Cognito module

#### Example
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