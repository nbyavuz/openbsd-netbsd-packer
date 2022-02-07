# "timestamp" template function replacement
locals {

  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "virtualbox-iso" "vbox-gce-builder" {

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
  cpus                    = 4
  disk_size               = 25600
  guest_additions_mode    = "disable"
  guest_os_type           = "OpenBSD_64"
  headless                = true
  http_directory          = "config"
  iso_checksum            = "sha256:1882f9a23c9800e5dba3dbd2cf0126f552605c915433ef4c5bb672610a4ca3a4"
  iso_urls                = [
    "install70.iso",
    "https://cdn.openbsd.org/pub/OpenBSD/7.0/amd64/install70.iso"
    ]
  memory                  = 4096
  shutdown_command        = "halt -p"
  ssh_password            = "packer"
  ssh_port                = 22
  ssh_username            = "root"
  ssh_wait_timeout        = "10000s"
  vm_name                 = "openbsd70-gce.x86-64"
}

build {

  sources = ["source.virtualbox-iso.vbox-gce-builder"]

  provisioner "shell" {
    script = "scripts/prep-postgres.sh"
  }

  provisioner "shell" {
    script = "scripts/prep-gce.sh"
  }

  provisioner "file" {
    source = "files/rc.local.sh"
    destination = "/etc/rc.local"
  }

  post-processors {

    post-processor "manifest" {
      output     = "output/manifest.json"
      strip_path = true
    }

    post-processor "shell-local" {
      inline = [
        "jq -r '.builds[] | (.name + \"/\" + .files[].name)' output/manifest.json | grep '\\.vmdk$' > output/disk-path", "if [ $(wc -l < output/disk-path) -gt 1 ]; then exit 1; fi", "qemu-img convert -f vmdk -O raw \"output-$(cat output/disk-path)\" output/disk.raw", "rm output/manifest.json output/disk-path"
      ]
    }

    post-processor "artifice" {
      files = ["output/disk.raw"]
    }

    post-processor "compress" {
      output = "output/openbsd70.tar.gz"
    }

    post-processor "googlecompute-import" {
      bucket            = "template"
      image_family      = "template"
      image_name        = "template"
      project_id        = "template"
    }
  }
}