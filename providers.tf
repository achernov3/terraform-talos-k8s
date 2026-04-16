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
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

provider "helm" {
  kubernetes = {
    config_path = "${pathexpand("~")}/.kube/config.d/${local.cluster_name}.yaml"
  }
}