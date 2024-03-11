variable "cluster_name" {
  default = "ibt-k8s-cluster"
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "myawesomeapp" {
  name       = "amazon-release"
  repository = "https://mitchxxx.github.io/jan-helm/"
  chart      = "myawesomeapp"
  version    = "0.1.1"
}