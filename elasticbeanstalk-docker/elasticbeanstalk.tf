data "template_file" "docker" {
  template = "${file("${path.module}/templates/Dockerrun.aws.json.tpl")}"

  vars {
    docker_tag       = "${var.docker_tag}"
    docker_image     = "${var.docker_image}"
    docker_ports     = "[ ${join(",\n",formatlist("{ \"ContainerPort\": \"%s\" }", var.docker_ports))} ]"
    application_name = "${var.application_name}"
  }
}

data "archive_file" "zip" {
  type = "zip"

  source_content = "${data.template_file.docker.rendered}"

  source_content_filename = "Dockerrun.aws.json"

  output_path = "./Dockerrun.zip"
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.application_name}-beanstalk-deployments"
}

resource "aws_s3_bucket_object" "default" {
  bucket = "${aws_s3_bucket.default.bucket}"
  key    = "Dockerrun"
  source = "./Dockerrun.zip"
  etag   = "${data.archive_file.zip.output_md5}"
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "default" {
  name        = "${var.application_name}"
  description = "${var.application_description}"
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "${var.application_name}-${var.application_version}"
  application = "${var.application_name}"
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.default.id}"
  key         = "${aws_s3_bucket_object.default.id}"

  lifecycle {
    create_before_destroy = true
  }
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "default" {
  name                = "${var.application_name}-${var.application_environment}"
  application         = "${aws_elastic_beanstalk_application.default.name}"
  solution_stack_name = "64bit Amazon Linux 2016.09 v2.5.2 running Docker 1.12.6"
  version_label       = "${aws_elastic_beanstalk_application_version.default.name}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"

    value = "${var.instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"

    value = "${var.autoscaling_maxsize}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.ec2.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.service.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.health_check}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Fixed"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingEnabled"
    value     = "true"
  }
}

output "cname" {
  value = "${aws_elastic_beanstalk_environment.default.cname}"
}
