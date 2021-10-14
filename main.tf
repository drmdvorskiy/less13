terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.yc_token
}
#############
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.6.0/24"]
}

resource "yandex_compute_disk" "iscsi_disk" {
name     = "iscsi"
zone     = var.zone
size     = 1
}

######################################################################

resource "yandex_compute_instance" "origin" {
  name = "origin"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_u
    }
  }

    network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_compute_instance" "iscsi" {
  name = "iscsi"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_c
    }
  }

  secondary_disk {
  disk_id = yandex_compute_disk.iscsi_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_compute_instance" "web" {
  count = 3
  name = "web${count.index+1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_c
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_compute_instance" "fe" {
  count = 2
  name = "fe${count.index+1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_u
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

resource "yandex_compute_instance" "db" {
  name = "db"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id_u
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface.0.nat_ip_address
  }
}

#################################################################################
output "external_ip_address_origin" {
  value = yandex_compute_instance.origin.*.network_interface.0.nat_ip_address
}
output "external_ip_address_fe0" {
  value = yandex_compute_instance.fe[0].network_interface.0.nat_ip_address
}
output "external_ip_address_fe1" {
  value = yandex_compute_instance.fe[1].network_interface.0.nat_ip_address
}
output "external_ip_address_web0" {
  value = yandex_compute_instance.web[0].network_interface.0.nat_ip_address
}
output "external_ip_address_web1" {
  value = yandex_compute_instance.web[1].network_interface.0.nat_ip_address
}
output "external_ip_address_web2" {
  value = yandex_compute_instance.web[2].network_interface.0.nat_ip_address
}
output "external_ip_address_db" {
  value = yandex_compute_instance.db.*.network_interface.0.nat_ip_address
}
output "external_ip_address_iscsi" {
  value = yandex_compute_instance.iscsi.*.network_interface.0.nat_ip_address
}
##
output "internal_ip_address_origin" {
  value = yandex_compute_instance.origin.*.network_interface.0.ip_address
}
output "internal_ip_address_fe0" {
  value = yandex_compute_instance.fe[0].network_interface.0.ip_address
}
output "internal_ip_address_fe1" {
  value = yandex_compute_instance.fe[1].network_interface.0.ip_address
}
output "internal_ip_address_web0" {
  value = yandex_compute_instance.web[0].network_interface.0.ip_address
}
output "internal_ip_address_web1" {
  value = yandex_compute_instance.web[1].network_interface.0.ip_address
}
output "internal_ip_address_web2" {
  value = yandex_compute_instance.web[2].network_interface.0.ip_address
}
output "internal_ip_address_db" {
  value = yandex_compute_instance.db.*.network_interface.0.ip_address
}
output "internal_ip_address_iscsi" {
  value = yandex_compute_instance.iscsi.*.network_interface.0.ip_address
}
###############################

output "hostname_web0" {
  value = yandex_compute_instance.web[0].hostname
}
output "hostname_web1" {
  value = yandex_compute_instance.web[1].hostname
}
output "hostname_web2" {
  value = yandex_compute_instance.web[2].hostname
}
