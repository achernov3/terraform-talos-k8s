terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}