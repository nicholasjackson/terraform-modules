variable "aws_region" {
  description = "AWS region to create the environment"
}

variable "aws_zones" {
  description = "List of AWS availability zones"
  type        = "list"
}

variable "profile" {
  description = "AWS profile for account"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "namespace" {
  description = <<EOH
The namespace to create the virtual training lab. This should describe the
training and must be unique to all current trainings. IAM users, workstations,
and resources will be scoped under this namespace.

It is best if you add this to your .tfvars file so you do not need to type
it manually with each run
EOH
}

variable "nomad_version" {
  description = "Version number for nomad"
}

variable "consul_version" {
  description = "Version number for nomad"
}

variable "servers" {
  description = "The number of nomad servers."
}

variable "agents" {
  description = "The number of nomad agents"
}

variable "consul_join_tag_key" {
  description = "AWS Tag to use for consul auto-join"
}

variable "consul_join_tag_value" {
  description = "Value to search for in auto-join tag to use for consul auto-join"
}

variable "public_key_path" {
  description = "The absolute path on disk to the SSH public key."
  default     = "~/.ssh/id_rsa.pub"
}

variable "subnets" {
  description = "A list of subnets to attach the instances to"
  type        = "list"
}

variable "vpc_id" {
  description = "The id of the VPC which the servers are attached to"
}
