terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.43, <4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.43, <4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}
