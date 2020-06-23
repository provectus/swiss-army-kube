output "argo_events_namespace" {
  value = "${helm_release.argo-events.namespace}"
}
