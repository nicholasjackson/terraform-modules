# Create a new load balancer
resource "aws_alb" "nomad" {
  name            = "${var.namespace}-nomad"
  internal        = false
  security_groups = ["${aws_security_group.default.id}"]
  subnets         = ["${var.subnets}"]
}

resource "aws_alb" "consul" {
  name            = "${var.namespace}-consul"
  internal        = false
  security_groups = ["${aws_security_group.default.id}"]
  subnets         = ["${var.subnets}"]
}

resource "aws_alb" "fabio" {
  name            = "${var.namespace}-fabio"
  internal        = false
  security_groups = ["${aws_security_group.default.id}"]
  subnets         = ["${var.subnets}"]
}

resource "aws_alb_target_group" "nomad" {
  name     = "${var.namespace}-nomad"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/v1/agent/self"
  }
}

resource "aws_alb_target_group" "consul" {
  name     = "${var.namespace}-consul"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/v1/status/leader"
  }
}

resource "aws_alb_target_group" "fabio" {
  name     = "${var.namespace}-fabio"
  port     = 9999
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/health"
    port = 9998
  }
}

resource "aws_alb_target_group" "ui" {
  name     = "${var.namespace}-ui"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "/nomad"
  }
}

resource "aws_alb_listener" "nomad" {
  load_balancer_arn = "${aws_alb.nomad.arn}"
  port              = "4646"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nomad.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "consul" {
  load_balancer_arn = "${aws_alb.consul.arn}"
  port              = "8500"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "fabio" {
  load_balancer_arn = "${aws_alb.fabio.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.fabio.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "ui" {
  load_balancer_arn = "${aws_alb.fabio.arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ui.arn}"
    type             = "forward"
  }
}
