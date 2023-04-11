# General idea

Author: [Yurii Onuk](https://onuk.org.ua)

This approach is intended to simplify the use of the terraform for daily tasks.
The basis of everything is the script `gtv-tf`.

First of all, it includes the use of the pre-installed AWS role switcher together with the terraform.

Secondly, during terraform initialization, it automatically uses the required backend, no need to additionally set the path to it.

And thirdly, when using such commonly used commands as `plan`, `apply` and `destroy`, you don't need to switch to the desired workspace and additionally enter the class name, the environment name, and the region where it is located.

# Running Terraform


To run terraform go into the environment directory `env/CLASS_NAME/ENV_NAME`
and run the linked `gtv-tf` script, e.g.

```shell
cd env/dev/usw201
./gtv-tf init
./gtv-tf plan
./gtv-tf apply
```

Besides, it is possible to pass in any terraform argument to these commands, e.g.

```shell
./gtv-tf plan -no-color -target=module.vpc
```

# Setup a new environment

Create a new environment by calling the `gtv-environments` script, e.g.

```shell
./gtv-environments --add usw201.stage --code-class stage
```

Where `usq201.dev` is the full environment name that is

- `usw2` – AWS us-west-2 region
- `01` – Number of the environment in the region
- `dev` – The profile and default class of the environment

This creates the environment directory and links the required files.

If you need a list of all configured environments just use

```shell
./gtv-environments --list
```
> It requires to install `realpath` utility

This will list the environment names, and the directories they belong to

# Customization

The `gtv-tf` supports customizations for each environment

## Custom backends

To customize which S3 bucket to use edit the environment file `ENV.CLASS_backend.txt` (e.g., `usw201.dev_backend.txt`).
The `gtv-environments` script creates the file and sets the default values.

## Custom variables

The `gtv-environments` script creates the environment file `ENV.CLASS.tfvars` (e.g., `usw201.dev.tfvars`)
that contains the environment name, class, and AWS region. These can be changed from the default values.

## Custom script

You can overwrite how terraform is called for the environment by creating a custom script
with the environment's full name (e.g., `env/dev/usw201/usw201.dev.sh`).
`gtv-tf` will run this script instead of terraform. **Please note the script must call terraform by itself.**
