# Host Details:
OS: Ubuntu 24.04
Memory: 16GB
CPU: 16 (8 core, 2 threads / core)

---

# Tools needed in Host to create VM's
1. KVM: A Linux kernel module that turns your system into a hypervisor, enabling VMs to run with near-native performance by leveraging CPU virtualization features

2. QEMU: A powerful emulator that provides the virtual hardware (for example, CPU, disk, network) for your VMs, working with KVM for fast execution.

3. libvirt: A management layer that simplifies VM creation, networking, and storage, offering tools like virsh and APIs for automation.

Ref: https://www.freecodecamp.org/news/turn-ubuntu-2404-into-a-kvm-hypervisor/

4. vagrant: CLI tool for managing VM's
---

# Setup:
1. Check virtualization support

```
lscpu | grep Virtualization

# or

kvm-ok
```
![alt text](./assets/image.png)
![alt text](./assets/image1.png)

2. Installing tools

```
# Update the system

sudo apt update && sudo apt upgrade -y
```

```
# Installing required tools

sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libvirt-dev -y
```
- qemu-kvm: Emulates hardware for VMs.
- libvirt-daemon-system: Manages VMs.
- libvirt-clients: CLI tools like virsh for hypervisor management.
- bridge-utils: For network bridging.
- libvirt-dev: Supporting files needed by vagrant


```
#  Verify that kvm is loaded
lsmod | grep kvm 
```
![alt text](./assets/image3.png)

```
# Add user to the libvirt group to create VM without sudo

sudo usermod -aG libvirt $USER

# logout and log back in for this group change to take effect.
```

```
# Install Vagrant
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install vagrant

# Vagrant-libvirt is a Vagrant plugin that adds a Libvirt provider to Vagrant, allowing Vagrant to control and provision machines via Libvirt toolkit.

vagrant plugin install vagrant-libvirt
```


# Start the vm's
```
cd vagrant
vagrant up
```