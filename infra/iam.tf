data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "task_policy" {
  name        = "${var.name_prefix}-task-policy"
  description = "IAM policy for ECS tasks"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect":"Allow",
       "Action":["s3:*"],
       "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.name_prefix}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "${var.name_prefix}-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "task-attach" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.task_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#resource "aws_iam_role" "ecs_agent" {
#  name               = "${var.name_prefix}-ecs-agent"
#  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
#}
#
#resource "aws_iam_instance_profile" "ecs_agent" {
#  name = "${var.name_prefix}-ecs-agent"
#  role = aws_iam_role.ecs_agent.name
#}
