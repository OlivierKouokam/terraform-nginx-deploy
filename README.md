install aws-cli

aws configure

aws configure list

aws s3api create-bucket --bucket tf-state-mini-project


aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --tags Key=Name,Value=TerraformLocks Key=Environment,Value=app

aws ec2 create-key-pair --region us-east-1 --key-name pwd-keypair --query 'KeyMaterial' --output text > pwd-keypair.pem

chmod 400 pwd-keypair.pem

aws ec2 describe-key-pairs
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text

cd app/

terraform init
terraform validate
terraform plan
terraform apply
terraform destroy

aws ec2 delete-key-pair --key-name NOM_DE_TA_CLE

aws s3 rb s3://tf-state-mini-project --force

aws dynamodb delete-table --table-name terraform-state-lock

