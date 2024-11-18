variable "access" {
  type = map(object({
    repository          = string
    path                = string
    use_custom_workflow = optional(bool)
  }))
}

variable "name" {
  type        = string
  description = "Name of the context"
  default     = "plugin_signed_runs"
}

variable "space" {
  type        = string
  description = "ID of the space the policy will be created in"
  default     = "root"
}

variable "spacelift_api_endpoint" {
  type        = string
  description = "The URL for your Spacelift account (e.g., https://acme.app.spacelift.io/)"
}

variable "spacelift_api_key_id" {
  type        = string
  description = "Spacelift API key ID with admin permissions"
}

variable "spacelift_api_key_secret" {
  type        = string
  description = "Spacelift API key secret with admin permissions"
}

variable "spacelift_run_signature_secret" {
  type        = string
  description = "The secret that will be used to sign the JWT token. It can be any string."
}
