#########################
# Backend configuration #
#########################

# These values must be changed per environment. Perhaps look these up dynamically one day.

# VPC CIDR
vpc_cidr_map = {
  usw201 = "10.16.48.0/21"
  usw202 = "10.16.56.0/21"
  usw203 = "10.16.72.0/21"
}

key_pair_create_keys_map = {
  usw201 = false
  usw202 = true
  usw203 = false
}

# End of per environment settings

# These values must change per environment type
ssh_key_name = "ops-dev"

# Add environment owner to tags
env_owner_map = {
  usw201 = "DevOps"
  usw202 = "DevOps"
  usw203 = "DevOps"
}

#####################
# VPC configuration #
#####################

# Redefining default values for inputs variables
max_az_count_map = {}

# Enable NAT Gateway per AZ
include_nat_gateways = "true"

# Enable DNS support in VPC
enable_dns_support = "true"

# Enable DNS hostname in VPC
enable_dns_hostnames = "true"

# Route destination CIDR
main_route_destination_cidr = "0.0.0.0/0"

#################################
# Security Groups configuration #
#################################

# Redefining default values for inputs variables
name_sg = "common-dev"

##############################
# Network ACLs configuration #
##############################

# Whether to use dedicated network ACL (not default) and custom rules for public subnets
public_dedicated_network_acl = false

# Whether to use dedicated network ACL (not default) and custom rules for private subnets
private_dedicated_network_acl = true

#######
# EKS #
#######

eks_cluster_enabled = {
  usw201 = true
  usw202 = false
  usw203 = false
}

eks_instance_type = {
  usw201 = "t3.medium"
  usw202 = "r5.xlarge"
  usw203 = "r5.xlarge"
}

eks_root_volume = {
  usw201 = "50"
  usw202 = "50"
  usw203 = "50"
}

eks_volume_type = {
  usw201 = "gp3"
  usw202 = "gp3"
  usw203 = "gp3"
}

eks_ami_custom_name_map = {
  usw201 = "amazon-eks-node-1.24-v20230322"
  usw202 = "amazon-eks-node-1.24-v20230322"
  usw203 = "amazon-eks-node-1.24-v20230322"
}

ami_custom_owner = "602401143452"

cluster_version_map = {
  usw201 = "1.24"
  usw202 = "1.24"
  usw203 = "1.24"
}

# EKS Worker group

worker_group_count_map = {
  usw201 = "0"
  usw202 = "0"
  usw203 = "0"
}

worker_create_security_group_map = {
  usw201 = true
  usw202 = false
  usw203 = false
}

# Node group
eks_node_group_parameters = {
  usw201 = {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  usw202 = {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  usw203 = {
    desired_size = 4
    max_size     = 6
    min_size     = 4
  }
}

# Only one per class IAM deploy role must be created !!!
# It should be created within the first created environment of the class
gtv_deploy_role_create_map = {
  usw201 = true
  usw202 = false
  usw203 = false
}

