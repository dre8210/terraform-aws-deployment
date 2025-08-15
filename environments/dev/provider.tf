terraform {

  backend "s3" {
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}



