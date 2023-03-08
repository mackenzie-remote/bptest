resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 1

  tags = local.tags
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  cluster_name = local.name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        # You can set a simple string and ECS will create the CloudWatch log group for you
        # or you can create the resource yourself as shown here to better manage retetion, tagging, etc.
        # Embedding it into the module is not trivial and therefore it is externalized
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    # FARGATE = {
    #   default_capacity_provider_strategy = {
    #     weight = 50
    #     base   = 20
    #   }
    # }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "bptest"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu                   = 256
  memory                = 512
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = <<EOF
[
  {
    "name": "bptest",
    "image": "${var.bptest_repo}:${var.bptest_tag}",
    "cpu": 256,
    "memory": 512,
    "command": ["--bucket-name", "${var.bucket_name}", "--add-date-suffix"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
        "awslogs-stream-prefix": "ec2"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = "bptest"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    assign_public_ip = true
    subnets          = [module.vpc.public_subnets.0]
  }
}
