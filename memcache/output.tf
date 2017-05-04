output "cluster_address" {
  value = "${aws_elasticache_cluster.default.cluster_address}"
}

output "configuration_endpoint" {
  value = "${aws_elasticache_cluster.default.configuration_endpoint}"
}

output "cache_nodes" {
  value = ["${aws_elasticache_cluster.default.cache_nodes}"]
}

output "security_group" {
  value = "${aws_security_group.default.id}"
}
