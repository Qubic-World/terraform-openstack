# Cloud provider with openstack api and terraform

First, you need to install [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Create two folders `.ssh` and `scripts` and one file 'terraform.tfvars' in the location where the `main.tf` file lies

## .ssh

In this directory there should be two files: `id_rsa` and `id_rsa.pub`, which contains private keys and public keys for access to the created servers

## scripts

Create a file here named `qiner_installer.sh`. Put in it the script that should be executed when creating the server. For example, the script to run the miner

## terraform.tfvars

The `variables.tf` file contains variables that you must give values to in `terraform.tfvars`. If a variable from `variables.tf` has a `default` field and the value is fine for you, you don't have to override it in `terraform.tfvars`

### Example

```hcl
#=========== Openstack ==============

auth_url    = "https://api.selvpc.ru/identity/v3"
domain_name = "34234"
tenant_id   = "43242342"
user_name   = "user_name"
password    = "pswd"
region      = "ru-7"
az_zone     = "ru-7a"

#=========== Volume ==============

volume_type = "fast.ru-7a"

#=========== Network ==============

network_cidr = "192.168.0.0/24"

#=========== Instance ==============

instance_count = 12
instance_cpus  = "32"
instance_ram   = "65536"
```

# Run

```bash
terraform init
terraform apply -auto-approve
```

# Destroy

```bash
terraform destroy -auto-approve
```

# Known issues

If your country is under sanctions, you will need to run VNP before running `terraform init`