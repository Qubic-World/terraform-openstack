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
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password    = var.password
  region      = var.region
}

locals {
  qiner_installer = "qiner_installer.sh"
  ssh_public      = file(var.ssh_public_key_path)
  ssh_private     = file(var.ssh_private_key_path)
}

#=========== SSH ==============

resource "openstack_compute_keypair_v2" "keypair" {
  name   = var.ssh_name
  region = var.region
  #  public_key = var.ssh_public_key
  public_key = local.ssh_public
}

#=========== Network ==============

resource "openstack_networking_router_v2" "router_tf" {
  name                = "router_tf"
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

resource "openstack_networking_network_v2" "network_tf" {
}

resource "openstack_networking_subnet_v2" "subnet_tf" {
  network_id = openstack_networking_network_v2.network_tf.id
  name       = "subnet_tf"
  cidr       = var.network_cidr
}

resource "openstack_networking_router_interface_v2" "router_interface_tf" {
  router_id = openstack_networking_router_v2.router_tf.id
  subnet_id = openstack_networking_subnet_v2.subnet_tf.id
}

resource "openstack_networking_floatingip_v2" "fip_tf" {
  pool = "external-network"
}

resource "openstack_compute_floatingip_associate_v2" "fip_tf" {
  count = var.instance_count

  floating_ip = openstack_networking_floatingip_v2.fip_tf.address
  instance_id = openstack_compute_instance_v2.server_tf[count.index].id
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

resource "openstack_compute_flavor_v2" "flavor_server" {
  name      = "qiner-${var.instance_cpus}-selectel${random_string.random_name_server.result}"
  ram       = "65536"
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

resource "openstack_compute_instance_v2" "server_tf" {
  count = var.instance_count

  name              = "qiner-${openstack_compute_flavor_v2.flavor_server.vcpus}-selectel_${count.index}"
  flavor_id         = openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.keypair.id
  availability_zone = var.az_zone

  network {
    uuid = openstack_networking_network_v2.network_tf.id
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

  tags = [
    "preemptible"
  ]
}


resource "null_resource" "provision" {
  count = var.instance_count

  connection {
    type        = "ssh"
    host        = openstack_compute_floatingip_associate_v2.fip_tf[count.index].floating_ip
    user        = var.ssh_user_name
    private_key = local.ssh_private
  }

  provisioner "file" {
    source      = "./scripts/${local.qiner_installer}"
    destination = "/tmp/${local.qiner_installer}"
  }
}