# Create the user-data for the Nomad server
data "template_file" "server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    nomad_version = "${var.nomad_version}"
  }
}

# Create the user-data for the Consul server
data "template_file" "agent" {
  count    = "${var.agents}"
  template = "${file("${path.module}/templates/nomad.sh.tpl")}"

  vars {
    nomad_version = "${var.nomad_version}"
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
