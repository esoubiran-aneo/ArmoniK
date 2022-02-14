# Profile
profile = "default"

# Region
region = "eu-west-3"

# TAG
tag = "main"

# S3 as shared storage
s3_fs = {
  name                                  = "armonik-s3fs"
  policy                                = ""
  attach_policy                         = false
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  attach_public_policy                  = false
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  kms_key_id                            = ""
  sse_algorithm                         = ""
}

# AWS Elasticache
elasticache = {
  name                        = "armonik-elasticache"
  engine                      = "redis"
  engine_version              = "6.x"
  node_type                   = "cache.r4.large"
  apply_immediately           = true
  multi_az_enabled            = false
  automatic_failover_enabled  = true
  num_cache_clusters          = 2
  preferred_cache_cluster_azs = [] # The order of the availability zones in the list is considered. The first item in the list will be the primary node
  data_tiering_enabled        = false # This parameter must be set to true when using r6gd nodes.
  log_retention_in_days       = 30
  encryption_keys             = {
    kms_key_id     = ""
    log_kms_key_id = ""
  }
}

# MQ parameters
mq = {
  name                    = "armonik-mq"
  engine_type             = "ActiveMQ"
  engine_version          = "5.16.3"
  host_instance_type      = "mq.m5.large"
  apply_immediately       = true
  deployment_mode         = "SINGLE_INSTANCE" # "SINGLE_INSTANCE" | "ACTIVE_STANDBY_MULTI_AZ"
  storage_type            = "efs" # "ebs"
  kms_key_id              = ""
  authentication_strategy = "simple" # "ldap"
  publicly_accessible     = false
}

# MQ Credentials
mq_credentials = {
  password = "MindTheGapOfPassword"
  username = "ExampleUser"
}