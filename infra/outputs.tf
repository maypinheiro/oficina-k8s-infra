output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "cluster_security_group_id" { value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id }
output "lambda_security_group_id" { value = aws_security_group.lambda.id }
output "vpc_link_security_group_id" { value = aws_security_group.vpc_link.id }
output "api_repository_url" { value = aws_ecr_repository.api.repository_url }

output "configure_kubectl_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}"
}
