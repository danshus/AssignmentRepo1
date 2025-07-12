# TFLint configuration without AWS plugin (fallback for CI/CD rate limits)

config {
  module = true
  force  = false
}

# Essential Terraform rules only (no AWS plugin)
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Disable strict rules for assignment
rule "terraform_unused_declarations" {
  enabled = false  # Allow unused declarations for learning/testing
}

rule "terraform_naming_convention" {
  enabled = false  # Allow flexible naming for assignment
}

rule "terraform_standard_module_structure" {
  enabled = false  # Allow flexible structure for assignment
} 