resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# O Learner Lab bloqueia ec2:DescribeInstances por SCP. O nodeadm usa o ID da
# instancia obtido pelo IMDS como nome do Node, eliminando essa chamada durante
# o bootstrap do Amazon Linux 2023.
resource "aws_eks_access_entry" "application_nodes" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.node_role_arn
  type          = "EC2"
}

resource "aws_launch_template" "application_nodes" {
  name_prefix            = "${local.prefix}-application-"
  update_default_version = true

  user_data = base64encode(<<-USERDATA
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="NODEADM"

    --NODEADM
    Content-Type: application/node.eks.aws

    ---
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      featureGates:
        InstanceIdNodeName: true
    --NODEADM--
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.prefix}-application-node"
    }
  }
}

resource "aws_eks_node_group" "application" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.prefix}-application"
  node_role_arn   = var.node_role_arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = var.node_instance_types
  capacity_type   = "ON_DEMAND"

  launch_template {
    id      = aws_launch_template.application_nodes.id
    version = aws_launch_template.application_nodes.latest_version
  }

  scaling_config {
    min_size     = var.node_min_size
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
  }

  update_config { max_unavailable = 1 }

  labels = { workload = "application", environment = var.environment }
  tags = {
    "k8s.io/cluster-autoscaler/enabled"                      = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.this.name}" = "owned"
  }

  depends_on = [aws_eks_access_entry.application_nodes]
}

resource "aws_eks_addon" "core" {
  for_each = toset(["vpc-cni", "coredns", "kube-proxy", "metrics-server"])

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value
  resolve_conflicts_on_update = "PRESERVE"
  depends_on                  = [aws_eks_node_group.application]
}

resource "aws_ecr_repository" "api" {
  name                 = "oficina-api"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}
