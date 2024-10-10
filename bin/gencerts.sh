#!/bin/bash
TRUST_ANCHOR='rootCA'

CERT_DIR='/tmp/rhtpa/certs'
mkdir -p "$CERT_DIR"

cat > /tmp/rhtpa/certs/rootCA.cnf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = req_distinguished_name
x509_extensions    = v3_ca

[ req_distinguished_name ]
C  = US
ST = North Carolina
L  = Raleigh
O  = Red Hat Inc.
CN = Root CA

[ v3_ca ]
basicConstraints = CA:TRUE
keyUsage = digitalSignature, keyCertSign
EOF

cat > /tmp/rhtpa/certs/server.cnf <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
C  = US
ST = North Carolina
L  = Raleigh
O  = Red Hat Inc.
CN = 192.168.121.60  # Replace with your IP address

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 192.168.121.60  # Replace with your IP address
EOF

CERT_DIR='/tmp/rhtpa/certs'
mkdir -p "$CERT_DIR"

CERTS=(
    'trust-cert'
)

# Root Cert - Trust Anchor
openssl genpkey -algorithm RSA -out "${CERT_DIR}/${TRUST_ANCHOR}.key" -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -nodes -key "${CERT_DIR}/${TRUST_ANCHOR}.key" -sha256 -days 3650 -out "${CERT_DIR}/${TRUST_ANCHOR}.crt" -config /tmp/rhtpa/certs/rootCA.cnf

for certname in "${CERTS[@]}"; do
    rm -f "${CERT_DIR}/${certname}.key" "${CERT_DIR}/${certname}.crt"

    # Create the private key    
    openssl genpkey -algorithm RSA -out "${CERT_DIR}/${certname}.key" -pkeyopt rsa_keygen_bits:2048

    # Create the CSR
    openssl req -new -key "${CERT_DIR}/${certname}.key" -out "${CERT_DIR}/${certname}.csr" -config /tmp/rhtpa/certs/server.cnf

    # # Sign the CSR with the CA
    openssl x509 -req -in "${CERT_DIR}/${certname}.csr" -CA "${CERT_DIR}/${TRUST_ANCHOR}.crt" -CAkey "${CERT_DIR}/${TRUST_ANCHOR}.key" -CAcreateserial -out "${CERT_DIR}/${certname}.crt" -days 365 -extfile /tmp/rhtpa/certs/server.cnf -extensions req_ext

    # Remove the CSR file
    rm "${CERT_DIR}/${certname}.csr"
done

