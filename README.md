# vpc-lambda-as-slash-command-backend

Configuration files building AWS VPC, NAT, Lambda in VPC, and SQS integrated with API Gateway
and an example function receiving slash commands from SQS and handling

## Requirements
- Node.js 10.0.0+
- Terraform 0.11+

## Deploy
```sh
$ npm run build
$ cd terraform
$ terraform init
$ terraform plan --out terraform.tfplan
$ terraform apply terraform.tfplan 
```
