terraform {
  required_version = ">=1.2.0, < 2.0.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

variable "cluster_name" {
  default = "ibt-k8s-cluster"
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

# Define Deployment

resource "kubernetes_deployment" "amazon_deployment" {
  metadata {
    name      = "amazone-deployment"
    namespace = "default"
    labels = {
      app     = "amazon-app"
      tier    = "frontend"
      version = "1.0.0"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app     = "amazon-app"
        tier    = "frontend"
        version = "1.0.0"
      }
    }
    template {
      metadata {
        labels = {
          app     = "amazon-app"
          tier    = "frontend"
          version = "1.0.0"
        }
      }
      spec {
        container {
          name  = "amazon-container"
          image = "mitchxxx/amazon:21"
          port {
            container_port = 3000
          }
        }
      }
    }
  }

}

# Define Service

resource "kubernetes_service" "amazon_service" {
  metadata {
    name = "amazon-service"
    labels = {
      app = "amazon-app"
    }
  }
  spec {
    selector = {
      app = "amazon-app"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}