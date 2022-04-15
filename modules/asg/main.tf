

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
              sudo yum update -y
              sudo yum install httpd -y
              myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
              echo "<h1>Welcome to ACS730 Project by Sohel Yousuf Shaikh!!!</h1><h2> My private IP is $myip</h2><br>Built by Terraform!"  >  /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  lifecycle {
    create_before_destroy = true
  }



}



resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.my-launch-config.name
  vpc_zone_identifier  = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"

  min_size = var.minsize
  max_size = var.maxsize


   tag {
    key                 = "Name"
    value               = "${local.name_prefix}-ASG" 
    propagate_at_launch = true
  }
}

resource "aws_security_group" "my-asg-sg" {

  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    security_groups = [var.lb_sg]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    { "Name" = "${local.name_prefix}-ASG-SG" }
  )
}


