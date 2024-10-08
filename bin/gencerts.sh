#!/bin/bash

SUBJ='/C=US/ST=North Carolina/L=Raleigh'
SUBJ+='/O=Red Hat Inc./OU=RHTPA'

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

mkdir -p certs
cd certs

# Trust Anchor
openssl genpkey -algorithm RSA -out rootCA.key -aes256 -pass pass:passwd123 -outform PEM -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt -passin pass:passwd123 -subj "${SUBJ}/CN=RTHTPA Example Root CA"

for certname in "${CERTS[@]}"; do
    rm -f "${certname}.key" "${certname}.crt"
    
    # Create the private key
    openssl genpkey -algorithm RSA -out "${certname}.key" -aes256 -pass pass:passwd123 -outform PEM -pkeyopt rsa_keygen_bits:2048

    # # Create the CSR
    openssl req -new -key "${certname}.key" -out ${certname}.csr -passin pass:passwd123 -subj "${SUBJ}/CN=${certname}"

    # # Sign the CSR with the CA
    openssl x509 -req -in "${certname}.csr" -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out "${certname}.crt" -days 825 -sha256 -passin pass:passwd123

    # Remove the CSR
    rm "${certname}.csr"
done

# Remove the CA serial file
rm rootCA.srl
