resource "aws_ecr_repository" "aws-ecr" {
  name = "${var.name_prefix}-ecr"
  tags = {
    Name = "${var.name_prefix}-ecr"
  }
}
