variable "credentials" {
  description = "Path to google cloud credentials file"
}

variable "project" {
  description = "Google cloud project name"
}

variable "region" {
  description = "Google cloud region"
}

variable "k8s_instances" {
  description = "Number of kubernetes instances"
}

variable "k8s_nodes" {
  description = "Number of kubernetes nodes"
}

variable "namespace" {
  description = "Namespace for the application"
}
