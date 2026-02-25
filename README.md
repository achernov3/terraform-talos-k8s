# Talos Kubernetes Cluster Provisioned with Terraform

This project provisions a fully functional Kubernetes cluster based on Talos Linux using Terraform.

With a single Terraform workflow, it:

1) Creates virtual machines

2) Installs and configures Talos

3) Bootstraps a Kubernetes cluster

4) Produces a ready-to-use kubeconfig

The entire infrastructure lifecycle is managed declaratively.

## 🚀 Overview

This repository provides Infrastructure as Code (IaC) for deploying a production-ready Kubernetes cluster built on:

- Terraform – Infrastructure provisioning

- Talos Linux – Secure, immutable Kubernetes OS

- Virtual machines (provider-dependent)

- Automated cluster bootstrap

The goal of this project is to make Kubernetes cluster creation reproducible, automated, and simple — executed with a single command.

## 🏗 Architecture

High-level workflow:

```shell
Terraform
   ↓
Virtual Machines Provisioning
   ↓
Talos Configuration Generation
   ↓
Cluster Bootstrap
   ↓
Kubernetes Ready
```

The Terraform configuration:

- Creates control plane and worker nodes

- Generates Talos machine configurations

- Applies configuration to nodes

- Bootstraps the control plane

- Retrieves kubeconfig for cluster access


## ⚙️ Requirements

- `Terraform >= 1.x`

- `libvirt`

- `kubectl` (optional, for verification)

- `talosctl`

## ▶️ Usage

### 1️⃣ Initialize
```shell
terraform init
```

### 2️⃣ Review Plan
```shell
terraform plan
```

### 3️⃣ Apply
```shell
terraform apply
```

After completion:

- Cluster is bootstrapped

- kubeconfig is generated

- Kubernetes API is accessible

## 🧪 Verify Cluster

```shell
kubectl get nodes
```

You should see all control plane and worker nodes in Ready state.

## 🔄 Destroy Cluster

To completely remove the infrastructure:

```shell
terraform destroy
```

🤝 Contributing

Pull requests are welcome.

If you find issues or want to improve modularity, feel free to open an issue or submit a PR.
