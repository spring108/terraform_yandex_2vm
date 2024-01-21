terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


# provider properties
provider "yandex" {
  #my autorization tocken
  token     = "MY_YANDEX_TOKEN"

  #my yandex cloud identifier
  cloud_id  = "b1gogrmv0lhpqnt6hqu1"

  #my yandex folder identifier (default)
  folder_id = "b1g5ks1opqq9pgacsaoo"

  # YANDEX ZONE: ru-central1-a, ru-central1-b, ru-central1-d
  zone = "ru-central1-a"
}




#############################################################
### VM "build"
#############################################################
# vm "build" resource configurations
resource "yandex_compute_instance" "vm-build" {
  name = "build"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.ubuntu2004_15GB.id
  }
  network_interface {
    subnet_id = "e9buvssk2htbkq921avo"
    nat       = true
  }
  metadata = {
    user-data = "${file("./public_keys.yml")}"
  }
  scheduling_policy {
    preemptible = true 
  }


  # init vm-build -------------------------
  connection {
    type     = "ssh"
    user     = "spring"
    private_key = file("/root/.ssh/id_rsa")
    host = yandex_compute_instance.vm-build.network_interface.0.nat_ip_address
  }
  provisioner "file" {
    source      = "./Dockerfile"
    destination = "/tmp/terraform/Dockerfile"
  }
  # make the artifact -------------------------
    provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo apt-get update", 
      "sudo apt install git -y",
      "sudo apt install docker.io -y",
      "sudo apt install default-jdk",
      "sudo apt install maven",
      "cd /tmp && git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git",
      "cd /tmp/boxfuse-sample-java-war-hello && mvn package",
      "cp /tmp/boxfuse-sample-java-war-hello/target/hello-1.0.war /tmp/terraform/hello.war",
      "sudo docker build -t mysite1 .",
      "sudo docker tag mysite1 cr.yandex/${yandex_container_registry.mydockerregistry.id}/mysite1",

    ]
  }

}

















#############################################################
### TEMPLATES
#############################################################

# boot disk template = ubuntu 20.04
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}


# boot disk template = ubuntu 20.04 with 15GB
resource "yandex_compute_disk" "ubuntu2004_15GB" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.ubuntu_image.id
  size = 15
}



#############################################################
### Yandex Registry: mydockerregistry
#############################################################
resource "yandex_container_registry" "my-reg" {
  name = "mydockerregistry"
  folder_id = "crpdla5isvrlmlvea9ha"
  labels = {
    my-label = "my-label-value"
  }
}
resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.my-reg.id
  role        = "container-registry.images.puller"
  members = [
    "system:allUsers",
  ]
}
resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.my-reg.id
  role        = "container-registry.images.pusher"
  members = [
    "system:allUsers",
  ]
}
