

locals {
  default_tags = { "Env" = "${terraform.workspace}" }
  name_prefix  = "${terraform.workspace}-Group20-Sohel"
}

resource "aws_launch_configuration" "my-launch-config" {
  image_id        = "ami-0c02fb55956c7d316"
  instance_type   = var.instance_type
  security_groups = ["${aws_security_group.my-asg-sg.id}"]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
  
  tags=merge(
  locals.default_tags,
  {"Name"="${locals.name_prefix}-ASG-LaunchConfig"}
  )
  
}



resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.my-launch-config.name}"
  vpc_zone_identifier  = ["${var.subnet1}","${var.subnet2 }"]
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"

  min_size = var.minsize
  max_size = var.maxsize

  
  tags=merge(
  locals.default_tags,
  {"Name"="${locals.name_prefix}-ASG"}
  )
}

resource "aws_security_group" "my-asg-sg" {
  
  vpc_id = "${var.vpc_id}"
  
  ingress{
      from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  }
  egress{
      from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  }
  
  tags=merge(
  locals.default_tags,
  {"Name"="${locals.name_prefix}-ASG-SG"}
  )
}


