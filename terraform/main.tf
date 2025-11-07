# 1) Bucket S3 pentru artefacte (NU pentru state; state-ul e în backend)
resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_name
  tags   = local.tags_comune
}

# 2) Încărcăm cheie SSH publică ca aws_key_pair
data "local_file" "ssh_pub" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "monitor_key" {
  key_name   = "monitor-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  tags       = local.tags_comune
}

# 3) Grup de securitate minimal (LocalStack nu validează cu strictețe, dar păstrăm corect)
resource "aws_security_group" "monitor_sg" {
  name        = "monitoring-sg"
  description = "Acces SSH & HTTP pentru platforma-monitorizare (simulat)"
  vpc_id      = null # în LocalStack, poți omite sau pune un VPC default simulat

  # Ingres SSH (22)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingres HTTP (80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egres total
  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags_comune
}

# 4) Instanță EC2 simulată
resource "aws_instance" "monitor_vm" {
  ami                         = local.localstack_ami
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.monitor_key.key_name
  vpc_security_group_ids      = [aws_security_group.monitor_sg.id]
  associate_public_ip_address = true

  tags = merge(local.tags_comune, {
    Name = var.instance_name
  })
}
