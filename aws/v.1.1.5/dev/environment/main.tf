################
# AWS Provider #
################
provider "aws" {
  region      = var.region
  max_retries = 5
}

################
# K8S Provider #
################

provider "kubernetes" {
  config_path = "eks_services_configs/kubeconfig"
}

########################
# Configure S3 backend #
########################
terraform {
  backend "s3" {
    # specify the bucket value in a file with terraform init -backend-config
    # Example
    #   assume-role apse231 terraform init -backend-config=../s3_backend/backend.txt   (for the dev / qc / stg /prod accounts)
    # bucket               = "usw201-terraform-state-bucket"
    workspace_key_prefix = ""
  }
}

##############################################################
# Common composed values shared across the different modules #
##############################################################
locals {
  app_environment_triplet = terraform.workspace
  common_tags = {
    EnvClass    = var.env_class
    Environment = "${var.env_name}.${var.env_class}"
    Owner       = var.env_owner_map[local.app_environment_triplet]
    Terraform   = "true"
  }
  env_name_id  = var.env_name
  env_class_id = var.env_class

  #########################################
  # Generating values for the EKS CLUSTER #
  #########################################

  # Cluster name
  cluster_name = "${var.env_name}-${var.env_class}-eks-cluster"

  # Local VARS for EKS ( LaunchConfigurations and LaunchTemplates )
  worker_groups = [
    {
      ######################################################################
      # This will launch an autoscaling group with only On-Demand instances
      ######################################################################
      instance_type         = lookup(var.eks_instance_type, local.app_environment_triplet)
      key_name              = var.ssh_key_name
      additional_userdata   = "echo foo bar"
      subnets               = join(",", module.vpc.private_subnet_id_list)
      asg_desired_capacity  = var.asg_desired_capacity
      asg_max_size          = var.asg_max_size
      asg_min_size          = var.asg_min_size
      autoscaling_enabled   = var.autoscaling_enabled
      protect_from_scale_in = var.protect_from_scale_in
    },
  ]
  worker_groups_launch_template = [
    {
      ######################################################################
      # This will launch an autoscaling group with only On-Demand instances
      ######################################################################
      instance_type         = lookup(var.eks_instance_type, local.app_environment_triplet)
      key_name              = var.ssh_key_name
      additional_userdata   = "echo foo bar"
      subnets               = join(",", module.vpc.private_subnet_id_list)
      asg_desired_capacity  = var.asg_desired_capacity
      asg_max_size          = var.asg_max_size
      asg_min_size          = var.asg_min_size
      autoscaling_enabled   = var.autoscaling_enabled
      protect_from_scale_in = var.protect_from_scale_in
    },
  ]

  # Node Groups
  node_groups = [
    {
      instance_type         = lookup(var.eks_instance_type, local.app_environment_triplet)
      key_name              = var.ssh_key_name
      root_volume_size      = lookup(var.eks_root_volume, local.app_environment_triplet)
      root_volume_type      = lookup(var.eks_volume_type, local.app_environment_triplet)
      additional_userdata   = null
      subnets               = join(",", module.vpc.private_subnet_id_list)
      name = "${var.env_name}-${var.env_class}-eks-node-group"
      desired_size = (lookup(var.eks_node_group_parameters, local.app_environment_triplet)).desired_size
      max_size = (lookup(var.eks_node_group_parameters, local.app_environment_triplet)).max_size
      min_size = (lookup(var.eks_node_group_parameters, local.app_environment_triplet)).min_size
    }
  ]
}

################
# Creating VPC #
################
# This example module creating VPC, private and public subnets with Internet and NAT Gateways
module "vpc" {
  source                       = "git@github.com:equinor/flowify-terraform-aws-vpc.git?ref=v.0.0.1"
  region                       = var.region
  max_az_count                 = lookup(var.max_az_count_map, local.app_environment_triplet, 2)
  include_nat_gateways         = var.include_nat_gateways
  env_name                     = "${local.env_name_id}-${local.env_class_id}"
  vpc_cidr                     = var.vpc_cidr_map[local.app_environment_triplet]
  enable_dns_hostnames         = var.enable_dns_hostnames
  enable_dns_support           = var.enable_dns_support
  main_route_destination_cidr  = var.main_route_destination_cidr
  common_tags                  = local.common_tags
}

###########################
# Creating Security Group #
###########################

# This module creating a main security group for VPC
module "main_sg" {
  source   = "git@github.com:equinor/flowify-terraform-aws-security-groups.git?ref=v.0.0.1"
  region   = var.region
  name_sg  = "${local.env_class_id}-ec2-main"
  env_name = local.env_name_id
  vpc_id   = module.vpc.vpc_id

  # Ingress
  ingress_rules          = ["tcp-22", "udp-161", "all-icmp"]       # Open ports for (SSH, SNMP, IPV4 ICMP)
  ingress_cidr_blocks    = [module.vpc.vpc_cidr_block] # Access only from VPC subnets
  ingress_rules_from_any = []

  # Egress
  egress_rules        = []
  egress_cidr_blocks  = []
  egress_rules_to_any = ["any"]

  # Tags
  common_tags = local.common_tags
}

