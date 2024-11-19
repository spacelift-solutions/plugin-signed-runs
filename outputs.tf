locals {
  stack_ids = [for k, _ in var.stacks : k]

  init_policy_workerpool_userdata = <<-EOT
echo "${base64encode(templatefile("${path.module}/init_policy.tpl.rego", { SECRET : var.spacelift_run_signature_secret, STACKS : jsonencode(local.stack_ids) }))}" | base64 -d > $HOME/init_policy.rego
export SPACELIFT_LAUNCHER_RUN_INITIALIZATION_POLICY=$HOME/init_policy.rego
EOT
}

output "initialization_policy" {
  sensitive = true
  value     = local.init_policy_workerpool_userdata
}