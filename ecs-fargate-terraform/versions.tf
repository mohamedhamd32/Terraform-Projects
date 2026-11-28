terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # For team use, store state remotely instead of on your laptop:
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "ecs-fargate-demo/terraform.tfstate"
  #   region         = "eu-central-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
