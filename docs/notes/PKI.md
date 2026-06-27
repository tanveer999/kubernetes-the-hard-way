# PKI - Public key infrastructure

PKI - A public key infrastructure (PKI) is a framework that enables secure communication and authentication over the internet.
PKI uses cryptographic keys and digital certificates to prove identities and encrypt data so that only the intended recipient can read it.

## How it works

PKI is asymmetric cryptography.
There are 2 keys:
1. Public Key: This is available to everyone. It is used to encrypt data or to verify the digital signature
2. Private Key: This is kept strictly confidential and hidden by the owner. It is used to decrypt the data or to creat a digital signature


## Core components of PKI system

To ensure that keys can be trusted, PKI relies on a chain of trust built by several components:

- Certificate Authority (CA): The trusted third party (like DigiCert, Gobalsign or Let's Encrypt). The CA acts as a governing body. If it trusts an identity, it signs and issues a Digital certificate to them.

- Registration Authority (RA): The "background checker". The RA verifies the real-world identity of the user, device or organization requesting a certificate and tells the CA it is safe to issue one.

- Digital Certificates: The electronic document that binds a Public Key to a specific entity (like a website domain name, a person, or a company).

- Certificate Revocation List (CRL) / OCSP: A system used to track whether a certificate has been invalidated before its expiration date (for example, if a Private Key was stolen by a hacker)

- Central Directory: A secure location where cryptographic keys and certificates are stored and indexed

## Certificate creation steps

1. **Key Pair Generation**
    The applicant generates the key pair. The private key is securely stored and is never shared with anyone, not even the Certificate Authority (CA).

2. **Creating the Certificate Signing Request (CSR)**
    The applicant creates the file called CSR. This is like a formal application for the certificate.

    The CSR contains:
    - Applicant's public key (generated in Step 1)
    - Identifying details about the entity requesting the certificate (e.g., domain name, organization name, country, and location)
    - A digital signature created using the applicant's private key to prove they actually possess the matching key pair

3. **Submitting the CSR**
    The applicant sends the CSR file to a trusted Certificate Authority (CA), such as DigiCert. The private key safely remains with the applicant.

4. **Validating and Identity Proofing**
    The CA (through RA) verifies that the information in the CSR is true.

    The level of scrutiny depends on the type of certificate requested:
    - **Domain Validation (DV):** The CA checks if the applicant has administrative control over the domain name (usually by asking them to add a specific DNS record or upload a hidden file to their website).
    - **Organization Validation (OV):** The CA checks domain ownership and verifies that the organization is a legally registered business.
    - **Extended Validation (EV):** The highest level of trust. The CA conducts a thorough background check, verifying legal, physical, and operational existence.

5. **Certificate Creation and Signing**
    Once the CA is satisfied with the validation, they create the actual digital certificate.

    - The CA takes the applicant's public key and verified identity details and bundles them together
    - The CA sets an expiration date and adds other metadata
    - Finally, the CA hashes this data and signs it using the CA's own private key. This cryptographic signature tells the rest of the world, "We vouch for this identity."

6. **Issuance**
    The CA sends the completed, signed digital certificate back to the applicant.

7. **Installation and Deployment**
    The applicant installs the newly issued digital certificate on their server, pairing it with the private key generated in Step 1. The server is now ready to establish secure, encrypted connections with anyone who connects to it.