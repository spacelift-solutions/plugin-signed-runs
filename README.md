# Plugin Signed Runs

This module create a Spacelift plugin that signs runs with Spacelift inside GitHub.

## How it works

The module will create the following resource:
  - A push policy inside spacelift
  - An output you can use with a worker pool to pass the appropriate initialization policy to the workers.
    - This initialization policy is written as to not prevent stacks that are not signed from running (stacks not defined in `var.stacks` can still use this workerpool with no issues).
  - For Every `stack` defined in `var.stacks`:
    - We will query for the repository defined in the specified `stack_id`, and we will commit a new workflow to that repository that will trigger a run in Spacelift with SpaceCTL.
      - The workflow will automatically configure the path in the workflow to only trigger based on the project root of the stack.
        - You can change this path with `custom_path` in the stacks variable.
      - You can also use a custom workflow by setting `use_custom_workflow` to `true` in the stacks variable.

1. A user pushes a code change to GitHub.
2. Spacelift is notified but ignores the code change push because of the Push policy.
3. The GitHub Action is triggered. It builds a JWT token and signs it with your secret. Then, it triggers a run and passes the signed token as metadata.
4. Spacelift schedules the run onto the private worker pool configured for the stack.
5. The private worker pool launcher evaluates the Initialization policy to verify the signature, that the token has not expired and is associated with the stack and commit for the run.
6. If the token validation succeeds, the launcher starts the worker, and the run gets executed. Otherwise, the worker does not get started, the run is marked as failed, and the reason for the failure is displayed in the Initialization phase logs.

## Stacks Variable

This variable in the module will control which stacks will be allowed to run signed runs.
The key can be anything, its only used statically in for_each loops.
  - `stack_id`: The stack you want to trigger with signed runs.
  - `custom_path`: Optional. If you want to trigger the stack using a path other than the stacks project root you can set it here.
  - `use_custom_workflow`: Optional. If set to `true`, the module will not create a workflow in github for this stack. You will need to create a custom workflow in the repository.

<!-- BEGIN_TF_DOCS -->
## Example

```hcl
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

  access = {
    # Keys in this object are stack slugs you
    # want to allow ONLY signed runs for
    my-great-stack-slug = {
      repository = "my-opentofu-monorepo"
      path       = "my-great-stack/**"
    }

    my-other-great-stack-slug = {
      repository = "my-opentofu-monorepo"
      path       = "my-other-great-stack/**"
    }
  }
}

module "workerpool_apollorion" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-workerpool-on-ec2?ref=v2.6.2"

  configuration = <<-EOT
    export SPACELIFT_TOKEN="{your_workerpool_config_token}"
    export SPACELIFT_POOL_PRIVATE_KEY="{your_workerpool_private_key}"

    # This line is needed in order to pass the initialization policy to the workers
    ${module.plugin_signed_runs.initialization_policy}
  EOT
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access"></a> [access](#input\_access) | n/a | <pre>map(object({<br/>    repository          = string<br/>    path                = string<br/>    use_custom_workflow = optional(bool)<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the context | `string` | `"plugin_signed_runs"` | no |
| <a name="input_space"></a> [space](#input\_space) | ID of the space the policy will be created in | `string` | `"root"` | no |
| <a name="input_spacelift_api_endpoint"></a> [spacelift\_api\_endpoint](#input\_spacelift\_api\_endpoint) | The URL for your Spacelift account (e.g., https://acme.app.spacelift.io/) | `string` | n/a | yes |
| <a name="input_spacelift_api_key_id"></a> [spacelift\_api\_key\_id](#input\_spacelift\_api\_key\_id) | Spacelift API key ID with admin permissions | `string` | n/a | yes |
| <a name="input_spacelift_api_key_secret"></a> [spacelift\_api\_key\_secret](#input\_spacelift\_api\_key\_secret) | Spacelift API key secret with admin permissions | `string` | n/a | yes |
| <a name="input_spacelift_run_signature_secret"></a> [spacelift\_run\_signature\_secret](#input\_spacelift\_run\_signature\_secret) | The secret that will be used to sign the JWT token. It can be any string. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_initialization_policy"></a> [initialization\_policy](#output\_initialization\_policy) | n/a |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |
| <a name="provider_spacelift"></a> [spacelift](#provider\_spacelift) | >= 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [github_actions_secret.api_endpoint](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.api_key_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.api_key_secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.run_signature_secret](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.stack_ids](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_repository_file.workflow](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [spacelift_policy.this](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/policy) | resource |
| [spacelift_policy_attachment.this](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/policy_attachment) | resource |
<!-- END_TF_DOCS -->
