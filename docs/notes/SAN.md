# SAN - subject alertnative names

SAN is extra hostname or IP addresses that the certificate is allow to represent.

For example:
```bash
[kube-api-server]
distinguished_name = kube-api-server_distinguished_name
prompt             = no
req_extensions     = kube-api-server_req_extensions

[kube-api-server_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client, server
nsComment            = "Kube API Server Certificate"
subjectAltName       = @kube-api-server_alt_names
subjectKeyIdentifier = hash

[kube-api-server_alt_names]
IP.0  = 127.0.0.1
IP.1  = 10.32.0.1
DNS.0 = kubernetes
DNS.1 = kubernetes.default
DNS.2 = kubernetes.default.svc
DNS.3 = kubernetes.default.svc.cluster
DNS.4 = kubernetes.svc.cluster.local
DNS.5 = server.kubernetes.local
DNS.6 = api-server.kubernetes.local

[kube-api-server_distinguished_name]
CN = kubernetes
C  = IN
ST = Karnataka
L  = Bangalore
```

When client connects, it checks host name or ip against the SAN list. If there is no match the certificate is rejected, even if Common Name looks right.

---

# SAN vs CN (Common Name)

SAN is the one that matters in modern TLS hostname checks.

CN is legacy. In oldern OpenSSL and older TLS setups CN is expected to be the certificate's main identity. 

So CN here is mostly informational.