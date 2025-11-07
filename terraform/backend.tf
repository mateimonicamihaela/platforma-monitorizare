terraform {
  backend "s3" {
    bucket = "tf-state-platforma-monitorizare"
    key    = "terraform.tfstate"
    region = "eu-central-1"

    # LocalStack
    endpoint                    = "http://localhost:4566"
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    insecure                    = true
  }
}
