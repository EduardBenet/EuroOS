# linuxmint-azure.pkr.hcl
packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "iso_url"      { default = "linuxmint-22.3-cinnamon-64bit.iso" }
variable "iso_checksum" { default = "sha256:a081ab202cfda17f6924128dbd2de8b63518ac0531bcfe3f1a1b88097c459bd4" }
variable "disk_size"    { default = "30720" }  # 30 GB in MB

source "qemu" "linuxmint" {
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  output_directory = "output-linuxmint"
  disk_size        = var.disk_size
  format           = "raw"           # convert to VHD afterwards
  accelerator      = "kvm"
  memory           = 2048
  cpus             = 2
  headless         = true

  # Serve the preseed file
  http_directory = "http"

  # Boot Linux Mint's Casper/Ubiquity installer unattended
  boot_wait = "15s"
  boot_command = [
    "<esc><wait>",
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "boot=casper ",
    "automatic-ubiquity ",
    "quiet splash noprompt ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "--<enter>"
  ]

  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "60m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  sources = ["source.qemu.linuxmint"]

  # Install Azure-required packages
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y walinuxagent cloud-init",
      # Hyper-V drivers (required for Azure)
      "sudo apt-get install -y linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual",
      # Azure repos (faster apt mirror inside Azure)
      "sudo sed -i 's|http://[a-z][a-z].archive.ubuntu.com|http://azure.archive.ubuntu.com|g' /etc/apt/sources.list",
      # Serial console for boot diagnostics
      "sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300\"/' /etc/default/grub",
      "sudo update-grub",
      # Deprovision
      "sudo waagent -force -deprovision+user",
      "sudo sync"
    ]
  }
}