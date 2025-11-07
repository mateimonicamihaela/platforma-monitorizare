locals {
  # AMI fictivă pentru LocalStack (EC2 din LocalStack nu pornește un VM real,
  # dar API-ul este simulat; orice ID de forma ami-xxxxxxxx este acceptat)
  localstack_ami = "ami-12345678"

  tags_comune = {
    proiect = "platforma-monitorizare"
    mediu   = "dev-localstack"
  }
}
