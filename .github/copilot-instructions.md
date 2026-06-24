# Copilot instructions

## Project shape

This repository is a docs-first walkthrough for building a Kubernetes lab by hand on Debian 12 VMs. The main flow is split across `00-prerequisite.md`, `01-provisioning-vm.md`, and `02-compute-resources.md`, with the Vagrant environment defined in `vagrant/Vagrantfile`.

The important moving parts are:

- `vagrant/Vagrantfile` provisions three libvirt VMs: `server`, `node-0`, and `node-1`
- `downloads-amd64.txt` lists the binary URLs to prefetch for the host architecture
- `downloads-binaries/` is the local staging area for client, controller, worker, and CNI artifacts
- `00-prerequisite.md` covers host setup, Vagrant/libvirt installation, and binary download/extraction
- `01-provisioning-vm.md` documents the VM provisioning flow
- `02-compute-resources.md` introduces the machine database used later in the cluster setup

## Commands

There is no dedicated build, test, or lint suite in the repository. Use the documented setup and validation commands instead:

```bash
cd vagrant
vagrant up
```

```bash
kubectl version --client
```

For the documented binary fetch flow:

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads-binaries \
  -i downloads-$(dpkg --print-architecture).txt
```

## Conventions

- Assume Debian 12 (`generic/debian12`) and libvirt are the default lab environment unless a doc says otherwise.
- Keep the VM identity consistent with the Vagrantfile: `server` at `10.240.0.10`, `node-0` at `10.240.0.20`, and `node-1` at `10.240.0.21`.
- Treat `downloads-binaries/` as a staged artifact tree with subdirectories for `client`, `controller`, `worker`, and `cni-plugins`.
- Preserve the documented binary organization flow: extract, move into the role-specific directories, then mark the binaries executable.
- Follow the machine database schema described in `02-compute-resources.md`: `IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET`.
