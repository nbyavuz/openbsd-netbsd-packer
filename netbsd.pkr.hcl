variable "account_file" { type = string }
variable "bucket" { type = string }
variable "project_id" { type = string }
variable "image_date" { type = string }

# "timestamp" template function replacement
locals {

  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "qemu" "qemu-gce-builder" {

  boot_command            = [
      "<enter><wait1s>",
      "<enter><wait1s>",
      "<enter><wait1s>",
      "<down><enter><wait1s>",
      "<enter><wait1s>",
      "<enter><wait1s>",
      "<enter><wait1s>",
      "<down><enter><wait1s>",
      "<enter><wait1s>",
      "<down><enter><wait3s>",
      "b<enter><wait1s>x<enter><wait1s>",
      "<down><enter><wait1s>",
      "<enter><wait50s>",
      "<enter><wait1s>",
      "g<enter><wait1s>",
      "o<enter><wait1s>packer<enter><wait1s><enter><wait1s>b<enter><wait1s>",
      "packer<enter><wait1s>packer<enter><wait1s>packer<enter><wait3s>",
      "d<enter><wait1s><enter><wait1s>packer<enter><wait1s>packer<enter><wait1s>",
      "packer<enter><wait3s>",
      "x<enter><wait1s>",
      "<enter><wait3s>",
      "d<enter><wait30s>",
      "root<enter><wait3s>",
      "packer<enter><wait5s>",
      "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config<enter><wait100ms>",
      "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config<enter><wait100ms>",
      "sed -i 's/UsePam yes/UsePam no/g' /etc/ssh/sshd_config<enter><wait100ms>",
      "echo '/sbin/dhcpcd' > /etc/rc.local<enter><wait100ms>",
      "reboot<enter>"
    ]

  boot_wait               = "20s"
  cpus                    = 4
  disk_size               = 25600
  headless                = true
  memory                  = 4096
  iso_checksum            = "sha256:5f1bca14c4090122f31713dd86a926f63109dd6fb3c05f9b9b150a78acc8bc7e"
  iso_urls                = [
    "NetBSD-9.2-amd64.iso",
    "https://cdn.netbsd.org/pub/NetBSD/NetBSD-9.2/images/NetBSD-9.2-amd64.iso"
    ]
  shutdown_command        = "/sbin/shutdown -p now"
  ssh_username            = "root"
  ssh_password            = "packer"
  ssh_port                = 22
  ssh_wait_timeout        = "300s"
  format                  = "qcow2"
  vm_name                 = "disk.raw"
  output_directory        = "output"
}

build {

  sources = ["source.qemu.qemu-gce-builder"]

  provisioner "shell" {
    script = "scripts/netbsd-prep-postgres.sh"
  }

  provisioner "shell" {
    script = "scripts/netbsd-prep-gce.sh"
  }

  provisioner "file" {
    source = "files/netbsd-rc.local.sh"
    destination = "/etc/rc.local"
  }

  provisioner "file" {
    source = "files/netbsd-rc.shutdown.sh"
    destination = "/etc/rc.shutdown"
  }

  provisioner "shell" {
    inline = ["chmod 744 /etc/rc.local && chmod 744 /etc/rc.shutdown"]
  }

  provisioner "shell" {
    script = "scripts/netbsd-set-cron.sh"
  }

  post-processors {
    post-processor "compress" {
      output = "output/netbsd92.tar.gz"
    }

    post-processor "googlecompute-import" {
      account_file      = "${var.account_file}"
      bucket            = "${var.bucket}"
      image_family      = "pg-ci-netbsd-9-2"
      image_name        = "pg-netbsd-9-2-${var.image_date}"
      project_id        = "${var.project_id}"
    }
  }
}
