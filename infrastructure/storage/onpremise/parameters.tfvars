# Namespace of ArmoniK storage
namespace = "armonik-storage"

# Storage resources to be created
storage = ["MongoDB", "Amqp", "Redis"]

# MongoDB
mongodb = {
  replicas      = 1
  port          = 27017
  image         = "mongo"
  tag           = "4.4.11"
  secret        = "mongodb-storage-secret"
  node_selector = {}
}

# Parameters for Redis
redis = {
  replicas      = 1
  port          = 6379
  image         = "redis"
  tag           = "bullseye"
  secret        = "redis-storage-secret"
  node_selector = {}
}

# Parameters for ActiveMQ
activemq = {
  replicas      = 1
  port          = [
    { name = "amqp", port = 5672, target_port = 5672, protocol = "TCP" },
    { name = "dashboard", port = 8161, target_port = 8161, protocol = "TCP" },
    { name = "openwire", port = 61616, target_port = 61616, protocol = "TCP" },
    { name = "stomp", port = 61613, target_port = 61613, protocol = "TCP" },
    { name = "mqtt", port = 1883, target_port = 1883, protocol = "TCP" }
  ]
  image         = "symptoma/activemq"
  tag           = "5.16.3"
  secret        = "activemq-storage-secret"
  node_selector = {}
}
