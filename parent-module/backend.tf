#  terraform {
#     backend "s3" {
#     bucket         	 = "ojoo-2"
#     key              = "Global/s3/terraform.tfstate"
#     region         	 = "eu-west-2"
#     profile          = "default"
#     dynamodb_table   = "website-dynamodb-table"
#   }
#  }