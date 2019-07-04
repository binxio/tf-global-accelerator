resource "aws_alb" "alb" {
  subnets         = data.aws_subnet_ids.subnets.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_alb_target_group" "alb" {
  port        = 80
  protocol    = "HTTP"
  target_type = "lambda"

  health_check {
    enabled     = true
    interval    = 10
    path        = "/health"
    timeout     = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
    matcher     = "200"
  }
}

resource "aws_alb_listener" "alb" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb.id
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  vpc_id        = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
