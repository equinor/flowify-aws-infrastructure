#########################
# Common variable block #
#########################
variable "region" {
  type        = string
  description = "The region where AWS operations will take place"
}

variable "env_class" {
  type        = string
  description = "The environment class tag that will be added to all taggable resources"
}

variable "env_name" {
  type        = string
  description = "The description that will be applied to the tags for resources created in the vpc configuration"
}

variable "env_owner_map" {
  type        = map(string)
  description = "The environment owner tag that will be added to all taggable resources"
}

variable "ssh_key_name" {
  type        = string
  description = "The ssh key to be used for ec2 instances"
}

############################
# Key pair variables block #
############################
variable "key_pair_create_keys_map" {
  type        = map(string)
  description = "set to true only if this is the first env in this region; set to false for any next env in same region"
}

#######################
# VPC variables block #
#######################
variable "max_az_count_map" {
  type        = map(string)
  description = "The maximum number of availability zones to utilize. Since EIP's and NAT gateways cost money, you many want to limit your usage. A value of 0 will use every available az in the region."
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Either \"true\" or \"false\" to toggle dns hostname support on or off on the vpc connection"
}

variable "enable_dns_support" {
  type        = bool
  description = "Either \"true\" or \"false\" to toggle dns support on or off on the vpc connection"
}

variable "main_route_destination_cidr" {
  type        = string
  description = "The cidr for the outgoing traffic to the internet gateway. By setting this is a more fine grained value, traffic will be dropped by the route."
}

variable "vpc_cidr_map" {
  type        = map(string)
  description = "The internal CIDR for the app VPC connection"
}

variable "include_nat_gateways" {
  type        = bool
  description = "Specifies whether or not nat gateways should be generated in all az's and the private subnet routes using them as their default gateways"
}

###################################
# Security Groups variables block #
###################################

variable "name_sg" {
  type        = string
  description = "Name of security group"
}

#######################
# ACL variables block #
#######################
variable "public_dedicated_network_acl" {
  type        = string
  description = "Whether to use dedicated network ACL (not default) and custom rules for public subnets"
}

variable "private_dedicated_network_acl" {
  type        = string
  description = "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
}

###############
# EKS Cluster #
###############

variable "eks_cluster_enabled" {
  type = map(bool)
  default = {}
  description = "Whether to add an EKS Cluster to the environment configuration"
}

variable "eks_instance_type" {
  type        = map(string)
  default     = {}
  description = "Instance type for EKS Cluster Worker Nodes"
}

variable "eks_root_volume" {
  type        = map(string)
  default     = {}
  description = "Root volume size for EKS Cluster Worker Nodes"
}

variable "eks_volume_type" {
  type        = map(string)
  default     = {}
  description = "The volume type for EKS Cluster Worker Nodes"
}

variable "asg_desired_capacity" {
  type        = string
  description = "Desired worker capacity in the autoscaling group"
  default     = "5"
}

variable "asg_min_size" {
  type        = string
  description = "Minimum worker capacity in the autoscaling group"
  default     = "2"
}

variable "asg_max_size" {
  type        = string
  description = "Maximum worker capacity in the autoscaling group"
  default     = "10"
}

variable "autoscaling_enabled" {
  description = "Autoscaling of worker nodes"
  default     = true
}

variable "protect_from_scale_in" {
  description = "to ensure that cluster-autoscaler is solely responsible for scaling events"
  default     = false
}

variable "eks_ami_custom_name_map" {
  type = map(string)
  description = "AWS EKS worker node AMI"
}

variable "ami_custom_owner" {
  type        = string
  default     = "195572076609"
  description = "Owner ID for custom AMI"
}

variable "cluster_version_map" {
  type        = map(string)
  description = "Kubernetes version to use for the EKS cluster"
}

variable "config_output_path" {
  type        = string
  default     = "./eks_services_configs/"
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Should end in a forward slash `/` ."
}

variable "metric_server_version" {
  type        = string
  default     = "v0.3.5"
  description = "Metric server version"
}

variable "map_users" {
  type = list(any)
  default = [
    {
      user_arn = "arn:aws:iam::707854892645:user/terraform"
      username = "terraform"
      group    = "system:masters"
    },
  ]
  description = "Additional IAM users to add to the aws-auth configmap."
}

variable "cluster_autoscaler_version" {
  type        = string
  default     = "v1.26.2"
  description = "Cluster Autoscaler version"
}

variable "cluster_autoscaler_image" {
  type        = string
  default     = "registry.k8s.io/autoscaling/cluster-autoscaler"
  description = "Docker images for cluster-autoscaler deploy"
}

variable "create_nginx_ingress_controller" {
  type        = bool
  default     = true
  description = "Whether to create the nginx ingress controller"
}

variable "nginx_ingress_controller_image" {
  type        = string
  default     = "nginx/nginx-ingress"
  description = "Docker images for nginx-ingress-controller"
}

variable "nginx_ingress_controller_version" {
  type        = string
  default     = "3.1"
  description = "Nginx ingress controller version"
}

variable "map_users_count" {
  type        = string
  default     = 1
  description = "The count of roles in the map_users list."
}

variable "map_roles" {
  type        = list(any)
  default     = [
    {
      role_arn = "arn:aws:iam::707854892645:role/gtv-eks-deploy-role"
      username = "gtv-deploy-manager"
      group    = "gtv-deploy"
    },
    {
      role_arn = "arn:aws:iam::707854892645:role/gtv-eks-deploy-admin-role"
      username = "gtv-deploy-admin-manager"
      group    = "gtv-deploy-admin"
    }
  ]
  description = "Additional IAM roles to add to the aws-auth configmap."
}

variable "map_roles_count" {
  type        = number
  default     = 2
  description = "The count of roles in the map_roles list."
}

variable "cluster_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
}

variable "cluster_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
}

# EKS Worker group

variable "worker_group_count_map" {
  type        = map(string)
  description = "Default number of workers"
}

variable "worker_group_launch_template_count" {
  default = "0"
}

variable "worker_create_security_group_map" {
  type        = map(bool)
  description = "Whether to create EKS worker security groups"
}

# EKS Node Group

variable "eks_node_group_enabled" {
  type = map(bool)
  description = "Whether to add a node group to the EKS cluster"
  default = {}
}

variable "eks_node_group_parameters" {
  type = map(object({
    desired_size = number
    max_size     = number
    min_size     = number
  }))
  description = "Parameters for EKS Node Group"
  default     = {}
}

# EKS deploy IAM role

variable "gtv_deploy_role_create_map" {
  type        = map(bool)
  description = "Whether to create a gtv-deploy role"
}
