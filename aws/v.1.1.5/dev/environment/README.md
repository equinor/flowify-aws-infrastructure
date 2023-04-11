# This configuration creates apse201 environment.

The TRACT service deploys into AWS using terraform to provide `infrastructure as code` and to manage the state of the deployed resources against the infrastructure definition.

AWS dealer Details:
```
AWS_REGION = us-west-2

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
Install the aws cli.  Google is your friend. [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

### Installing and setup `assume-role`
You can find full information via the link: [assume-role](https://github.com/remind101/assume-role)


### Notice
*This guide expects that you already have assume-role installed to handle MFA role assumption and that your aws credentials file
is appropriately configured* 
- [multi-factor-authentication](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)
- [assum-role](https://github.com/remind101/assume-role)

Terraform Initialization
----------------------------
Before terraform can be used to manage the aws infrastructure (new, update, destroy) `terraform init` must be performed
to pull down the latest `aws provider` and the modules from git. Note that this must be performed each time a module 
version number changes as well.  This step should not be performed **BEFORE** running the AWS Initial Configuration on 
new AWS user accounts.
 
For dev, qc, reg, cse and prod environments: 
```bash
assume-role usw201 terraform init -backend-config=../s3_backend/backend.txt 
```

or uses script: 
```bash
./gtv-tf init
```

Terraform Workspaces
---------------
You **MUST** set your terrform workspace to the appropriate environment **BEFORE** running an apply or destroy. Failure to 
do this **WILL** cause issues withe the environment and the blame finger will find its way back to you. **CONSIDER YOURSELF WARNED!**

_Note that this will most likely be replaced in a future PR to include helpful scripts to prevent you from accidentally shooting yourself in the foot._

For dev:
```bash
assume-role usw201 terraform workspace new dev
assume-role usw201 terraform workspace select dev
```

For qc:
```bash
assume-role usw201 terraform workspace new qc
assume-role usw201 terraform workspace select qc
```

For reg:
```bash
assume-role usw201 terraform workspace new reg
assume-role usw201 terraform workspace select reg
```

For stage:
```bash
assume-role usw201 terraform workspace new stage
assume-role usw201 terraform workspace select stage
```

For prod:
```bash
assume-role usw201 terraform workspace new prod
assume-role usw201 terraform workspace select prod
```

or uses scripts, they do it automatically:

```bash
./gtv-tf init
./gtv-tf plan
./gtv-tf apply
./gtv-tf destroy
```

Running Terraform
-----------------
Assuming that since you got this for in the document, you want to actually push some changes to AWS and are looking for help..
Great!

Terraform has a handy feature that will compare the existing state stored in the s3 bucket against your local configuration.
This process will output a plan that tells you what changes will be made without actually applying those changes. It is 
recommended that you do this and understand what its telling you **BEFORE** actually pushing your changes. This also has
the added benefit of validating that you do not have any (obvious) configuration issues.

_Note that some modules will display changes no matter what. A good example of this would be any IAM policies as they are
created in memory as documents before they are compared and show up as a change. Another example could be the Elastic beanstalk
application because it attempts to map the settings namespace, key, and value to a existing resource property and fails at it. This does not mean a 
change is or isn't happening, so its recommended that you make sure the plan is presenting your expectation of your changes._

For dev:
```bash
assume-role usw201 terraform plan 
assume-role usw201 terraform apply 
```

or uses scripts, they do it automatically:

```bash
./gtv-tf init
./gtv-tf plan
./gtv-tf apply
./gtv-tf destroy
```

