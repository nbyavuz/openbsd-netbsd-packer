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
    "S<enter><wait>",
    "cat <<EOF >>install.conf<enter>",
    "System hostname = openbsd70<enter>",
    "Password for root = packer<enter>",
    "Setup a user = packer<enter>",
    "Password for user = packer<enter>",
    "Allow root ssh login = yes<enter>",
    "What timezone are you in = Etc/UTC<enter>",
    "Do you expect to run the X Window System = no<enter>",
    "Set name(s) = -man* -game* -x*<enter>",
    "Directory does not contain SHA256.sig. Continue without verification = yes<enter>",
    "EOF<enter>",
    "install -af install.conf && reboot<enter>"
    ]

  boot_wait               = "20s"
  cpus                    = 2
  disk_size               = 25600
  memory                  = 1024
  headless                = true
  iso_checksum            = "sha256:1882f9a23c9800e5dba3dbd2cf0126f552605c915433ef4c5bb672610a4ca3a4"
  iso_urls                = [
    "install70.iso",
    "https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/install70.iso"
    ]
  shutdown_command        = "halt -p"
  ssh_username            = "root"
  ssh_password            = "packer"
  ssh_port                = 22
  ssh_wait_timeout        = "300s"
  format                  = "raw"
  vm_name                 = "disk.raw"
  output_directory        = "output"
}

build {

  sources = ["source.qemu.qemu-gce-builder"]

  provisioner "shell" {
    script = "scripts/openbsd-prep-postgres.sh"
  }

  provisioner "shell" {
    script = "scripts/openbsd-prep-gce.sh"
  }

  provisioner "file" {
    source = "files/openbsd-rc.local.sh"
    destination = "/etc/rc.local"
  }

  provisioner "file" {
    source = "files/openbsd-rc.shutdown.sh"
    destination = "/etc/rc.shutdown"
  }

  provisioner "shell" {
    inline = ["chmod 744 /etc/rc.local && chmod 744 /etc/rc.shutdown"]
  }

  provisioner "shell" {
    script = "scripts/openbsd-set-cron.sh"
  }

  post-processors {
    post-processor "compress" {
      output = "output/openbsd70.tar.gz"
    }

    post-processor "googlecompute-import" {
      account_file      = "${var.account_file}"
      bucket            = "${var.bucket}"
      image_family      = "pg-ci-openbsd-7-0"
      image_name        = "pg-openbsd-7-0-${var.image_date}"
      project_id        = "${var.project_id}"
    }
  }
}
