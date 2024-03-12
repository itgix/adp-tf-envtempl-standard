encrypt        = true                //encrypts data
bucket         = "itgix-dev-ec1-terraform-state-backend" //name of s3 bucket
region         = "eu-central-1"        //region
key            = "itgix-dev-ec1-terraform.tfstate" //name of tfstate file
dynamodb_table = "itgix-dev-ec1-terraform-state-backend" //dynamoDB table for state locking  