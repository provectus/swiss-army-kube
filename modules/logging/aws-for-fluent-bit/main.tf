# Create namespace logging
resource "kubernetes_namespace" "logging" {
  depends_on = [
    var.module_depends_on
  ]
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "aws-for-fluent-bit" {
  depends_on = [
    var.module_depends_on
  ]

  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.3"
  namespace  = var.namespace_name

  values = [
    templatefile("${path.module}/values/aws-for-fluent-bit.yaml", {
      aws_region                               = var.aws_region
      namespace                                = var.namespace_name

      service_account_auto_create              = var.service_account_auto_create
      service_account_name                     = var.service_account_name
      service_account_annotations              = var.service_account_annotations

      daemon_set_resources_limits_cpu          = var.daemon_set_resources_limits_cpu
      daemon_set_resources_limits_memory       = var.daemon_set_resources_limits_memory
      daemon_set_resources_requests_cpu        = var.daemon_set_resources_requests_cpu
      daemon_set_resources_requests_memory     = var.daemon_set_resources_requests_memory

      cloudwatch_enabled                       = var.cloudwatch_enabled
      cloudwatch_match                         = var.cloudwatch_match
      cloudwatch_log_group_name                = var.cloudwatch_log_group_name
      cloudwatch_log_stream_name               = var.cloudwatch_log_stream_name
      cloudwatch_log_stream_prefix             = var.cloudwatch_log_stream_prefix
      cloudwatch_log_key                       = var.cloudwatch_log_key
      cloudwatch_log_format                    = var.cloudwatch_log_format
      cloudwatch_role_arn                      = var.cloudwatch_role_arn
      cloudwatch_auto_create_group             = var.cloudwatch_auto_create_group
      cloudwatch_endpoint                      = var.cloudwatch_endpoint
      cloudwatch_credentials_endpoint          = var.cloudwatch_credentials_endpoint

      firehose_enabled                         = var.firehose_enabled
      firehose_match                           = var.firehose_match
      firehose_delivery_stream                 = var.firehose_delivery_stream
      firehose_data_keys                       = var.firehose_data_keys
      firehose_role_arn                        = var.firehose_role_arn
      firehose_endpoint                        = var.firehose_endpoint
      firehose_time_key                        = var.firehose_time_key
      firehose_time_key_format                 = var.firehose_time_key_format

      kinesis_enabled                          = var.kinesis_enabled
      kinesis_match                            = var.kinesis_match
      kinesis_stream                           = var.kinesis_stream
      kinesis_partition_key                    = var.kinesis_partition_key
      kinesis_append_new_line                  = var.kinesis_append_new_line
      kinesis_data_keys                        = var.kinesis_data_keys
      kinesis_role_arn                         = var.kinesis_role_arn
      kinesis_endpoint                         = var.kinesis_endpoint
      kinesis_sts_endpoint                     = var.kinesis_sts_endpoint
      kinesis_time_key                         = var.kinesis_time_key
      kinesis_time_key_format                  = var.kinesis_time_key_format
      kinesis_compression                      = var.kinesis_compression
      kinesis_aggregation                      = var.kinesis_aggregation
      kinesis_experimental_concurrency         = var.kinesis_experimental_concurrency
      kinesis_experimental_concurrency_retries = var.kinesis_experimental_concurrency_retries

      elastic_search                           = var.elastic_search_enabled
      elastic_match                            = var.elastic_match
      elastic_host                             = var.elastic_host
      elastic_aws_auth                         = var.elastic_aws_auth
      elastic_tls                              = var.elastic_tls
      elastic_port                             = var.elastic_port
      elastic_retry_limit                      = var.elastic_retry_limit
    })
  ]
}