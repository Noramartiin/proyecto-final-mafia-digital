# ----------------------------------------------------------------------------------------------------------------------
# AWS SECURITY GROUPS
# ----------------------------------------------------------------------------------------------------------------------

# SG- Load Balancer
resource "aws_security_group" "sg_lb" {
  name        = "sg_lb_${var.az_prefix}_${var.app_name}"
  description = "LB - Security Group"
  vpc_id      = aws_vpc.vpc-app.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Habilita el acceso HTTP al puerto 80"
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG- Instancias EC2
resource "aws_security_group" "sg_instance" {
  name        = "sg_instances_${var.az_prefix}_${var.app_name}"
  description = "INSTANCES - Security Group"
  vpc_id      = aws_vpc.vpc-app.id

  ingress {
    description     = "Acceso HTTP"
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.sg_lb.id]
  }

  ingress {
    description = "Acceso ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}