# Talos Kubernetes Cluster Terraform Module

<p align="center">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  <img src="https://img.shields.io/badge/Talos%20Linux-4B44CE?style=for-the-badge&logo=talos&logoColor=white" alt="Talos Linux">
  <img src="https://img.shields.io/badge/Libvirt-8A2BE2?style=for-the-badge&logo=linux&logoColor=white" alt="Libvirt">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge">
</p>

A production-ready Terraform module for deploying Kubernetes clusters on Talos Linux using libvirt.

## Features

- Single command cluster provisioning
- Automated Talos configuration generation
- Support for control plane and worker nodes
- Flexible networking with NAT and DHCP
- Image Factory integration for automatic image building
- Local image support option
- System extensions support

## Overview

This module provisions a fully functional Kubernetes cluster with:

1. Virtual machine provisioning (libvirt)
2. Talos Linux installation and configuration
3. Kubernetes cluster bootstrap
4. Ready-to-use kubeconfig generation

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.0 | Infrastructure provisioning |
| libvirt | latest | Virtualization provider |
| talosctl | latest | Talos cluster management |
| kubectl | latest | Kubernetes CLI |

## Usage

### Quick Start

```hcl
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.10.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

module "talos_cluster" {
  source = "github.com/your-org/talos-k8s-terraform"

  cluster_name = "my-cluster"
  
  nodes = {
    "master-1" = {
      role      = "controlplane"
      cpu       = 2
      memory    = 4
      disk_size = 20
    },
    "worker-1" = {
      role      = "worker"
      cpu       = 2
      memory    = 2
      disk_size = 20
    }
  }

  pool_settings = {
    name = "talos_pool"
    type = "dir"
    target = {
      path = "/var/lib/libvirt/images/talos"
    }
  }

  talos_image = {
    factory = {
      version      = "latest"
      architecture = "amd64"
      platform     = "metal"
      extensions   = ["qemu-guest-agent", "iscsi-tools"]
    }
  }
}
```

### Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Access the Cluster

```bash
# Using the output kubeconfig
export KUBECONFIG=$(terraform output -raw kube_config)

# Verify nodes
kubectl get nodes
```

## Module Structure

```
.
├── main.tf                 # Root module
├── locals.tf               # Local values
├── output.tf               # Outputs
├── modules/
│   ├── talos/              # Main cluster module
│   ├── node/               # Node provisioning
│   ├── network/            # Network management
│   ├── pool/               # Storage pool
│   ├── volumes/            # Volume management
│   ├── image/              # Local image handling
│   └── image_factory/      # Image Factory integration
└── files/
    └── image/
        └── schematic.yaml  # Image Factory schematic
```

## Variables

### Root Module Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `cluster_name` | string | Yes | - | Name of the Kubernetes cluster |
| `nodes` | map(object) | Yes | - | Map of node definitions (see below) |
| `control_plane_role` | string | Yes | `"controlplane"` | Role identifier for control plane nodes |
| `worker_role` | string | Yes | `"worker"` | Role identifier for worker nodes |
| `pool_settings` | object | Yes | - | Storage pool configuration (see below) |
| `network_settings` | object | No | `null` | Network configuration (see below) |
| `talos_image` | object | Yes | - | Talos image specification (see below) |
| `memory_unit` | string | No | `"GiB"` | Unit for memory specification |
| `default` | string | Yes | - | Default provider identifier |

### `nodes` Map Structure

Each node is defined as a map with the following attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `role` | string | Node role: `"controlplane"` or `"worker"` |
| `cpu` | number | Number of virtual CPUs |
| `memory` | number | Amount of memory (in `memory_unit`) |
| `disk_size` | number | Disk size in GB |

Example:
```hcl
nodes = {
  "master-1" = {
    role      = "controlplane"
    cpu       = 2
    memory    = 4
    disk_size = 20
  },
  "master-2" = {
    role      = "controlplane"
    cpu       = 2
    memory    = 4
    disk_size = 20
  },
  "worker-1" = {
    role      = "worker"
    cpu       = 4
    memory    = 8
    disk_size = 50
  }
}
```

### `pool_settings` Object

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | Yes | - | Pool name |
| `type` | string | Yes | - | Pool type (e.g., `"dir"`) |
| `target.path` | string | Yes | - | Path to the storage directory |
| `target.permissions.owner` | string | No | `"1000"` | Owner UID |
| `target.permissions.group` | string | No | `"1000"` | Owner GID |
| `target.permissions.mode` | string | No | `"0711"` | Directory permissions |

Example:
```hcl
pool_settings = {
  name = "talos_pool"
  type = "dir"
  target = {
    path = "/var/lib/libvirt/images/talos"
    permissions = {
      owner = "1000"
      group = "1000"
      mode  = "0711"
    }
  }
}
```

