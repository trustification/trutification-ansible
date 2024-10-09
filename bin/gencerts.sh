#!/bin/bash

SUBJ='/C=US/ST=North Carolina/L=Raleigh'
SUBJ+='/O=Red Hat Inc./OU=RHTPA'
CN='/CN=localhost' 
TRUST_ANCHOR='rootCA'

CERTS=(
    'bombastic-api-tls'
    'collector-osv-tls'
    'collector-osv-tls-client'
    'collectorist-api-tls'
    'collectorist-api-tls-csub'
    'guac-collectsub-tls'
    'guac-graphql-tls'
    'nginx-tls'
    'spog-api-tls'
    'vexination-api-tls'
)


cat > /tmp/rhtpa/certs/openssl.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = 192.168.121.60

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
IP.1 = 192.168.121.60
EOF

CERT_DIR='/tmp/rhtpa/certs'
mkdir -p "$CERT_DIR"

# Trust Anchor
openssl genpkey -algorithm RSA -out "${CERT_DIR}/${TRUST_ANCHOR}.key" -outform PEM -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -nodes -key "${CERT_DIR}/${TRUST_ANCHOR}.key" -sha256 -days 3650 -out "${CERT_DIR}/${TRUST_ANCHOR}.crt" -subj "${SUBJ}/CN=RTHTPA Root CA"

for certname in "${CERTS[@]}"; do
    rm -f "${CERT_DIR}/${certname}.key" "${CERT_DIR}/${certname}.crt"
    
    # Create the private key
    openssl genpkey -algorithm RSA -out "${CERT_DIR}/${certname}.key" -outform PEM -pkeyopt rsa_keygen_bits:2048

    # # Create the CSR
    openssl req -new -key "${CERT_DIR}/${certname}.key" -out "${CERT_DIR}/${certname}.csr" -subj "${SUBJ}/CN=${certname}" -config /tmp/rhtpa/certs/openssl.cnf

    # # Sign the CSR with the CA
    openssl x509 -req -in "${CERT_DIR}/${certname}.csr" -CA "${CERT_DIR}/${TRUST_ANCHOR}.crt" -CAkey "${CERT_DIR}/${TRUST_ANCHOR}.key" -CAcreateserial -out "${CERT_DIR}/${certname}.crt" -days 825 -sha256

    # Remove the CSR file
    rm "${CERT_DIR}/${certname}.csr"
done

# Remove the CA serial file
rm "${CERT_DIR}/${TRUST_ANCHOR}.srl"
