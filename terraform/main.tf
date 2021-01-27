module "eks" {
  source                                       = "terraform-aws-modules/eks/aws"
  version                                      = "4.0.2"
  cluster_name                                 = "${var.cluster_name}"
  cluster_version                              = "${var.cluster_version}"
  subnets                                      = "${split(",", var.subnets)}"
  worker_group_count                           = "${var.worker_group_count}"
  worker_create_security_group                 = false
  worker_security_group_id                     = "${aws_security_group.workers.id}"
  worker_additional_security_group_ids         = "${compact(concat(list(aws_security_group.workers.id), split(",", var.worker_additional_security_group_ids)))}"
  worker_group_launch_template_count           = "${var.worker_group_launch_template_count}"
  worker_groups_launch_template                = "${var.worker_groups_launch_template}"
  kubeconfig_aws_authenticator_command         = "${var.kubeconfig_aws_authenticator_command}"
  kubeconfig_aws_authenticator_additional_args = "${var.kubeconfig_aws_authenticator_additional_args}"
  kubeconfig_aws_authenticator_env_variables   = "${var.kubeconfig_aws_authenticator_env_variables}"
  config_output_path                           = "${var.config_output_path}"
  map_roles                                    = "${var.map_roles}"
  map_roles_count                              = "${var.map_roles_count}"
  map_users                                    = "${var.map_users}"
  map_users_count                              = "${var.map_users_count}"
  cluster_endpoint_private_access              = "${var.cluster_endpoint_private_access}"
  cluster_endpoint_public_access               = "${var.cluster_endpoint_public_access}"
  workers_additional_policies_count            = "1"
  workers_additional_policies                  = ["${aws_iam_policy.additional_policy.arn}"]

  tags = "${
    map(
     "Name", "${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
     "Team", "${var.team_tag}",
     "Environment", "${var.environment_tag}",
     "Service", "${var.service_tag}",
     "Role", "eks"
    )
  }"

  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group" "workers" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${var.vpc_id}"
  tags = "${map(
     "Name", "${var.cluster_name}-eks_worker_sg",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
     "Team", "${var.team_tag}",
     "Environment", "${var.environment_tag}",
     "Service", "${var.service_tag}",
     "Role", "eks",
  )}"
}


resource "aws_security_group_rule" "workers_egress_cdir" {
  security_group_id = "${aws_security_group.workers.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
    description       = "Allow egress to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${module.eks.cluster_security_group_id}"
  from_port                = "1025"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${module.eks.cluster_security_group_id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_pods" {
  description              = "Allow worker machines to talk to each other"
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-ssh" {
  count                    = "${length(var.mgmt_sg_ids)}"
  description              = "Allow ssh access from mgmt sg group"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${module.eks.worker_security_group_id}"
  source_security_group_id = "${var.mgmt_sg_ids[count.index]}"
  to_port                  = 22
  type                     = "ingress"
}
