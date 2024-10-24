terraform {
  required_version = ">= 1.5.0"
}

locals {
  document_types = toset(["bombastic", "vexination", "v11y"])
}

variable "availability-zone" {
  type        = string
  default     = "eu-west-1a"
  description = "The AWS availability zone to create RDS resources in. Must be part of the 'region'."
}

variable "environment" {
  type        = string
  default     = "rhtpa"
  description = "An environment, using for tagging and creating a suffix for AWS resources"
}

# Replace with your aws profile or use default 
provider "aws" {
  region  = "eu-west-1"
  profile = "gildub"
}

variable "sso-domain" {
  type = string
  default = "trustification-gildub"
}

variable "app-domain" {
  type = string
  default = "gildub-trust1"
}

variable "admin-email" {
  type = string
  default = "gdubreui@redhat.com"
}

module "trustification" {
  source = "./trustification"
  
  cluster-vpc-id = "vpc-0035505e4eebde7eb" 
  availability-zone = "eu-west-1a"

  admin-email = var.admin-email
  environment = var.environment
  sso-domain = var.sso-domain
  console-url = "https://192.168.121.60"
}
