terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

# terraform provider section 
provider "aws" {
  # Configure provider via environment variables or override via variables below
  # Recommended: set AWS_REGION and AWS_PROFILE or AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
  region = var.aws_region
  # profile = var.aws_profile
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region to use. Can be overridden with TF_VAR_aws_region or in a tfvars file."
}

variable "msg" {
  type    = string
 
}


# A null_resource that runs a local-exec provisioner to print "Hello World"
resource "null_resource" "hello" {
  # Use a random trigger so it runs when you want; for example, you can change this value to re-run
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Hello, World from DeV branch TerraforM null_resource!'"
  }
}

# Example of using aws provider: a read-only data call (doesn't create resources)
# This is just to demonstrate the aws provider is usable; it's optional.
data "aws_region" "current" {}

output "hello_resource_id" {
  value       = null_resource.hello.id
  description = "ID of the null_resource that ran the hello command."
}

output "aws_region" {
  value       = data.aws_region.current.name
  description = "AWS based region retrieved by the provider (optional)."
}

output "printing_env" {
  value       = var.msg
  description = "Message from the environment-specific variable. new"
}


