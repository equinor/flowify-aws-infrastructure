output "public_subnet_id_list" {
  description = "Public subnets IDs list in VPC"
  value       = [module.vpc.public_subnet_id_list]
}

output "private_subnet_id_list" {
  description = "Private subnets IDs list in VPC"
  value       = [module.vpc.private_subnet_id_list]
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "main_sg_id" {
  value       = module.main_sg.security_group_id
  description = "Common SG ID for VPC"
}

output "public_subnet_cidr_list" {
  value       = [module.vpc.public_subnet_cidr_list]
  description = "Public az subnet CIDR block"
}

output "privat_subnet_cidr_list" {
  value       = [module.vpc.private_subnet_cidr_list]
  description = "Private az subnet CIDR block"
}
