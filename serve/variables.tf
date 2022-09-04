variable "region" {
  default = "us-east-1"
}

variable "name_prefix" {
  default = "encoder"
}

variable "model-bucket" {
  default = "jj-model"
}

variable "model_key" {
  default = "my-model"
}

variable "desired_count" {
  description = "desired number of tasks to run"
  default     = "1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "ec2_instance_type" {
  description = "ECS cluster instance type"
  default     = "t3.large"
}

variable "max_cluster_size" {
  description = "Maximum number of instances in the cluster"
  default     = 1
}

variable "min_cluster_size" {
  description = "Minimum number of instances in the cluster"
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default     = 1
}
