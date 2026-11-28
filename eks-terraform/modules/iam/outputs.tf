output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role (returned once its policy is attached)."
  value       = aws_iam_role.cluster.arn

  depends_on = [aws_iam_role_policy_attachment.cluster]
}

output "node_role_arn" {
  description = "ARN of the worker node IAM role (returned once its policies are attached)."
  value       = aws_iam_role.node.arn

  depends_on = [aws_iam_role_policy_attachment.node]
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.name
}

output "node_role_name" {
  description = "Name of the worker node IAM role."
  value       = aws_iam_role.node.name
}
