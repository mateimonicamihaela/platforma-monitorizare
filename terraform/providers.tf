provider "aws" {
  region     = "eu-central-1"
  access_key = "test"
  secret_key = "test"

  # Evită încercările de validare în AWS real
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # S3 path-style (compatibilitate LocalStack)
  s3_use_path_style = true

  # Direcționează TOATE serviciile folosite către LocalStack
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"

  }
}
