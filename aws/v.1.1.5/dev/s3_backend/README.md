# This configuration creates a S3 bucket and backend config for the usw201 environment.

The TRACT service deploys into AWS using terraform to provide `infrastructure as code` and to manage the state of the deployed resources against the infrastructure definition.

AWS dealer Details:
```
AWS_REGION = usw201

Dev Environment:
  - AWS_PROFILE = usw201
  - AWS_ACCOUNT_NO = 120690318229
  - ENVIRONMENT_TRIPLET = dev
  - TERRAFORM WORKSPACE = dev

QC Environment:
  - AWS_PROFILE = usw201
  - AWS_ACCOUNT_NO = 120690318229
  - ENVIRONMENT_TRIPLET = qc
  - TERRAFORM WORKSPACE = qc

Regression Environment:
  - AWS_PROFILE = usw201
  - AWS_ACCOUNT_NO = 120690318229
  - ENVIRONMENT_TRIPLET = reg
  - TERRAFORM WORKSPACE = reg

Staging Environment:
  - AWS_PROFILE = usw201
  - AWS_ACCOUNT_NO = 120690318229
  - ENVIRONMENT_TRIPLET = stage
  - TERRAFORM WORKSPACE = stage

Production Environment:
  - AWS_PROFILE = usw201
  - AWS_ACCOUNT_NO = 120690318229
  - ENVIRONMENT_TRIPLET = prod
  - TERRAFORM WORKSPACE = prod
```

### Installing Terraform
--------------------
In OSX, install using brew.

``brew install terraform``

Alternately Terraform can be downloaded directly from [www.terraform.io](https://www.terraform.io/)

### AWS Setup
---------------------
Install the aws cli.  Google is your friend.

### Installing and setup `assume-role`
You can find full information via the link: [assume-role](https://github.com/remind101/assume-role)


### Notice
*This guide expects that you already have assume-role installed to handle MFA role assumption and that your aws credentials file
is appropriately configured*

### Creating S3 bucket and getting configuration for backend

S3 bucket and backend configurations will be used for all environments that will be deployed in apt 201. Workspaces will be stored `terraform.state` files in the subfolders for different environment classes (dev, qc, reg, sgate, prod)

for example:
```
usw201-terraform-state-bucket/dev/terraform.state
usw201-terraform-state-bucket/stg/terraform.state
usw201-terraform-state-bucket/prd/terraform.state
```

For quick creation you can using scripts:
```bash
./gtv-tf init
./gtv-tf plan
./gtv-tf apply
./gtv-tf destroy
```

Or run the commands from the console:

```bash
assume-role apse201 terraform init
assume-role apse201 terraform plan
assume-role apse201 terraform apply
assume-role apse201 terraform destroy
```

In result, you will have two outputs:
- First in console

```bash
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = arn:aws:s3:::usw201-terraform-state-bucket
bucket_name = usw201-terraform-state-bucket
bucket_region = us-west-2
dynamodb_table_arn = arn:aws:dynamodb:us-west-2:120690318229:table/usw201_backend_tf_lock
dynamodb_table_name = usw201_backend_tf_lock
```
- Second in backend.txt file:
```bash
bucket         = "usw201-terraform-state-bucket"
acl            = "bucket-owner-full-control"
key            = "terraform.tfstate"
region         = "us-west-2"
encrypt        = "1"
dynamodb_table = "usw201_backend_tf_lock"
``` 