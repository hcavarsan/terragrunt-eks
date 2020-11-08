include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/clusterfrak-dynamics/terraform-kubernetes-addons.git?ref=v5.10.0"
}

locals {
  env                 = yamldecode(file("${find_in_parent_folders("common_tags.yaml")}"))["Env"]
  aws_region          = yamldecode(file("${find_in_parent_folders("common_values.yaml")}"))["aws_region"]
  default_domain_name = yamldecode(file("${find_in_parent_folders("common_values.yaml")}"))["default_domain_name"]
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_id              = "cluster-name"
    cluster_oidc_issuer_url = "https://oidc.eks.sa-east-1.amazonaws.com/id/0000000000000000"
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnets_cidr_blocks = [
      "10.0.0.0/16",
      "192.168.0.0/24"
    ]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
    }
    provider "kubectl" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
      load_config_file       = false
    }
    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
      load_config_file       = false
    }
    provider "helm" {
      version = "~> 1.0"
      kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
        token                  = data.aws_eks_cluster_auth.cluster.token
        load_config_file       = false
      }
    }
    data "aws_eks_cluster" "cluster" {
      name = var.cluster-name
    }
    data "aws_eks_cluster_auth" "cluster" {
      name = var.cluster-name
    }
  EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
    }
  EOF
}

inputs = {

  cluster-name = dependency.eks.outputs.cluster_id

  eks = {
    "cluster_oidc_issuer_url" = dependency.eks.outputs.cluster_oidc_issuer_url
  }

  calico = {
    enabled = false
  }

  alb_ingress = {
    enabled = false
  }

  aws_node_termination_handler = {
    enabled = false
  }

  nginx_ingress = {
    enabled = true
  }

  istio_operator = {
    enabled = false
  }

  cluster_autoscaler = {
    enabled      = false
  }

  external_dns = {
    enabled = false
  }

  cert_manager = {
    enabled                        = false
  }

  metrics_server = {
    enabled       = false
  }

  flux = {
    enabled      = false
  }

  prometheus_operator = {
    enabled       = false
  }

  fluentd_cloudwatch = {
    enabled = false
  }

  aws_fluent_bit = {
    enabled = false
  }

  npd = {
    enabled = false
  }

  sealed_secrets = {
    enabled = false
  }

  cni_metrics_helper = {
    enabled = false
  }

  kong = {
    enabled = false
  }

  keycloak = {
    enabled = false
  }

  karma = {
    enabled      = false
  }
}
