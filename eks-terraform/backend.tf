terraform {
  backend "s3" {
    bucket       = "practice-eks-tfstate-059839071178"
    key          = "eks/practice-eks/terraform.tfstate" 
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3 native locking (Terraform >= 1.10)
  }
}