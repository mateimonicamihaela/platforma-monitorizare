variable "aws_region" {
  description = "Regiunea AWS folosită în LocalStack"
  type        = string
  default     = "eu-central-1"
}

variable "aws_access_key" {
  description = "Cheie de acces dummy pentru LocalStack"
  type        = string
  default     = "test"
}

variable "aws_secret_key" {
  description = "Cheie secretă dummy pentru LocalStack"
  type        = string
  default     = "test"
}

variable "localstack_endpoint" {
  description = "Endpoint LocalStack (edge)"
  type        = string
  default     = "http://localhost:4566"
}

variable "ssh_public_key_path" {
  description = "Calea către cheia publică SSH ce va fi înregistrată ca aws_key_pair"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_name" {
  description = "Numele instanței EC2"
  type        = string
  default     = "vm-monitoring"
}

variable "bucket_name" {
  description = "Numele bucket-ului S3 pentru artefacte/proiect"
  type        = string
  default     = "platforma-monitorizare-artifacts"
}
