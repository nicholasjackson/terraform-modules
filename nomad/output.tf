output "alb_nomad_dns" {
  value = "${aws_alb.nomad.dns_name}"
}

output "alb_nomad_arn" {
  value = "${aws_alb.nomad.arn}"
}

output "alb_consul_dns" {
  value = "${aws_alb.consul.dns_name}"
}

output "alb_consul_arn" {
  value = "${aws_alb.consul.arn}"
}

output "alb_fabio_dns" {
  value = "${aws_alb.fabio.dns_name}"
}

output "alb_fabio_arn" {
  value = "${aws_alb.fabio.arn}"
}
