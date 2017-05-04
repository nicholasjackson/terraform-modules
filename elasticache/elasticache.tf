resource "aws_security_group" "default" {
  name_prefix = "${var.namespace}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.namespace}-cache-subnet"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_cluster" "default" {
  cluster_id           = "${var.cluster_id}"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  port                 = 11211
  num_cache_nodes      = "${var.nodes}"
  parameter_group_name = "default.memcached1.4"

  subnet_group_name  = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids = ["${aws_security_group.default.id}"]
  az_mode            = "cross-az"
}
