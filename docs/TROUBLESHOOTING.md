# Troubleshooting

### Debugging Terraform
To set Terraform logs to the verbose mode:
``` 
export TF_LOG=trace
```

To remove corrupt state:
```
terraform state rm module.loki.helm_release.loki-stack
```

To refresh tfstate:
```
terraform refresh -var-file example.tfvars
```

To recreate resources:
```
terraform taint module.system.null_resource.helm_init
```

If `terraform destroy` command fails, run `destroy_fix.sh` and try `terraform destroy` again. After successful destroy process go to AWS console and delete argo-artifacts S3 bucket (if needed), also delete Route53 resources remaining from your deployment.

Further reading: 
* [Debugging Terraform](https://www.terraform.io/docs/internals/debugging.html)