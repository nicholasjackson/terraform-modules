# Create the user-data for the Nomad server
data "template_file" "config_consul_client" {
  template = "${file("${path.module}/templates/consul-client.json.tpl")}"

  vars {
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
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    nomad_version  = "${var.nomad_version}"
    nomad_config   = "${data.template_file.config_nomad_startup_server.rendered}"
    consul_config  = "${data.template_file.config_consul_client.rendered}"
  }
}

# Create the user-data for the Consul server
data "template_file" "agent" {
  count    = "${var.agents}"
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    consul_version = "${var.consul_version}"
    nomad_version  = "${var.nomad_version}"
    nomad_config   = "${data.template_file.config_nomad_startup_agent.rendered}"
    consul_config  = "${data.template_file.config_consul_client.rendered}"
  }
}

# Create the Consul cluster
resource "aws_instance" "server" {
  count = "${var.servers}"

  ami           = "${data.aws_ami.ubuntu-1404.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.nomad.id}"

  subnet_id              = "${element(aws_subnet.nomad.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.nomad.id}"]

  tags = "${map(
    "Name", "${var.namespace}-nomad-server-${count.index}"
  )}"

  user_data = "${element(data.template_file.server.*.rendered, count.index)}"
}

resource "aws_instance" "agent" {
  count = "${var.agents}"

  ami           = "${data.aws_ami.ubuntu-1404.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.nomad.id}"

  subnet_id              = "${element(aws_subnet.nomad.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.nomad.id}"]

  tags = "${map(
    "Name", "${var.namespace}-nomad-agent-${count.index}"
  )}"

  user_data = "${element(data.template_file.agent.*.rendered, count.index)}"
}

output "servers" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "agents" {
  value = ["${aws_instance.agent.*.public_ip}"]
}
