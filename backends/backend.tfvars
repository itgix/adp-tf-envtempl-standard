encrypt        = true                //encrypts data
bucket         = "itgix-dev-ew1-terraform-state-backend" //name of s3 bucket
region         = "eu-west-1"        //region
key            = "itgix-dev-ew1-terraform.tfstate" //name of tfstate file
dynamodb_table = "itgix-dev-ew1-terraform-state-backend" //dynamoDB table for state locking 