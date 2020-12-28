# For depends_on queue
variable "module_depends_on" {
  default     = []
  type        = list(any)
  description = "A list of explicit dependencies"
}

variable "environment" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
}

variable "project" {
  type        = string
  default     = null
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "A name of the existing namespace"
}

variable "namespace_name" {
  type        = string
  default     = "logging"
  description = "A name of namespace for creating"
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "A name of the Amazon EKS cluster"
}

variable "cluster_oidc_arn" {
  type        = string
  description = "An OIDC arn of the EKS cluster"
  default     = ""
}

variable "cluster_oidc_url" {
  type        = string
  description = "An OIDC endpoint of the EKS cluster"
  default     = ""
}

variable "aws_region" {
  type        = string
  default     = null
  description = "A name of the AWS region (us-central-1, us-west-2 and etc.)"
}

variable "aws_account" {
  description = "AWS Account ID for IAM policy"
  default     = "*"
}

variable "cloudwatch_enabled" {
  default     = false
  description = "Whether to enable CloudWatch output"
}

variable "cloudwatch_match" {
  default     = "'*'"
  description = "The log filter"
}

variable "cloudwatch_log_group_name" {
  default     = "/aws/eks/fluentbit-cloudwatch/logs"
  description = "The name of the CloudWatch Log Group that you want log records sent to"
}

variable "cloudwatch_log_stream_name" {
  default     = ""
  description = "The name of the CloudWatch Log Stream that you want log records sent to."
}

variable "cloudwatch_log_stream_prefix" {
  default     = "fluentbit-"
  description = "Prefix for the Log Stream name"
}

variable "cloudwatch_log_key" {
  default     = ""
  description = "Log record key value of which will be sent to CloudWatch. By default whole message will be sent"
}

variable "cloudwatch_log_format" {
  default     = ""
  description = "Format of the log data"
}

variable "cloudwatch_cross_account_role_arn" {
  default     = ""
  description = "ARN of an IAM role to assume (cross-account access)"
}

variable "cloudwatch_auto_create_group" {
  default     = true
  description = "Whether to automatically create the log group"
}

variable "cloudwatch_endpoint" {
  default     = ""
  description = "Custom endpoint for the CloudWatch Logs API"
}

variable "cloudwatch_credentials_endpoint" {
  default     = ""
  description = "Custom HTTP endpoint to pull credentials from"
}

variable "firehose_enabled" {
  default     = false
  description = "Whether to enable Firehose output"
}

variable "firehose_match" {
  default     = "'*'"
  description = "The log filter"
}

variable "firehose_delivery_stream" {
  default     = ""
  description = "The name of the delivery stream that you want log records sent to"
}

variable "firehose_data_keys" {
  default     = ""
  description = "Log record key value of which will be sent to Firehose. By default whole message will be sent"
}

variable "firehose_cross_account_role_arn" {
  default     = ""
  description = "ARN of an IAM role to assume (cross-account access)"
}

variable "firehose_endpoint" {
  default     = ""
  description = "Custom endpoint for the Kinesis Firehose API"
}

variable "firehose_time_key" {
  default     = false
  description = "Whether to add the timestamp to the record under this key"
}

variable "firehose_time_key_format" {
  default     = ""
  description = "Strftime compliant format string for the timestamp"
}

variable "kinesis_enabled" {
  default     = false
  description = "Whether to enable Kinesis output"
}

variable "kinesis_match" {
  default     = "'*'"
  description = "The log filter"
}

variable "kinesis_stream" {
  default     = ""
  description = "The name of the Kinesis Data Stream that you want log records sent to"
}

variable "kinesis_partition_key" {
  default     = "container_name"
  description = "A partition key is used to group data by shard within a stream"
}

variable "kinesis_append_new_line" {
  default     = false
  description = "Whether to add newline after each log record"
}

variable "kinesis_data_keys" {
  default     = ""
  description = "Log record key value of which will be sent to Firehose. By default whole message will be sent"
}

variable "kinesis_cross_account_role_arn" {
  default     = ""
  description = "ARN of an IAM role to assume (cross-account access)"
}

variable "kinesis_endpoint" {
  default     = ""
  description = "Custom endpoint for the Kinesis Streams API"
}

variable "kinesis_sts_endpoint" {
  default     = ""
  description = "Custom endpoint for the STS API. Used to assume your custom role provided with kinesis_role_arn variable"
}

variable "kinesis_time_key" {
  default     = false
  description = "Whether to add the timestamp to the record"
}

variable "kinesis_time_key_format" {
  default     = ""
  description = "Strftime compliant format string for the timestamp"
}

variable "kinesis_compression" {
  default     = ""
  description = "Setting compression to zlib will enable zlib compression of each record"
}

variable "kinesis_aggregation" {
  default     = false
  description = "Setting aggregation to true will enable KPL aggregation of records sent to Kinesis. This feature isn't compatible with the partitionKey feature"
}

variable "kinesis_experimental_concurrency" {
  default = ""
}
variable "kinesis_experimental_concurrency_retries" {
  default = ""
}

variable "elastic_search_enabled" {
  default     = false
  description = "Whether to enable ElasticSearch output"
}

variable "elastic_match" {
  default     = "'*'"
  description = "The logs filter"
}

variable "elastic_host" {
  default     = ""
  description = "The url of the Elastic Search endpoint you want log records sent to"
}

variable "elastic_aws_auth" {
  default     = "On"
  description = "Whether to enable AWS Sigv4 Authentication for Amazon ElasticSearch Service"
}

variable "elastic_tls" {
  default     = "On"
  description = "Whether to enable TLS support"
}

variable "elastic_port" {
  default     = ""
  description = "TCP Port of the target service"
}

variable "elastic_retry_limit" {
  default     = 1
  description = "Integer value to set the maximum number of retries allowed"
}

variable "daemon_set_resources_limits_cpu" {
  default = "500m"
}

variable "daemon_set_resources_limits_memory" {
  default = "500Mi"
}

variable "daemon_set_resources_requests_cpu" {
  default = "500m"
}

variable "daemon_set_resources_requests_memory" {
  default = "500Mi"
}

variable "service_account_auto_create" {
  default     = true
  description = "Whether a new service account should be created"
}

variable "service_account_name" {
  default     = "aws-for-fluent-bit"
  description = "Service account name"
}
