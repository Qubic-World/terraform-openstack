terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  user_id     = var.user_id
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password    = var.password
  region      = var.region
}

locals {
  qiner_installer     = "qiner_installer.sh"
  ssh_public          = file(var.ssh_public_key_path)
  ssh_private         = file(var.ssh_private_key_path)
  network_router_name = "qiner_nat_${var.network_external_name}"

}

#=========== SSH ==============

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.ssh_name
  region     = var.region
  public_key = local.ssh_public
}

#=========== Network ==============

# External network
data "openstack_networking_network_v2" "qiner_external_network" {
  name = var.network_external_name
}

#=========== Group ==============

# Creating instances on different machines
resource "openstack_compute_servergroup_v2" "qiner_server_group" {
  name     = "qiner-group"
  policies = ["soft-anti-affinity"]
}

#=========== Server ==============

data "openstack_images_image_v2" "ubuntu_image" {
  most_recent = true
  visibility  = "public"
  name        = "Ubuntu 22.04 LTS 64-bit"
}

resource "random_string" "random_name_server" {
  length  = 5
  special = false
}

resource "random_string" "random_password" {
  length  = 18
  special = true
}

resource "openstack_compute_flavor_v2" "flavor_server" {
  name      = "qiner-${var.instance_cpus}-selectel${random_string.random_name_server.result}"
  ram       = var.instance_ram
  vcpus     = var.instance_cpus
  disk      = "0"
  is_public = "false"
  lifecycle {
    create_before_destroy = true
  }
}

resource "openstack_blockstorage_volume_v3" "volume_server" {
  count = var.instance_count

  name                 = "volume-for-server1"
  size                 = "8"
  image_id             = data.openstack_images_image_v2.ubuntu_image.id
  volume_type          = var.volume_type
  availability_zone    = var.az_zone
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_compute_instance_v2" "qiner_instance" {
  count = var.instance_count

  name              = "qiner-${openstack_compute_flavor_v2.flavor_server.vcpus}-selectel_${count.index}"
  flavor_id         = openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.keypair.id
  availability_zone = var.az_zone
  admin_pass        = random_string.random_password

  network {
    uuid = data.openstack_networking_network_v2.qiner_external_network.id
  }

  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_server[count.index].id
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }

  lifecycle {
    ignore_changes = [image_id]
  }

  scheduler_hints {
    group = openstack_compute_servergroup_v2.qiner_server_group.id
  }

  # Preemptible server
  tags = [
    "preemptible"
  ]
}

resource "null_resource" "provision" {
  count = var.instance_count

  connection {
    type        = "ssh"
    host        = openstack_compute_instance_v2.qiner_instance[count.index].access_ip_v4
    user        = var.ssh_user_name
    private_key = local.ssh_private
  }

  provisioner "file" {
    source      = "./scripts/${local.qiner_installer}"
    destination = "/tmp/${local.qiner_installer}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/${local.qiner_installer}",
      "sudo /tmp/${local.qiner_installer}",
      "sudo rm /tmp/${local.qiner_installer}"
    ]
  }
}
