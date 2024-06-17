# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "elb_autoscaling_role" {
  name = "elb-autoscaling-role"

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

resource "aws_iam_policy" "elb_autoscaling_policy" {
  name        = "ELB-AutoScaling-Policy"
  description = "Policy to allow Auto Scaling Group to interact with ELB"
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

resource "aws_iam_role_policy_attachment" "elb_autoscaling_attach" {
  role       = aws_iam_role.elb_autoscaling_role.name
  policy_arn = aws_iam_policy.elb_autoscaling_policy.arn
}

resource "aws_iam_instance_profile" "elb_autoscaling_profile" {
  name = "elb-autoscaling-instance-profile"
  role = aws_iam_role.elb_autoscaling_role.name
}