### `network_settings` Object

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | Yes | - | Network name |
| `autostart` | bool | No | `true` | Start network on boot |
| `dns` | string | No | `"yes"` | Enable DNS |
| `forward.nat.ports.start` | string | Yes* | - | NAT port range start |
| `forward.nat.ports.end` | string | Yes* | - | NAT port range end |
| `ips.address` | string | Yes* | - | Network base address |
| `ips.family` | string | No | `"ipv4"` | IP family |
| `ips.netmask` | string | No | `"255.255.255.0"` | Network netmask |
| `ips.dhcp.ranges` | list(object) | Yes* | - | DHCP range configuration |

* Required when network is enabled

Example:
```hcl
network_settings = {
  name      = "talos-network"
  autostart = true
  dns       = "yes"
  forward = {
    nat = {
      ports = {
        start = "10000"
        end   = "20000"
      }
    }
  }
  ips = {
    address = "192.168.100.1"
    family  = "ipv4"
    netmask = "255.255.255.0"
    dhcp = {
      ranges = [
        {
          start = "192.168.100.128"
          end   = "192.168.100.254"
          lease = {
            expiry = 86400
            unit   = "seconds"
          }
        }
      ]
    }
  }
}
```

### `talos_image` Object

You must specify **exactly one** of `local` or `factory`.

#### Using Image Factory (Recommended)

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `factory.use_stable` | bool | No | `true` | Use only stable releases |
| `factory.version` | string | No | `"latest"` | Talos version (e.g., `"v1.6.5"` or `"latest"`) |
| `factory.architecture` | string | No | `"amd64"` | CPU architecture (`"amd64"` or `"arm64"`) |
| `factory.platform` | string | No | `"metal"` | Platform type |
| `factory.extensions` | list(string) | No | `[]` | System extensions to include |
| `factory.extra_kernel_args` | list(string) | No | `[]` | Additional kernel arguments |

Available extensions:
- `qemu-guest-agent` - QEMU guest agent
- `iscsi-tools` - iSCSI utilities
- `util-linux-tools` - System utilities
- And more from [Sidero Labs extensions](https://www.siderolabs.com/blog/the-state-of Talos-extensions)

#### Using Local Image

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `local.name` | string | Yes | - | Logical image name |
| `local.path` | string | Yes | - | Path to ISO image |

Example - Image Factory:
```hcl
talos_image = {
  factory = {
    version      = "latest"
    architecture = "amd64"
    platform     = "metal"
    extensions   = [
      "qemu-guest-agent",
      "iscsi-tools",
      "util-linux-tools"
    ]
  }
}
```

Example - Local Image:
```hcl
talos_image = {
  local = {
    name = "talos-local"
    path = "/path/to/talos.iso"
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `client_configuration` | object | Talos client configuration (sensitive) |
| `kube_config` | string | Kubernetes configuration file (sensitive) |
| `machine_config` | object | Generated Talos machine configurations |
| `control_plane_endpoints_list` | list(string) | Control plane API endpoints |

## Example Configurations

### Minimal Single Node

```hcl
module "talos_cluster" {
  source = "./modules/talos"

  cluster_name       = "minimal"
  control_plane_role = "controlplane"
  worker_role        = "worker"
  default            = "default"

  pool_settings = {
    name = "minimal"
    type = "dir"
    target = { path = "~/minimal" }
  }
  network_settings = null

  talos_image = {
    factory = {
      version      = "latest"
      architecture = "amd64"
      platform     = "metal"
    }
  }

  nodes = {
    "node-1" = {
      role      = "controlplane"
      cpu       = 2
      memory    = 2
      disk_size = 10
    }
  }
}
```

### Multi-Node Cluster

```hcl
module "talos_cluster" {
  source = "./modules/talos"

  cluster_name       = "production"
  control_plane_role = "controlplane"
  worker_role        = "worker"
  default            = "default"

  pool_settings = {
    name = "production"
    type = "dir"
    target = { path = "~/production" }
  }

  network_settings = {
    name      = "production-net"
    autostart = true
    forward = {
      nat = {
        ports = { start = "10000", end = "20000" }
      }
    }
    ips = {
      address = "10.0.0.1"
      dhcp = {
        ranges = [{ start = "10.0.0.100", end = "10.0.0.200" }]
      }
    }
  }

  talos_image = {
    factory = {
      version      = "v1.6.5"
      architecture = "amd64"
      platform     = "metal"
      extensions   = ["qemu-guest-agent"]
    }
  }

  nodes = {
    "master-1" = { role = "controlplane", cpu = 4, memory = 4, disk_size = 40 }
    "master-2" = { role = "controlplane", cpu = 4, memory = 4, disk_size = 40 }
    "master-3" = { role = "controlplane", cpu = 4, memory = 4, disk_size = 40 }
    "worker-1" = { role = "worker", cpu = 8, memory = 8, disk_size = 100 }
    "worker-2" = { role = "worker", cpu = 8, memory = 8, disk_size = 100 }
  }
}
```

## Cleanup

```bash
terraform destroy
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.
