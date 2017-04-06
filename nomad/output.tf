output "alb_nomad" {
  value = "${aws_alb.nomad.dns_name}"
}

output "alb_consul" {
  value = "${aws_alb.consul.dns_name}"
}
