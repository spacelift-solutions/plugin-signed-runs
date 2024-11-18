# Plugin Signed Runs

This module create a Spacelift plugin that signs runs with Spacelift inside GitHub.

## How it works

1. A user pushes a code change to GitHub.
2. Spacelift is notified but ignores the code change push because of the Push policy.
3. The GitHub Action is triggered. It builds a JWT token and signs it with your secret. Then, it triggers a run and passes the signed token as metadata.
4. Spacelift schedules the run onto the private worker pool configured for the stack.
5. The private worker pool launcher evaluates the Initialization policy to verify the signature, that the token has not expired and is associated with the stack and commit for the run.
6. If the token validation succeeds, the launcher starts the worker, and the run gets executed. Otherwise, the worker does not get started, the run is marked as failed, and the reason for the failure is displayed in the Initialization phase logs.


<!-- BEGIN_TF_DOCS -->
## Example

```hcl
module "plugin_sops" {
  source = "spacelift.io/spacelift-solutions/plugin-sops/spacelift"

  # Optional Variables
  name     = "plugin-sops"
  space_id = "root"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the context | `string` | `"plugin_sops"` | no |
| <a name="input_space_id"></a> [space\_id](#input\_space\_id) | ID of the space | `string` | `"root"` | no |
<!-- END_TF_DOCS -->
