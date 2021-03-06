resource "aws_lb_target_group" "dt-web-target-group" {
  count = "${var.devteam_web_tg_binding > 0 ? 1 : 0 }"
  name        = "dt-${var.cluster_name}-web-node-tg"
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

########################################################################################################################
resource "aws_lb_target_group" "wallaby-web-target-group" {
  count = "${var.wallaby_web_tg_binding > 0 ? 1 : 0 }"
  name        = "wallaby-web-node-tg"
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

########################################################################################################################
resource "aws_lb_target_group" "qaauto-web-target-group" {
  count = "${var.qaauto_web_tg_binding > 0 ? 1 : 0 }"
  name        = "qaauto-web-node-tg"
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

########################################################################################################################
resource "aws_lb_target_group" "ut-web-target-group" {
  count = "${var.ut_web_tg_binding > 0 ? 1 : 0 }"
  name        = "ut-${var.cluster_name}-web-node-tg"
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

########################################################################################################################