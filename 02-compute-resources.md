# Provision Compute Resources

Kubernetes requires set of machines to host control plane and the worker nodes where containers are ultimately run.

## Machine Database

A text file will be used as machine database, to store various machine attributes that will be used when setting up kubernetes control plane and worker nodes.

Schema of the entries:
```
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
```

IPV4_ADDRESS: Machine IP address
FQDN: Fully qualified domain name
HOSTNAME: Host name
POD_SUBNET: Pod IP Subnet

K8 assigns one IP address per pod and the IP is allocated from POD_SUBNET which is unique IP address range assigned to each machine in the cluster for doing so.

```
cat machines.txt
```

```
xxx.xxx.xxx.xxx server.kubernetes.local server
xxx.xxx.xxx.xxx node-0.kubernetes.local node-0 10.200.0.0/24
xxx.xxx.xxx.xxx node-1.kubernetes.local node-1 10.200.1.0/24
```

# Cofiguring SSH Access

## Enable root SSH Access

By default, a new debian install disables SSH access for `root` user. This is done for security reasons as `root` user has total administrative control of unix-like systems. Root access is enabled for ease of this project trading off with security.

Root login is already enabled with Vagrant Debian 12 box.

## Generate and Distribute SSH keys

Generate a new SSH key:
```
ssh-keygen
```

Copy the SSH public key to each machine:
```
KEY="vagrant/root-ssh-key/root_key.pub"

for vm in server node-0 node-1; do
  cat "$KEY" | vagrant ssh "$vm" -c \
  "sudo install -d -m 700 /root/.ssh && sudo tee -a /root/.ssh/authorized_keys > /dev/null && sudo chmod 600 /root/.ssh/authorized_keys"
done

```

Verfiy root SSH access is working:
```
while read IP FQDN HOST SUBNET; do
  ssh -i vagrant/root-ssh-key/root_key -n root@${IP} hostname
done < machine.txt
```