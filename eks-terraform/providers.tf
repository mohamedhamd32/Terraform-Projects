provider "aws" {
  region = var.region

  # Tags applied to every resource Terraform creates (useful for cost tracking).
  default_tags {
    tags = merge(
      {
        Project   = var.cluster_name
        ManagedBy = "terraform"
      },
      var.tags
    )
  }
}
