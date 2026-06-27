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

# Hostnames

Hostname will be assigned to server, node-0, node-1. Hostname is used when executing command from local laptop/ jumpbox. It also plays major role in the cluster. Instead of kubernetes clients using an IP adress to issue commands to the K8 API server, those clients will use the `server` hostname instead. Hostnames are also used by each worker machine, `node-0` and `node-1` when registering with a given kubernetes cluster.


To set the hostname for each machine using `machine.txt` file

```bash
while read IP FQDN HOST SUBNET; do
  CMD="sed -i 's/^127.0.1.1.*/127.0.1.1\t${FQDN} $HOST'/ /etc/hosts"
  ssh -i vagrant/root-ssh-key/root_key -n root@${IP} "$CMD"
  ssh -i vagrant/root-ssh-key/root_key -n root@${IP} hostnamectl set-hostname ${HOST}
  ssh -i vagrant/root-ssh-key/root_key -n root@${IP} systemctl restart systemd-hostnamed
done < machine.txt
```

Verify the hostname is set on each machine:
```bash
while read IP FQDN HOST SUBNET; do
  ssh -i vagrant/root-ssh-key/root_key -n root@${IP} hostname --fqdn
done < machine.txt
```

# Host Lookup Table

Generate `hosts` file which will be appendend to /etc/hosts file on the jumpbox and 3 cluster members. This will allow each machine to be reachable using a hostname such as `server`, `node-0` or `node-1`

```bash 
echo "" > hosts
echo "# Kubernetes the hard way" >> hosts
```

Generate the host entry for each machine in the `machine.txt` file and append it to the `hosts` file:

```bash
while read IP FQDN HOST SUBNET; do 
  ENTRY="${IP} ${FQDN} ${HOST}"
  echo $ENTRY >> hosts
done < machine.txt
```

```
cat hosts
```

```

# Kubernetes the hard way
10.240.0.10 server.kubernetes.local server
10.240.0.20 node-0.kubernetes.local node-0
10.240.0.21 node-1.kubernetes.local node-1


```

## Adding /etc/hosts entries in jumbox

```
cat hosts | sudo tee -a /etc/hosts > /dev/null
```

Verify that the file `/etc/hosts` has been updated
```
cat /etc/hosts
```

At this stage SSH should be possible using hostname
```bash
for host in server node-0 node-1; do
  ssh -i vagrant/root-ssh-key/root_key root@${host} hostname
done
```

## Adding /etc/hosts entries to remote machines

```bash
while read IP FQDN HOST SUBNET; do
  scp -i vagrant/root-ssh-key/root_key hosts root@${HOST}:~/
  ssh -i vagrant/root-ssh-key/root_key -n root@${HOST} "cat hosts >> /etc/hosts"
done < machine.txt
```

Now each machine can be accessed using hostname such as `server`, `node-0` and `node-1`