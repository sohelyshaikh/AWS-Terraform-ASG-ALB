
locals {
  default_tags = { "Env" = "${terraform.workspace}" }
  name_prefix  = "${terraform.workspace}-Group20-Sohel"
}

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }


  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = merge(
    local.default_tags, { "Name" = "${local.name_prefix}-ALB-TG" }
  )
}


resource "aws_lb" "my-alb" {
  // name     = "my-test-alb"
  internal = false

  security_groups = [
    "${aws_security_group.my-alb-sg.id}",
  ]

  subnets = [
    "${var.subnet1}",
    "${var.subnet2}",
    "${var.subnet3}"
  ]

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  tags = merge(
    local.default_tags,
    { "Name" = "${local.name_prefix}-ALB-TG" }
  )

}

resource "aws_lb_listener" "my-alb-listner" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }

  tags = merge(
    local.default_tags,
    { "Name" = "${local.name_prefix}-ALB-Listner" }
  )

}

resource "aws_security_group" "my-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    protocol  = "tcp"

    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"

    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
  { "Name" = "${local.name_prefix}-ALB-SG" })

}