#####################
# Creating SSH keys #
#####################
module "key_pair" {
  source      = "git@github.com:equinor/flowify-terraform-aws-key-pair.git?ref=v.0.0.1"
  region      = var.region
  create_keys = "true"

  # List of names the public key material
  public_key_name = ["ops-dev"]
}

#######################
# Networks ACL rulles #
#######################
module "network-acl" {
  source   = "git@github.com:equinor/flowify-terraform-aws-network-acl.git?ref=v.0.0.1"
  region   = var.region
  env_name = local.env_name_id

  # VPC
  vpc_id = module.vpc.vpc_id

  # Subnet IDs
  public_subnet_ids  = module.vpc.public_subnet_id_list
  private_subnet_ids = module.vpc.private_subnet_id_list

  # Turn on/off Network ACLs
  public_dedicated_network_acl  = true
  private_dedicated_network_acl = true

  # Tags
  common_tags = local.common_tags

  # Rules for Public ACLs rules
  public_inbound_acl_rules  = local.public_network_acls["public_inbound"]
  public_outbound_acl_rules = local.public_network_acls["public_outbound"]

  # Rules for Private ACLs rules
  private_inbound_acl_rules  = local.private_network_acls["private_inbound"]
  private_outbound_acl_rules = local.private_network_acls["private_outbound"]
}

# Public inbound ACL rules
locals {
  public_network_acls = {
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "17"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.public_subnet_cidr_list[0]
      },
      {
        rule_number = 103
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.public_subnet_cidr_list[1]
      },
      {
        rule_number = 104
        rule_action = "allow"
        from_port   = 123
        to_port     = 123
        protocol    = "17"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 106
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    # Public outbound ACL rules
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "17"
        cidr_block  = "0.0.0.0/0"
      },      
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.public_subnet_cidr_list[0]
      },
      {
        rule_number = 103
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.public_subnet_cidr_list[1]
      },
      {
        rule_number = 104
        rule_action = "allow"
        from_port   = 123
        to_port     = 123
        protocol    = "17"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 106
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      }
    ]
  }

  # Private inbound ACL rules
  private_network_acls = {
    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "17"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.private_subnet_cidr_list[0]
      },
      {
        rule_number = 103
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.private_subnet_cidr_list[1]
      },
      {
        rule_number = 104
        rule_action = "allow"
        from_port   = 123
        to_port     = 123
        protocol    = "17"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "6"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 106
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "6"
        cidr_block  = module.vpc.vpc_cidr_block
      }
    ]
    # Private outbound ACL rules
    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "6"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "17"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.private_subnet_cidr_list[0]
      },
      {
        rule_number = 103
        rule_action = "allow"
        from_port   = -1
        to_port     = -1
        protocol    = -1
        cidr_block  = module.vpc.private_subnet_cidr_list[1]
      },
      {
        rule_number = 104
        rule_action = "allow"
        from_port   = 123
        to_port     = 123
        protocol    = "17"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 105
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 106
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "6"
        cidr_block  = "0.0.0.0/0"
      }
    ]
  }
}

################################################
# Deploying the EKS cluster in the environment #
################################################

# Deploying the EKS cluster in the environment
module "eks" {
  source                 = "git@github.com:equinor/flowify-terraform-aws-eks.git?ref=v.0.0.2"
  count                  = var.eks_cluster_enabled[local.app_environment_triplet] ? 1 : 0
  env_name               = var.env_name
  env_class              = var.env_class
  region                 = var.region
  cluster_name           = local.cluster_name
  common_tags            = local.common_tags
  subnets                = module.vpc.private_subnet_id_list
  vpc_id                 = module.vpc.vpc_id
  custom_ami             = "true"
  ami_custom_name        = lookup(var.eks_ami_custom_name_map, local.app_environment_triplet)
  ami_custom_owner       = var.ami_custom_owner
  cluster_version        = lookup(var.cluster_version_map, local.app_environment_triplet)
  config_output_path     = var.config_output_path
  metric_server_version  = var.metric_server_version
  map_users              = var.map_users
  map_users_count        = var.map_users_count
  map_roles              = var.map_roles
  map_roles_count        = var.map_roles_count

  cluster_public_access  = var.cluster_public_access
  cluster_private_access = var.cluster_private_access
  allowed_cidr_block     = [module.vpc.vpc_cidr_block]
  ebs_csi_driver_addon_enabled      = "true"

  worker_groups                      = local.worker_groups
  worker_groups_launch_template      = local.worker_groups_launch_template
  worker_group_count                 = lookup(var.worker_group_count_map, local.app_environment_triplet)
  worker_group_launch_template_count = var.worker_group_launch_template_count
  worker_create_security_group       = lookup(var.worker_create_security_group_map, local.app_environment_triplet)

  # EKS Cluster resources
  create_tiller                      = false
  create_metric_server               = false
  create_nginx_ingress_controller    = false

  cluster_autoscaler_version = var.cluster_autoscaler_version
  cluster_autoscaler_image = var.cluster_autoscaler_image

  # Node group
  node_groups = local.node_groups
  eks_node_group_asg_policy_name = "${var.env_name}-${var.env_class}-eks-node-group-policy"
  eks_node_group_role_name = "${var.env_name}-${var.env_class}-eks-node-group"
  eks_node_group_role_policy_document_json = file("./policies/eks-node-group-assume-role-policy.json")
}
