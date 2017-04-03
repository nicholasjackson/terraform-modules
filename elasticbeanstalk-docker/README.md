# Elasticbeanstalk Docker
Terraform module to create an AWS Elasticbeanstalk application using a Docker container.

## Variables

| Name                    | Type   | Description                                           | Required |
| ----                    | ----   | -----------                                           | -------- | 
| application_name        | String | Name of the application                               | yes      |
| application_description | String | Description for the application                       | yes      |
| application_environment | String | Environment label, e.g. development, production       | yes      |
| application_version     | String | Version label for deployment                          | yes      |
| profile                 | String | Profile for AWS credentials to use                    | yes      |
| docker_image            | String | Fully qualified path for the docker image to deploy   | yes      |
| docker_ports            | List   | Container ports to map to the ELB                     | yes      |
| health_check            | String | Health check URL (relative path)                      | yes      |
| instance_type           | String | AWS instance type to deploy default: t2.micro         | no       |
| autoscaling_maxsize     | String | Maximum instances in the autoscaling group default: 3 | no       |

## Outputs

| Name  | Type   | Description               |
| ----  | ----   | -----------               |
| cname | String | The FQDN for the resource |

## Usage
```terraform
module "elasticbeanstalk" {
  source = "github.com/nicholasjackson/terraform-modules/elasticbeanstalk-docker"

  application_name        = "my application name"
  application_description = "The description for my application"
  application_environment = "development"
  application_version     = "1.0.0"
  profile                 = "default"
  docker_image            = "docker.io/nicholasjackson/testapp"
  docker_tag              = "latest"
  docker_ports            = ["8001"],
  health_check            = "/v1/health"
}

output "elasticbeanstalk_cname" {
  value = "${module.elasticbeanstalk.cname}"
}
```
