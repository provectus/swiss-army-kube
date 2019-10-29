# issuers

This chart creates Letsencrypt certificate ClusterIssuer using DNS-01 challenge mechanism.

More info about cert-manager processes: [cert-manager](https://docs.cert-manager.io/en/latest/tutorials/acme/quick-start/index.html#step-5-deploy-cert-manager)

## Prerequisites

To use this chart you need helm chart for cert-manager installed in its own namespace:

```
helm install --name cert-manager \
             --namespace cert-manager \
             --version v0.11.0 \
             jetstack/cert-manager
```

## Configuration

**FIXME**: change accessKeyID/secretAccessKey into using IAM policies

Parameter | Description | Default
--- | --- | ---
| `accessKeyID`                           | | ``                                                |
| `secretAccessKey`                       | | ``                                                |
| `email`                                 | E-mail to use in cert generation | `noreply@provectus.com`                                                |
| `region`                                | | ``                                                |
| `secretNamespace`                       | Namespace for secret holding `secretAccessKey` (optional) | `cert-manager`                                    |
| `hostedZoneID`                          | Route53 zone ID for managed zone (optional) | `` |

### Per-issuer configuration:

**Warning:** don't enable issuer that you don't need yet. Otherwise if you reinstall the chart you might not be able to use that issuer.

Parameter | Description | Default
--- | --- | ---
| `letsencrypt.staging.enabled`                        | | `false`                                                |
| `letsencrypt.prod.enabled`                           | | `false`                                                |


## Provided resources

`ClusterIssuer` resources provided:
 * `letsencrypt-staging` - for use in development/testing to avoid bans and hitting rate limits. Is not trusted by SSL clients.
 * `letsencrypt-prod` - for production usage

## Example usage

```yaml
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: mycert
spec:
  secretName: mycert
  commonName: example.provectus.com
  dnsNames:
    - example.provectus.com
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
```
