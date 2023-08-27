#=========== Selectel ==============

variable "selectel_token" {
  description = "Account token (Selectel API key), it can be obtained by following the API Keys instructions: https://docs.selectel.ru/control-panel-actions/account/api-keys/"
  type        = string
}

#=========== Openstack ==============

variable "auth_url" {
  description = "(Optional; required if cloud is not specified) The Identity authentication URL. If omitted, the OS_AUTH_URL environment variable is used."
  type        = string
}

variable "domain_name" {
  description = "Selectel account number (contract number). You can view it in the control panel in the upper right corner: https://my.selectel.ru/"
  type        = string
}

variable "tenant_id" {
  description = "Cloud platform project ID: https://docs.selectel.ru/cloud/servers/about/projects/"
  type        = string
}

variable "user_name" {
  description = "OpenStack user tied to a cloud platform project: https://docs.selectel.ru/cloud/servers/about/projects/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D1%82%D1%8C-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F"
  type        = string
}

variable "password" {
  description = "OpenStack user password"
  type        = string

}

variable "region" {
  description = "Pool where the infrastructure will be deployed: https://docs.selectel.ru/control-panel-actions/selectel-infrastructure/"
  type        = string
  default = ""
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
  type = string
  default = "qiner_ssh"
}

variable "ssh_user_name" {
  type = string
  default = "root"
}

variable "ssh_private_key_path" {
  type = string
  default = "./.ssh/id_rsa"
}

variable "ssh_public_key_path" {
  type = string
  default = "./.ssh/id_rsa.pub"
}

#=========== Network ==============

variable "network_cidr" {
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