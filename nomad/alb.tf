# Create a new load balancer
resource "aws_alb" "nomad" {
  name            = "${var.namespace}-nomad"
  internal        = false
  security_groups = ["${var.security_groups}"]
  subnets         = ["${var.subnets}"]
}

resource "aws_alb" "consul" {
  name            = "${var.namespace}-consul"
  internal        = false
  security_groups = ["${var.security_groups}"]
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
