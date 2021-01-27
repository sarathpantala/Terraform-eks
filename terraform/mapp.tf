resource "aws_security_group" "mapp-alb" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  name_prefix = "${var.cluster_name}"
  description = "Security group for ALB ingress on 443"
  vpc_id      = "${var.vpc_id}"
  tags = "${map(
     "Name", "${var.cluster_name}-eks_mapp-alb_sg",
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

resource "aws_security_group_rule" "mapp-alb_egress_cdir" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  security_group_id = "${aws_security_group.mapp-alb.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "mapp-alb_ingress_https" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  description              = "Request Https access from anywhere"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.mapp-alb.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-node-ingress-mapp-alb" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  description              = "Allow ssh access from mapp-alb"
  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.mapp-alb.id}"
  to_port                  = 3000
  type                     = "ingress"
}

resource "aws_lb_target_group" "mapp-target-group" {
  count = "${var.sg_alb_mapp > 0 ? 1 : 0 }"
  name        = "${var.cluster_name}-mapp-node-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.vpc_id}"
  deregistration_delay = "30"

  health_check {
    path = "/dist/index.html"
    port = 3000
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    interval = 6
    matcher = "200"
  }
}
