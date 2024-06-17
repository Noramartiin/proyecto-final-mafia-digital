# ----------------------------------------------------------------------------------------------------------------------
# AWS LOAD BALANCER CONFIG
# ----------------------------------------------------------------------------------------------------------------------

# Load Balancer & Target Group
resource "aws_lb" "load_balancer" {
  name               = "lb-${var.az_prefix}-${var.app_name}" # No debe tener mas de 32 caracteres
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]

  depends_on = [aws_autoscaling_group.as-ubuntu]
}

resource "aws_lb_target_group" "lb_target" {
  name        = "tg-${var.az_prefix}-${var.app_name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-app.id

  depends_on = [aws_lb.load_balancer]
}

# Listener port 80
resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }

  depends_on        = [aws_lb_target_group.lb_target]
}

# Attachment Load Balancer to Target  Group
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.as-ubuntu.name
  lb_target_group_arn   = aws_lb_target_group.lb_target.arn

  depends_on             = [aws_autoscaling_group.as-ubuntu, aws_lb_target_group.lb_target]
}