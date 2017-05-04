# AWS Specific variables
variable "aws_region" {
  description = "AWS region to create the environment"
}

variable "aws_access_key_id" {
  description = "AWS access key"
}

variable "aws_secret_access_key" {
  description = "AWS secret"
}

variable "namespace" {
  description = "Default namespace"
}

variable "cluster_id" {
  description = "Id to assign the new cluster"
}

variable "subnets" {
  description = "The name of the subnets to attach the instances to"
  type        = "list"
}

variable "vpc_id" {
  description = "The name of the vpc to attach the instances to"
}

variable "nodes" {
  description = "The number of cache nodes to create in the cluster"
}
