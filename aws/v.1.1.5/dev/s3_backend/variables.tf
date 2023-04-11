#########################
# Common variable block #
#########################

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The region where AWS operations will take place"
}

variable "env_name" {
  type        = string
  default     = "usw201"
  description = "Name to be used on all the resources as identifier"
}

variable "env_class" {
  type        = string
  default     = "dev"
  description = "Name to be used on all the resources as identifier"
}

###################################
# S3 remote state variables block #
###################################
variable "create_dynamodb_lock_table" {
  default     = true
  description = "Boolean:  If you have a dynamoDB table already, use that one, else make this true and one will be created"
}

variable "create_s3_bucket" {
  default     = true
  description = "Boolean.  If you have an S3 bucket already, use that one, else make this true and one will be created"
}

variable "s3_bucket_name" {
  type        = string
  default     = "terraform-state-bucket"
  description = "Name of S3 bucket prepared to hold your terraform state(s)"
}

variable "dynamodb_state_table_name" {
  type        = string
  default     = "backend_tf_lock"
  description = "Name of dynamoDB table to use for state locking"
}

