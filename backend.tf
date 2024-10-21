terraform {
  backend "s3" {
    bucket         = "for-infotech123"
    region         = "us-east-2"
    key            = "Sunil12/terraform.tfstate"
    dynamodb_table = "locking"
    encrypt        = true
  }
}