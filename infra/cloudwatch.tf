resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.name_prefix}-logs"

  tags = {
    Application = var.name_prefix
  }
}