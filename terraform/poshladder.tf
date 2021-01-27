resource "aws_security_group" "poshladder-alb" {
  count = "${var.sg_alb_poshladder > 0 ? 1 : 0 }"
  name_prefix = "${var.cluster_name}"
  description = "Security group for ALB ingress on 443"
  vpc_id      = "${var.vpc_id}"
  tags = "${map(
     "Name", "${var.cluster_name}-eks_poshladder-alb_sg",
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

resource "aws_security_group_rule" "poshladder-alb_egress_cdir" {
  count = "${var.sg_alb_poshladder > 0 ? 1 : 0 }"
  security_group_id = "${aws_security_group.poshladder-alb.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "poshladder-alb_ingress_https" {
  count = "${var.sg_alb_poshladder > 0 ? 1 : 0 }"
  description              = "Request Https access from anywhere"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.poshladder-alb.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "poshladder-alb_ingress_http" {
  count = "${var.sg_alb_poshladder > 0 ? 1 : 0 }"
  description              = "Request Https access from anywhere"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.poshladder-alb.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 80
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-poshladder-alb" {
  count = "${var.sg_alb_poshladder > 0 ? 1 : 0 }"
  description              = "Allow ssh access from poshladder-alb"
  from_port                = 4000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.poshladder-alb.id}"
  to_port                  = 4000
  type                     = "ingress"
}
