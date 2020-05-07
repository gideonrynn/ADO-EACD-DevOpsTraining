terraform {
  backend "s3" {
    bucket = "as-ado-sbx-tfstate"
    key    = "wildRydes/scd/terraform.tfstate"
    region = "us-east-2"
  }
}

