output "alb_target_group_arn"{
    value = aws_lb_target_group.my-target-group.arn
}

output "lb_sg"{
    value = aws_security_group.my-alb-sg.id
}