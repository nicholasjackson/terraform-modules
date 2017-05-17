output "id" {
  value = "${aws_vpc.default.id}"
}

output "subnets" {
  value = ["${aws_subnet.default.*.id}"]
}

output "subnet_names" {
  value = ["${aws_subnet.default.*.arn}"]
}
