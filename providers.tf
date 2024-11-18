terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">= 0.0.1"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
