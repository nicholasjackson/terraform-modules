variable "application_name" {
  description = "Name of your application"
}

variable "application_description" {
  description = "Sample application based on Elastic Beanstalk & Docker"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
}

variable "application_version" {
  description = "Version number for the application"
}

variable "docker_tag" {
  description = "Tag for the docker image to be deployed"
}

variable "docker_image" {
  description = "Image name for the docker image to be deployed"
}

variable "docker_ports" {
  description = "Docker ports to expose"
  type        = "list"
}

variable "instance_type" {
  description = "Type of the instance to deploy, e.g. t2.micro"
  default     = "t2.micro"
}

variable "autoscaling_maxsize" {
  description = "Maximum size for the autoscaling group"
  default     = "3"
}

variable "health_check" {
  description = "Container endpoint to use for health checks"
}
