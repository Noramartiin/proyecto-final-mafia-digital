# ----------------------------------------------------------------------------------------------------------------------
# AUTOSCALING CONFIG
# ----------------------------------------------------------------------------------------------------------------------

# Instance template
resource "aws_launch_template" "asg-template-t2micro" {
  name_prefix            = "asg-${var.app_name}-t2micro"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.template_key.key_name
  user_data              = filebase64("${path.module}/provision/instance-provision.sh")

  vpc_security_group_ids = [aws_security_group.sg_instance.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.lb_autoscaling_app_profile.name
  }
}

# Key pair
resource "aws_key_pair" "template_key" {
  key_name   = "${var.app_name}-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Auto Scaling Group 
resource "aws_autoscaling_group" "as-ubuntu" {
  vpc_zone_identifier = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3

  launch_template {
    id      = aws_launch_template.asg-template-t2micro.id
    version = aws_launch_template.asg-template-t2micro.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "NODO-${var.app_name}"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.asg-template-t2micro]
}