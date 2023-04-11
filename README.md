CONTENTS

Author: [Yurii Onuk](https://onuk.org.ua)

---

# General information

## Repository workflow

- All code changes should be made in the branch, named the same as related ticket (e.g., `FLOWIFY-XXXX`)
- *CHANGELOG.md* file have to be updated with an entry of brief description of changes
- *version* file should be updated with new version. It is three digit versioning strategy X.Y.Z (e.g., `10.22.1`), where

  ```plaintext
  X - major changes (without backward compatibility)  
  Y - minor changes (some details or functionality)
  Z - fixes
  ```
- All commits have to be squashed into one with mentioning of ticket number and changes made to the repo (e.g., `[FLOWIFY-XXXX] - Port XX was opened for dev environment`)

## Remote State and Workspaces

Separate terraform [state](https://www.terraform.io/language/state) files are used for each of the environments to avoid collisions, and all these state files are stored in S3 buckets. To ensure this separation, the [workspace](https://www.terraform.io/language/state/workspaces) mechanism is used, in which each state file is stored in a separate terraform workspace, e.g

```shell
❯ aws s3 ls gtv-cse-terraform-state --recursive --human-readable
932.7 KiB apse201/terraform.tfstate
157 Bytes euc101/terraform.tfstate
619.6 KiB terraform.tfstate
937.1 KiB usw201/terraform.tfstate
664.6 KiB usw202/terraform.tfstate
```

The remote state is initialized in the [s3_backend](https://github.com/equinor/flowify-terraform-aws-s3-remote-state) code per environment class only once. It produces a `backend.txt` file which is used to initialize a working directory containing terraform configuration files, e.g.

```shell
terraform init -backend-config=../s3_backend/backend.txt
```
