resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.name_prefix}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  container_definitions = file("./app.json")
  family                = "${var.name_prefix}-ecs-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "ecs-service" {
  name = "${var.name_prefix}-ecs-service"
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 2
  scheduling_strategy = "REPLICA"

  # 50 percent must be healthy during deploys
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.ecs-task-definition.family
    container_port   = 8080
  }

  network_configuration {
    subnets          = [aws_subnet.vpc_subnet_1, aws_subnet.vpc_subnet_2]
    assign_public_ip = true
    security_groups = [aws_security_group.service_security_group.id]
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

# will be used in the ecs cluster
resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-005b753c07ecef59f"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_sg.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.name_prefix}-ecs-cluster >> /etc/ecs/ecs.config"
  instance_type        = var.ec2_instance_type
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                 = "${var.name_prefix}-ecs-asg"
  vpc_zone_identifier  = [aws_subnet.vpc_subnet_2, aws_subnet.vpc_subnet_1]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = var.desired_capacity
  min_size                  = var.min_cluster_size
  max_size                  = var.max_cluster_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.ecs-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
