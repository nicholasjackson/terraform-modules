# Create the user-data for the Consul server
data "template_file" "config_server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul-server.json.tpl")}"

  vars {
    index                 = "${count.index}"
    namespace             = "${var.namespace}"
    servers               = "${var.servers}"
    consul_join_tag_key   = "${var.consul_join_tag_key}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
  }
}

data "template_file" "config_client" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/consul-client.json.tpl")}"

  vars {
    index                 = "${count.index}"
    namespace             = "${var.namespace}"
    consul_join_tag_key   = "${var.consul_join_tag_key}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
  }
}

data "template_file" "server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    version = "${var.consul_version}"
    config  = "${element(data.template_file.config_server.*.rendered, count.index)}"
  }
}

data "template_file" "client" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/consul.sh.tpl")}"

  vars {
    version = "${var.consul_version}"
    config  = "${element(data.template_file.config_client.*.rendered, count.index)}"
  }
}

# Create the Consul cluster
resource "aws_instance" "server" {
  count = "${var.servers}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.consul.id}"

  subnet_id              = "${element(var.subnets,count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${var.security_groups}"]

  tags = "${map(
    "Name", "${var.namespace}-server-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
  )}"

  user_data = "${element(data.template_file.server.*.rendered, count.index)}"
}

resource "aws_instance" "client" {
  count = "${var.clients}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.consul.id}"

  subnet_id              = "${element(var.subnets,count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${var.security_groups}"]

  tags = "${map(
    "Name", "${var.namespace}-client-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
  )}"

  user_data = "${element(data.template_file.client.*.rendered, count.index)}"
}

output "servers" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "clients" {
  value = ["${aws_instance.client.*.public_ip}"]
}
