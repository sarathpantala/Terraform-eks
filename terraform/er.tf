resource "aws_security_group" "er-alb" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for ALB ingress on 80"
  vpc_id      = "${var.vpc_id}"
  tags = "${map(
     "Name", "${var.cluster_name}-eks_er-alb_sg",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
     "Team", "${var.team_tag}",
     "Environment", "${var.environment_tag}",
     "Service", "${var.service_tag}",
     "Role", "eks",
  )}"
  lifecycle {
    ignore_changes = [ "description" ]
  }
}

resource "aws_security_group_rule" "er-alb_egress_cdir" {
  security_group_id = "${aws_security_group.er-alb.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "er-alb_ingress_http" {
  description              = "Request Http access from anywhere"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.er-alb.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 80
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-er-alb" {
  description              = "Allow ssh access from er-alb"
  from_port                = 9294
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.er-alb.id}"
  to_port                  = 9294
  type                     = "ingress"
}
