# Terraform Module: Talos Kubernetes on Libvirt

<p align="left">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Talos%20Linux-4B44CE?style=for-the-badge&logo=talos&logoColor=white" alt="Talos Linux">
  <img src="https://img.shields.io/badge/Libvirt-8A2BE2?style=for-the-badge&logo=linux&logoColor=white" alt="Libvirt">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge">
</p>

A production-ready Terraform module for provisioning Kubernetes clusters on Talos Linux using libvirt (KVM).

## ✨ Features

- **Clean Architecture (BYOP)**: Provider-agnostic design with no local side effects (perfect for CI/CD pipelines).
- **CNI-Agnostic**: Easily disable default Flannel and `kube-proxy` to seamlessly install custom CNIs.
- **Image Factory Integration**: Dynamically generate optimized Talos images with required system extensions (e.g., `qemu-guest-agent`).
- **Flexible KVM/Libvirt Management**: Full control over networks (NAT, DHCP, DNS), storage pools, and individual node resources (CPU, RAM, Disk).
- **Local Image Support**: Option to provision clusters using pre-downloaded local Talos ISOs.
- **Automated Bootstrap**: Fully automates Talos configuration generation, machine patching, and Kubernetes bootstrapping.

## 📖 Overview

This module provides a pure Infrastructure-as-Code approach to deploying a fully functional Kubernetes cluster. The automated workflow includes:

1. **Infrastructure Provisioning**: Creates libvirt networks, storage pools, and virtual machines.
2. **OS Installation**: Boots VMs using Talos Linux (via Image Factory or local ISO).
3. **Configuration Generation**: Generates and applies cryptographic secrets and Talos machine configs.
4. **Cluster Bootstrap**: Bootstraps the control plane and outputs a ready-to-use `kubeconfig` and `talosconfig`.

---

## 🚀 Quick Start

Below is a complete example of how to use this module in your root `main.tf`.

### 1. Configure Providers

Since the module is provider-agnostic, define your connections first:

```hcl
terraform {
  required_providers {
    libvirt = { source = "dmacvicar/libvirt", version = ">= 0.9.0" }
    talos   = { source = "siderolabs/talos", version = ">= 0.10.1" }
    local   = { source = "hashicorp/local", version = ">= 2.4.0" }
  }
}

provider "libvirt" {
  uri = "qemu:///system" # Or qemu+ssh://root@remote-server/system
}
```

### 2. Call the Module

```hcl
module "talos_cluster" {
  source = "github.com/achernov3/terraform-talos-k8s"

  cluster_name       = "talos-dev"
  control_plane_role = "controlplane"
  worker_role        = "worker"
  default            = "default"
  disk_name          = "vda"

  pool_settings = {
    name = "talos_pool"
    type = "dir"
    target = { path = "/var/lib/libvirt/images/talos" }
  }

  # Disable default CNI to install a custom CNI later
  k8s_network = {
    disable_default_cni = true
    disable_kube_proxy  = true
  }

  talos_image = {
    factory = {
      version      = "latest"
      architecture = "amd64"
      platform     = "metal"
      extensions   = ["qemu-guest-agent", "iscsi-tools"]
    }
  }

  nodes = {
    "master-1" = { role = "controlplane", cpu = 2, memory = 4, disk_size = 20 }
    "worker-1" = { role = "worker", cpu = 4, memory = 8, disk_size = 50 }
  }
}
```

### 3. Save Configurations (Optional but Recommended)

The module outputs the configurations. You can save them locally using the `local_file` resource:

```hcl
resource "local_file" "kubeconfig" {
  content              = module.talos_cluster.kube_config
  filename             = "${pathexpand("~")}/.kube/config.d/talos-dev.yaml"
  file_permission      = "0600"
}

resource "local_file" "talosconfig" {
  content              = module.talos_cluster.talos_config
  filename             = "${pathexpand("~")}/.talos/talos-dev-config.yaml"
  file_permission      = "0600"
}
```

---

## � Module Structure

```text
.
├── modules/
│   ├── talos/          # Main orchestration module (Talos configs, bootstrap)
│   ├── node/           # Virtual machine provisioning (Libvirt domains)
│   ├── network/        # Network configuration (Libvirt networks, NAT, DHCP)
│   ├── pool/           # Storage pool management
│   ├── volumes/        # Disk volume allocation for nodes
│   ├── image/          # Local Talos ISO image handling
│   └── image_factory/  # Sidero Labs API integration for custom Talos images
└── examples/           # Ready-to-use implementation examples
```

---

## �🕸️ Networking & CNI

By default, this module is configured to bypass the built-in Talos CNI (Flannel) using the `k8s_network` variable. 

> **Note:** Because the default CNI is disabled, your nodes will show a `NotReady` status after the initial deployment. This is expected behavior!

To make the nodes `Ready`, you must deploy a custom CNI.

---

## ⚙️ Module Variables

### Core Settings

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cluster_name` | `string` | **Required** | Unique name of the Kubernetes cluster. |
| `nodes` | `map(object)` | **Required** | Map defining nodes (role, CPU, memory, disk). |
| `pool_settings` | `object` | **Required** | Libvirt storage pool configuration for VMs. |
| `talos_image` | `object` | **Required** | Talos image specification (Factory vs Local). |
| `disk_name` | `string` | **Required** | Target device name for primary storage (e.g. `vda`, `sda`). |
| `control_plane_role` | `string` | `"controlplane"` | String identifier for control plane nodes. |
| `worker_role` | `string` | `"worker"` | String identifier for worker nodes. |
| `memory_unit` | `string` | `"GiB"` | Unit for memory allocation (`GiB`, `MB`). |

### Network Configurations

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `k8s_network` | `object` | `disable_cni: true` | Disables Flannel and kube-proxy for custom CNI setups. |
| `network_settings` | `object` | `null` | Libvirt network configuration (NAT, DHCP, Subnets). If null, uses the default libvirt network. |

### Detailed Object Structures

#### `nodes`
```hcl
nodes = {
  "node-name" = {
    role      = "controlplane" # or "worker"
    cpu       = 2
    memory    = 4
    disk_size = 20
  }
}
```

#### `k8s_network`
```hcl
k8s_network = {
  disable_default_cni = true
  disable_kube_proxy  = true
}
```

#### `talos_image`
You can build a tailored image via Sidero Labs API:
```hcl
talos_image = {
  factory = {
    version      = "latest"
    architecture = "amd64"
    platform     = "metal"
    extensions   = ["qemu-guest-agent"]
  }
}
```
Or provide a local ISO path:
```hcl
talos_image = {
  local = {
    name = "talos-local.iso"
    path = "/var/lib/libvirt/images/talos.iso"
  }
}
```

---

## 📤 Outputs

| Name | Description | Sensitive |
|------|-------------|:---------:|
| `kube_config` | Raw Kubernetes configuration file content (YAML). | Yes |
| `talos_config` | Raw Talos client configuration (YAML) for `talosctl`. | Yes |
| `machine_config` | Map of raw generated Talos machine configurations per node. | Yes |
| `control_plane_endpoint` | The IP address/endpoint of the primary control plane node. | No |

---

## 🧹 Cleanup

To tear down the cluster and clean up libvirt resources:

```bash
terraform destroy
```

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
