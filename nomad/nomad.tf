# Create the user-data for the Nomad server
data "template_file" "config_consul_client" {
  template = "${file("${path.module}/templates/consul-client.json.tpl")}"

  vars {
    namespace             = "${var.namespace}"
    consul_join_tag_key   = "${var.consul_join_tag_key}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
  }
}

data "template_file" "config_consul_server" {
  template = "${file("${path.module}/templates/consul-server.json.tpl")}"

  vars {
    servers               = "${var.servers}"
    namespace             = "${var.namespace}"
    consul_join_tag_key   = "${var.consul_join_tag_key}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
  }
}

data "template_file" "config_nomad_startup_server" {
  template = "${file("${path.module}/templates/server.hcl.tpl")}"

  vars {
    servers = "${var.servers}"
  }
}

data "template_file" "config_nomad_startup_agent" {
  template = "${file("${path.module}/templates/agent.hcl.tpl")}"
}

data "template_file" "server" {
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    nomad_version  = "${var.nomad_version}"
    nomad_config   = "${data.template_file.config_nomad_startup_server.rendered}"
    consul_config  = "${data.template_file.config_consul_server.rendered}"
  }
}

# Create the user-data for the Consul server
data "template_file" "agent" {
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    nomad_version  = "${var.nomad_version}"
    nomad_config   = "${data.template_file.config_nomad_startup_agent.rendered}"
    consul_config  = "${data.template_file.config_consul_client.rendered}"
  }
}

resource "aws_launch_configuration" "nomad_server" {
  name = "${var.namespace}.nomad-server"

  image_id      = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.nomad.id}"

  iam_instance_profile = "${aws_iam_instance_profile.consul-join.name}"
  security_groups      = ["${aws_security_group.default.id}"]

  user_data = "${data.template_file.server.rendered}"
}

resource "aws_autoscaling_group" "nomad_server" {
  name     = "${var.namespace}.nomad-server"
  max_size = 5
  min_size = "${var.servers}"

  launch_configuration = "${aws_launch_configuration.nomad_server.name}"
  vpc_zone_identifier  = ["${var.subnets}"]

  target_group_arns = ["${aws_alb_target_group.nomad.arn}"]

  tag = {
    key                 = "Name"
    value               = "${var.namespace}-nomad-server"
    propagate_at_launch = true
  }

  tag = {
    key                 = "${var.consul_join_tag_key}"
    value               = "${var.consul_join_tag_value}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "nomad_agent" {
  name = "${var.namespace}.nomad-agent"

  image_id      = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.nomad.id}"

  iam_instance_profile = "${aws_iam_instance_profile.consul-join.name}"
  security_groups      = ["${aws_security_group.default.id}"]

  user_data = "${data.template_file.agent.rendered}"
}

resource "aws_autoscaling_group" "nomad_agent" {
  name     = "${var.namespace}.nomad-agent"
  max_size = 5
  min_size = "${var.agents}"

  target_group_arns = ["${aws_alb_target_group.consul.arn}", "${aws_alb_target_group.fabio.arn}"]

  launch_configuration = "${aws_launch_configuration.nomad_agent.name}"
  vpc_zone_identifier  = ["${var.subnets}"]

  tag = {
    key                 = "Name"
    value               = "${var.namespace}-nomad-agent"
    propagate_at_launch = true
  }
}
