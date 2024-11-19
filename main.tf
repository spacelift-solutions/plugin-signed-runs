locals {
  stacks = {
    for k, v in var.stacks : k => {
      stack_id            = v.stack_id
      use_custom_workflow = v.use_custom_workflow != null ? v.use_custom_workflow : false
      path                = v.custom_path != null ? v.custom_path : data.spacelift_stack.this[k].project_root
    }
  }
}

data "spacelift_stack" "this" {
  for_each = local.stacks

  stack_id = each.value.stack_id
}

resource "spacelift_policy" "this" {
  name = var.name
  type = "GIT_PUSH"
  body = file("${path.module}/push_policy.rego")

  space_id = var.space
}

resource "spacelift_policy_attachment" "this" {
  for_each = local.stacks

  policy_id = spacelift_policy.this.id
  stack_id  = each.value.stack_id
}

resource "github_actions_secret" "api_endpoint" {
  for_each = local.stacks

  repository      = data.spacelift_stack.this[each.key].repository
  secret_name     = "SPACELIFT_API_KEY_ENDPOINT"
  plaintext_value = var.spacelift_api_endpoint
}

resource "github_actions_secret" "api_key_id" {
  for_each = local.stacks

  repository      = data.spacelift_stack.this[each.key].repository
  secret_name     = "SPACELIFT_API_KEY_ID"
  plaintext_value = var.spacelift_api_key_id
}

resource "github_actions_secret" "api_key_secret" {
  for_each = local.stacks

  repository      = data.spacelift_stack.this[each.key].repository
  secret_name     = "SPACELIFT_API_KEY_SECRET"
  plaintext_value = var.spacelift_api_key_secret
}

resource "github_actions_secret" "run_signature_secret" {
  for_each = local.stacks

  repository      = data.spacelift_stack.this[each.key].repository
  secret_name     = "SPACELIFT_RUN_SIGNATURE_SECRET"
  plaintext_value = var.spacelift_run_signature_secret
}

resource "github_actions_secret" "stack_ids" {
  for_each = local.stacks

  repository      = data.spacelift_stack.this[each.key].repository
  secret_name     = "SPACELIFT_STACK_ID"
  plaintext_value = jsonencode(each.key)
}

resource "github_repository_file" "workflow" {
  for_each = { for k, v in local.stacks : k => v if v.use_custom_workflow == false }

  repository = data.spacelift_stack.this[each.key].repository
  file       = ".github/workflows/spacelift-signed-run-${trim(replace(replace(v.path, "*", ""), "/", "_"), "_")}.yaml"
  content = templatefile("${path.module}/workflow.tpl.yaml", {
    PATH : v.path,
    STACK_ID : each.value.stack_id
  })
}