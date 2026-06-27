# Provisioning a CA and Generating TLS Certificates

In this lab a PKI Infrastructure will be provisioned using openssl to bootstrap a Certificate Authority, and generate TLS certificates for the following components: kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy. The commands will be run from the jumpbox.

## Certificate Authority (CA)

In this section a CA will be provisioned that can be used to generate additional TLS certificates for the other Kubernetes components. Setting up CA and generating certificates can be time-consuming, especially when doing it for the first time. So the openssl configuration is added in file ca.conf, which defines all the details needed to generate certificates for each kubernetes component.

To check file content:
```
cat ca.conf
```

TODO: Try with production grade certificate management

Every certificate authority starts with a private key and root certificate. In this section, we are going to create a self-signed certificate authority. This isn't something that is done in a real-world production environment.

Generate the CA configuration file, certificate and private key:
```bash
{
  openssl genrsa -out ca.key 4096

  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ../ca.conf \
    -out ca.crt
}
```

Result:
```txt
ca.crt ca.key
```

## Create Client and Server Certificates

In this section client and server certificates for each kubernetes components and a client certificate for the kubernetes `admin` user.

Generate certificates and private key
```bash
certs=(
  "admin" "node-0" "node-1" "kube-proxy"
  "kube-scheduler" "kube-controller-manager" "kube-api-server"
  "service-accounts"
)
```

```bash
for i in ${certs[@]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
  -config "../ca.conf" -section ${i} \
  -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
  -copy_extensions copyall \
  -sha256 -CA "ca.crt" \
  -CAkey "ca.key" \
  -CAcreateserial \
  -out "${i}.crt"
done
```

The above command will generate a private key, certificate request and signed SSL certificates for each of the kubernetes components.

## Distribute the Client and Server Certificates

TODO: Safe storage of certificates

In this section various certificates will be copied to every machine at a path where each kubernetes component will search for its certificate pair. In a real world environment these certificates should be treated like a set of sensitive secrets as they are used as credentials by the kubernetes components to authenticate to each other.

Copy the appropriate certificates and private keys to the `node-0` and `node-1` machines:
```bash
for host in node-0 node-1; do

  ssh -i vagrant/root-ssh-key/root_key root@${host} mkdir /var/lib/kubelet/

  scp -i vagrant/root-ssh-key/root_key certs/${host}.crt \
    root@${host}:/var/lib/kubelet/kubelet.crt

  scp -i vagrant/root-ssh-key/root_key certs/${host}.key \
    root@${host}:/var/lib/kubelet/kubelet.key
done
```

Copy the appropriate certificates and private keys to the `server` machines: 

```bash

scp -i vagrant/root-ssh-key/root_key \
  certs/ca.key certs/ca.crt \
  certs/kube-api-server.key certs/kube-api-server.crt \
  certs/service-accounts.key certs/service-accounts.crt \
  root@server:~/
```

> The `kube-proxy`, `kube-controller-manager`, `kube-scheduler`, and `kubelet` client certificates will be used to generate client authentication configuration files in the next lab.