# Remote State Backend Configuration
# This configures Terraform to store state in S3 with DynamoDB locking
#
# To use this:
# 1. Create an S3 bucket: aws s3api create-bucket --bucket <bucket-name>
# 2. Create a DynamoDB table: aws dynamodb create-table --table-name terraform-locks \
#    --attribute-definitions AttributeName=LockID,AttributeType=S \
#    --key-schema AttributeName=LockID,KeyType=HASH \
#    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
# 3. Uncomment and fill in the values below

# terraform {
#   backend "s3" {
#     bucket           = "terraform-state-myproject"          # S3 bucket name
#     key              = "prod/infrastructure.tfstate"        # Path in bucket
#     region           = "eu-west-1"                          # AWS region
#     dynamodb_table   = "terraform-locks"                    # DynamoDB table for locking
#     encrypt          = true                                 # Enable encryption
#     skip_credentials_validation = false
#   }
# }

# Alternative: Using a separate backend configuration file (recommended)
# Create backend-config.hcl:
# bucket           = "terraform-state-myproject"
# key              = "prod/infrastructure.tfstate"
# region           = "eu-west-1"
# dynamodb_table   = "terraform-locks"
# encrypt          = true
#
# Then run: terraform init -backend-config=backend-config.hcl
