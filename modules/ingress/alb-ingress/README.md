The AWS ALB Ingress Controller satisfies Kubernetes ingress resources by provisioning Application Load Balancers.


> :warning: For the operator to work correctly, the backend service must have a Node port or Load balancer type

# Example terraform resource kubernetes_ingress for connect alb and nginx

```
resource "kubernetes_ingress" "alb-nginx-ingress" {
    metadata {
        name = "alb-nginx-ingress"
        namespace = "default"
        annotations = {
            "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-west-2:xxxx:certificate/xxxxxx"
            "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
            "alb.ingress.kubernetes.io/scheme" = "internet-facing"
            "alb.ingress.kubernetes.io/listen-ports" = "'[{\"HTTP\":80}, {\"HTTPS\":443}]'"
            "alb.ingress.kubernetes.io/actions.ssl-redirect" = "'{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}'"
            "kubernetes.io/ingress.class" = "alb"
        }
    }

    spec {
        backend {
            service_name = "nginx-nginx-ingress-controller"
            service_port = 80
        }

        rule {
            host = var.domains[0]
            http {
              path {
                path = "/*"
                backend {
                    service_name = "ssl-redirect"
                    service_port = "use-annotation"
                }
              }                
              path {
                path = "/*"
                backend {
                    service_name = "nginx-nginx-ingress-controller"
                    service_port = "80"
                }
              }
            }
        } 
    }   
}

```

# Example kubernetes ingress manifest

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:xxxx:certificate/xxxxxx
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    kubernetes.io/ingress.class: alb
  name: alb-ingress-connect-nginx
  namespace: ingress-system
spec:
  rules:
    - http:
        paths:
          - path: /*
            backend:
             serviceName: ssl-redirect
             servicePort: use-annotation
          - path: /*
            backend:
              serviceName: "nginx-nginx-ingress-controller"
              servicePort: http
```
