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

# Define Deployment
resource "kubectl_manifest" "deployment" {
  yaml_body = <<YAML
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: amazon-deployment
    namespace: default
    labels:
      app: amazon-app
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: amazon-app
        tier: frontend
        version: 1.0.0
    template:
      metadata:
        labels:
          app: amazon-app
          tier: frontend
          version: 1.0.0
      spec:
        containers:
        - name: amazon-container
          image: mitchxxx/amazon:21
          ports:
          - containerPort: 3000
YAML
}

# Deploy the Service
resource "kubectl_manifest" "service" {
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: amazon-service
  labels:
    app: amazon-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: amazon-app
YAML
}