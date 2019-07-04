resource "aws_globalaccelerator_endpoint_group" "ga" {
  listener_arn = var.ga_listener
  health_check_interval_seconds = 10
  health_check_path = "/health"
  health_check_protocol = "HTTP"
  threshold_count = 2

  endpoint_configuration {
    endpoint_id = aws_alb.alb.arn
    weight      = 100
  }
}