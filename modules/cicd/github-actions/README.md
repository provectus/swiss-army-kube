# Github Actions

## Example

``` hcl
module "github_runners" {
  depends_on   = [module.cert_manager]
  source       = "git::https://github.com/provectus/swiss-army-kube.git//modules/cicd/github-actions"
  argocd       = module.argocd.state
  cluster_name = module.eks.cluster_id
  github_token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  actions_repositories = {
    "repo-one"      = "provectus/repo-one"
    "repo-two"      = "provectus/repo-two"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| actions\_repositories | describe your variable | `map(string)` | `{}` | no |
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| chart\_version | A Helm Chart version | `string` | `"0.5.2"` | no |
| cluster\_name | A name of the Amazon EKS cluster | `string` | n/a | yes |
| conf | A custom configuration for deployment | `map(string)` | `{}` | no |
| github\_token | A GitHub token for application | `string` | n/a | yes |
| module\_depends\_on | A list of explicit dependencies | `list(any)` | `[]` | no |
| namespace | A name of the existing namespace | `string` | `""` | no |
| namespace\_name | A name of namespace for creating | `string` | `"github-actions"` | no |
| runner\_deployment\_spec | A custom Github Runner configuration | `any` | <pre>{<br>  "replicas": 2,<br>  "template": {<br>    "spec": {<br>      "dockerdWithinRunnerContainer": true,<br>      "image": "summerwind/actions-runner-dind",<br>      "labels": [<br>        "private"<br>      ],<br>      "repository": "%REPOSITORY%",<br>      "volumeMounts": [<br>        {<br>          "mountPath": "/runner",<br>          "name": "runner"<br>        }<br>      ],<br>      "volumes": [<br>        {<br>          "emptyDir": {},<br>          "name": "runner"<br>        }<br>      ]<br>    }<br>  }<br>}</pre> | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |
