# Region
variable "region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
}

# TAG
variable "tag" {
  description = "Tag to prefix the AWS resources"
  type        = string
}

# Account ID
variable "account" {
  description = "Account ID that will have permissions."
  type        = any
}

# Kubernetes cluster name
variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

# VPC
variable "vpc_parameters" {
  description = "Parameters of AWS VPC"
  type        = object({
    name                                            = string
    cidr                                            = string
    private_subnets_cidr                            = list(string)
    public_subnets_cidr                             = list(string)
    enable_private_subnet                           = bool
    flow_log_cloudwatch_log_group_kms_key_id        = string
    flow_log_cloudwatch_log_group_retention_in_days = number
  })
}