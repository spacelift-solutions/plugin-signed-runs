terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">=1.18.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = "{your_github_token}" # WARNING Sensitive
}

module "plugin_signed_runs" {
  source = "spacelift.io/spacelift-solutions/plugin-signed-runs/spacelift"

  spacelift_api_endpoint         = "https://{your_account}.app.spacelift.io"
  spacelift_api_key_id           = "{your_spacelift_api_key_id}"
  spacelift_api_key_secret       = "{your_spacelift_api_key_secret}"                # WARNING Sensitive
  spacelift_run_signature_secret = "my-super-awesome-secret-that-no-one-will-guess" # WARNING Sensitive

  stacks = {
    my-great-stack = {
      stack_id    = "my-awesome-stack-id"
      custom_path = "my-great-stack/test"
    }

    my-second-great-stack = {
      stack_id            = "my-awesome-second-stack-id"
      use_custom_workflow = true
    }

    my-third-great-stack = {
      stack_id = "my-awesome-third-stack-id"
    }
  }
}

module "workerpooln" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v2.6.2"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="{your_workerpool_config_token}"
    export SPACELIFT_POOL_PRIVATE_KEY="{your_workerpool_private_key}"

    # This line is needed in order to pass the initialization policy to the workers
    ${module.plugin_signed_runs.initialization_policy}
  EOT
}