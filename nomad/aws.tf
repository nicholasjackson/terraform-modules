# Get the list of official Canonical Ubunt 14.04 AMIs
data "aws_ami" "ubuntu-1404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "nomad" {
  key_name   = "${var.namespace}-nomad"
  public_key = "${file("${var.public_key_path}")}"
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "${var.namespace}-nomad-consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "${var.namespace}-nomad-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "${var.namespace}-nomad-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "${var.namespace}-nomad-consul-join"
  roles = ["${aws_iam_role.consul-join.name}"]
}
