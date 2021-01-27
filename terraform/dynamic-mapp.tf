resource "aws_lb_target_group" "dt-mapp-target-group" {
  count = "${var.devteam_mapp_tg_binding > 0 ? 1 : 0 }"
  name        = "dt-${var.cluster_name}-mapp-node-tg"
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
resource "aws_lb_target_group" "wallaby-mapp-target-group" {
  count = "${var.wallaby_mapp_tg_binding > 0 ? 1 : 0 }"
  name        = "wallaby-mapp-node-tg"
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
resource "aws_lb_target_group" "qaauto-mapp-target-group" {
  count = "${var.qaauto_mapp_tg_binding > 0 ? 1 : 0 }"
  name        = "qaauto-mapp-node-tg"
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