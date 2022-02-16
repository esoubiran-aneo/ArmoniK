# prometheus deployment
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
    labels    = {
      app     = "armonik"
      type    = "monitoring"
      service = "prometheus"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "armonik"
        type    = "monitoring"
        service = "prometheus"
      }
    }
    template {
      metadata {
        name      = "prometheus"
        namespace = var.namespace
        labels    = {
          app     = "armonik"
          type    = "monitoring"
          service = "prometheus"
        }
      }
      spec {
        node_selector = var.node_selector
        dynamic toleration {
          for_each = (var.node_selector != {} ? [1] : [])
          content {
            key      = keys(var.node_selector)[0]
            operator = "Equal"
            value    = values(var.node_selector)[0]
            effect   = "NoSchedule"
          }
        }
        container {
          name              = "prometheus"
          image             = "${var.docker_image.prometheus.image}:${var.docker_image.prometheus.tag}"
          image_pull_policy = "IfNotPresent"
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          port {
            name           = "prometheus"
            container_port = 9090
            protocol       = "TCP"
          }
          volume_mount {
            name       = "prometheus-configmap"
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path   = "prometheus.yml"
          }
        }
        volume {
          name = "prometheus-configmap"
          config_map {
            name     = kubernetes_config_map.prometheus_config.metadata.0.name
            optional = false
          }
        }
      }
    }
  }
}

# Kubernetes prometheus service
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = kubernetes_deployment.prometheus.metadata.0.name
    namespace = kubernetes_deployment.prometheus.metadata.0.namespace
    labels    = {
      app     = kubernetes_deployment.prometheus.metadata.0.labels.app
      type    = kubernetes_deployment.prometheus.metadata.0.labels.type
      service = kubernetes_deployment.prometheus.metadata.0.labels.service
    }
  }
  spec {
    type     = var.service_type
    selector = {
      app     = kubernetes_deployment.prometheus.metadata.0.labels.app
      type    = kubernetes_deployment.prometheus.metadata.0.labels.type
      service = kubernetes_deployment.prometheus.metadata.0.labels.service
    }
    port {
      name        = "prometheus"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name   = kubernetes_deployment.prometheus.metadata.0.name
    labels = {
      app     = "armonik"
      type    = "monitoring"
      service = "prometheus"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "endpoints", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    non_resource_urls = ["/metrics", "/metrics/cadvisor", "/metrics/resource", "/metrics/probes"]
    verbs             = ["get"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name   = kubernetes_deployment.prometheus.metadata.0.name
    labels = {
      app     = "armonik"
      type    = "monitoring"
      service = "prometheus"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata.0.name
  }
  # subject {
  #   kind      = "User"
  #   name      = "admin"
  #   api_group = "rbac.authorization.k8s.io"
  # }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.namespace
  }
  # subject {
  #   kind      = "Group"
  #   name      = "system:masters"
  #   api_group = "rbac.authorization.k8s.io"
  # }
}

resource "kubernetes_cluster_role_binding" "prometheus_ns_armonik" {
  metadata {
    name   = "prometheus_ns_armonik"
    labels = {
      app     = "armonik"
      type    = "monitoring"
      service = "prometheus"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.prometheus.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "armonik"
  }
}