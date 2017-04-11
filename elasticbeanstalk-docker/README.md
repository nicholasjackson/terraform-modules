# Elasticbeanstalk Docker
Terraform module to create an AWS Elasticbeanstalk application using a Docker container.

## Variables

| Name                    | Type   | Description                                           | Required |
| ----                    | ----   | -----------                                           | -------- | 
| application_name        | String | Name of the application                               | yes      |
| application_description | String | Description for the application                       | yes      |
| application_environment | String | Environment label, e.g. development, production       | yes      |
| application_version     | String | Version label for deployment                          | yes      |
| aws_region              | String | AWS region to deploy to                               | yes      |
| aws_access_key_id       | String | AWS access key                                        | yes      |
| aws_secret_access_key   | String | AWS secret                                            | yes      |
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

  application_name         = "my application name"
  application_description  = "The description for my application"
  application_environment  = "development"
  application_version      = "1.0.0"
  aws_region               = "eu-west-1"
  aws_access_key_id        = "XXXXXXXXXX"
  aws_secret_access_key    = "XXXXXXXXXXX"
  docker_image             = "docker.io/nicholasjackson/testapp"
  docker_tag               = "latest"
  docker_ports             = ["8001"],
  health_check             = "/v1/health"
}

output "elasticbeanstalk_cname" {
  value = "${module.elasticbeanstalk.cname}"
}
```

Rather than hard coding the aws secrets you can use environment variables or variable settings in the terraform state file.

### Environment Variables
### Terraform State
For more info please see: [https://www.terraform.io/docs/configuration/variables.html](https://www.terraform.io/docs/configuration/variables.html#environment-variables)

```terraform
module "elasticbeanstalk" {
  source = "github.com/nicholasjackson/terraform-modules/elasticbeanstalk-docker"

  aws_region = "${TF_VAR_aws_region}"
}
```

### Terraform Variable Files
For more info please see: [https://www.terraform.io/docs/configuration/variables.html](https://www.terraform.io/docs/configuration/variables.html#variable-files)

*terraform.tfvars*
```terraform
aws_region = "eu-west-1"
```

*variables.tf*
```terraform
variable "aws_region" {
  description = "AWS region to create the environment"
}
```

```terraform
module "elasticbeanstalk" {
  source = "github.com/nicholasjackson/terraform-modules/elasticbeanstalk-docker"

  aws_region = "${aws_region}"
}
```
