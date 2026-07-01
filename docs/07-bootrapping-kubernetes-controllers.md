# Bootstrapping the kubernetes control plane

In this lab you will bootstrap the kubernetes control plane. The following components will be installed on the `server` machine: Kubernetes API Server, Scheduler, and Controller Manager.

## Prerequisites

Copy Kubernetes binaries and systemd unit files to the `server` machine:

```bash

scp -i vagrant/root-ssh-key/root_key \
  downloads-binaries/controller/kube-apiserver \
  downloads-binaries/controller/kube-controller-manager \
  downloads-binaries/controller/kube-scheduler \
  downloads-binaries/client/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs-template/kube-scheduler.yaml \
  configs-template/kube-apiserver-to-kubelet.yaml \
  root@server:~/

```

The commands in this lab must be run on the `server` machine.

SSH into `server`

```bash
ssh -i vagrant/root-ssh-key/root_key root@server
```

## Provision the kubernetes control plane

Create the kubernetes configuration directory:

```bash
mkdir -p /etc/kubernetes/config
```

### Install the Kubernetes controller binaries:

```bash
mv kube-apiserver \
  kube-controller-manager \
  kube-scheduler \
  kubectl \
  /usr/local/bin
```

### Configure the kubernetes API server

```bash
{
  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes
}
```

Create the `kube-apiserver.service` systemd unit file:

```bash
mv kube-apiserver.service \
  /etc/systemd/system/kube-apiserver.service
```

### Configure the Kubernetes controller manager

Move the `kube-controller-manager` kubeconfig into place:

```bash
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Create the `kube-controller-manager.service` systemd unit file:

```bash
mv kube-controller-manager.service /etc/systemd/system/
```

### configure the kubernetes scheduler

Move the `kube-scheduler` kubeconfig into place:

```bash
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Create the `kube-scheduler.yaml` configuration file:

```bash
mv kube-scheduler.yaml /etc/kubernetes/config/
```

Create the `kube-scheduler.service` systemd unit file:

```bash
mv kube-scheduler.service /etc/systemd/system/
```

### Start the controller services

```bash
systemctl daemon-reload

systemctl enable kube-apiserver \
  kube-controller-manager \
  kube-scheduler

systemctl start kube-apiserver \
  kube-controller-manager \
  kube-scheduler
```

Check if the controller components are active

```bash
systemctl is-active \
  kube-apiserver.service \
  kube-controller-manager.service \
   kube-scheduler.service
```

For more detailed status check
```bash
systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler
```

In case of error or to check logs use `journalctl` command.

```bash
journalctl -u kube-apiserver
journalctl -u kube-controller-manager
journalctl -u kube-scheduler
```

### Verification

At this point the Kubernetes control plan components should be up and running. Verify with `kubectl` tool:

```bash
kubectl cluster-info \
  --kubeconfig admin.kubeconfig
```

```text
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

# RBAC for Kubelet Authorization

In this section you will configure RBAC permissions to allow the kubernetes API server to access the kubelet API on each worker node. Access to the Kubelet API is required for retrieving metrics, logs and executing commands in pods.

> This tutorial sets the Kubelet `--authorization-mode` flag to `Webhook`. Webhook mode uses the [SubjectAccessReview](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access) API to determine authorization.

The commands in this section will affect the entire cluster and only need to be run on the `server` machine.

```bash
ssh -i vagrant/root-ssh-key/root_key root@server
```

Create the `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) with permissions to access the Kubelet API and perform most common tasks associated with managing pods:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### Verification

At this point the kubernetes control plane is up and running.

Run the following command from the `jumpbox` machine to verify it's working:

Make a HTTP request for the kubernetes version info:
```bash
curl --cacert certs/ca.crt \
  https://server.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "35",
  "emulationMajor": "1",
  "emulationMinor": "35",
  "minCompatibilityMajor": "1",
  "minCompatibilityMinor": "34",
  "gitVersion": "v1.35.6",
  "gitCommit": "fc0e7a6ca50f7ce368f9a5516e1716b473ed3a26",
  "gitTreeState": "clean",
  "buildDate": "2026-06-11T18:05:09Z",
  "goVersion": "go1.25.11",
  "compiler": "gc",
  "platform": "linux/amd64"
}%
```