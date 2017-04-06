output "id" {
  value = "${aws_vpc.default.id}"
}

output "security_group" {
  value = "${aws_security_group.default.id}"
}

output "subnets" {
  value = ["${aws_subnet.default.*.id}"]
}
