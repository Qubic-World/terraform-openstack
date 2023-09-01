#=========== Openstack ==============

variable "auth_url" {
  description = "(Optional; required if cloud is not specified) The Identity authentication URL. If omitted, the OS_AUTH_URL environment variable is used."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "(Optional) The Name of the Domain to scope to (Identity v3). If omitted, the following environment variables are checked (in this order): OS_DOMAIN_NAME"
  type        = string
  default     = ""
}

variable "project_domain_name" {
  description = "The domain name where the project is located. If omitted, the OS_PROJECT_DOMAIN_NAME environment variable is checked"
  type        = string
  default     = ""
}

variable "tenant_name" {
  description = "The Name of the Tenant (Identity v2) or Project (Identity v3) to login with. If omitted, the OS_TENANT_NAME or OS_PROJECT_NAME environment variable are used"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Cloud platform project ID: https://docs.selectel.ru/cloud/servers/about/projects/"
  type        = string
}

variable "user_id" {
  description = "The User ID to login with. If omitted, the OS_USER_ID environment variable is used."
  type        = string
  default     = ""
}

variable "user_name" {
  description = "OpenStack user tied to a cloud platform project: https://docs.selectel.ru/cloud/servers/about/projects/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D1%82%D1%8C-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F"
  type        = string
}

variable "user_domain_name" {
  description = "The domain name where the user is located. If omitted, the OS_USER_DOMAIN_NAME environment variable is checked"
  type        = string
  default     = ""
}

variable "password" {
  description = "OpenStack user password"
  type        = string
}

variable "region" {
  description = "Pool where the infrastructure will be deployed: https://docs.selectel.ru/control-panel-actions/selectel-infrastructure/"
  type        = string
  default     = ""
}

variable "az_zone" {
  description = "Pool segment"
  type        = string
}

#=========== Volume ==============

variable "volume_type" {
  type = string
}

#=========== SSH ==============

variable "ssh_name" {
  type    = string
  default = "qiner_ssh"
}

variable "ssh_user_name" {
  type    = string
  default = "root"
}

variable "ssh_private_key_path" {
  type    = string
  default = "./.ssh/id_rsa"
}

variable "ssh_public_key_path" {
  type    = string
  default = "./.ssh/id_rsa.pub"
}

#=========== Network ==============

variable "network_cidr" {
  type = string
}

variable "network_external_name" {
  type = string
}

#=========== Instance ==============

variable "instance_count" {
  description = "Number of instances to be created"
  type        = number
}

variable "instance_cpus" {
  description = "Number of cores for instances"
  type        = string
}

variable "instance_ram" {
  description = "Number of RAM in MB"
  type        = string
}
