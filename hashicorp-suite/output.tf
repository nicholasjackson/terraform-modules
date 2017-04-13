output "alb_dns" {
  value = "${aws_alb.default.dns_name}"
}

output "alb_arn" {
  value = "${aws_alb.default.arn}"
}
