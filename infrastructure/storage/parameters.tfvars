# Namespace of ArmoniK storage
namespace = "armonik-storage"

# Storage resources to be created
# Warning: the allowed storage for ArmoniK are defined in:
# "../../modules/needed-storage/storage_for_each_armonik_data.tf"
storage = ["MongoDB", "Amqp", "Redis", "AWS_EBS"]

# Kubernetes secrets for storage
storage_kubernetes_secrets = {
  mongodb  = "mongodb-storage-secret"
  redis    = "redis-storage-secret"
  activemq = "activemq-storage-secret"
}