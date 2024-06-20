# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lb_autoscaling_app_role" {
  name = "lb-autoscaling-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lb_autoscaling_app_policy" {
  name        = "LB-AutoScaling-App-Policy"
  description = "Policy to allow Auto Scaling Group to interact with LB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "autoscaling:Describe*",
          "autoscaling:AttachInstances",
          "autoscaling:DetachInstances",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_autoscaling_app_attach" {
  role       = aws_iam_role.lb_autoscaling_app_role.name
  policy_arn = aws_iam_policy.lb_autoscaling_app_policy.arn
}

resource "aws_iam_instance_profile" "lb_autoscaling_app_profile" {
  name = "lb-autoscaling-app-profile"
  role = aws_iam_role.lb_autoscaling_app_role.name
}