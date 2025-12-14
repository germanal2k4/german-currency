#!/bin/bash

# Script to generate self-signed TLS certificates for muffin-wallet

DOMAIN="muffin-wallet.com"
CERT_DIR="./tls-certs"
KEY_FILE="${CERT_DIR}/tls.key"
CERT_FILE="${CERT_DIR}/tls.crt"

mkdir -p ${CERT_DIR}

# Generate private key
openssl genrsa -out ${KEY_FILE} 2048

# Generate certificate signing request
openssl req -new -key ${KEY_FILE} -out ${CERT_DIR}/tls.csr -subj "/CN=${DOMAIN}/O=muffin-wallet"

# Generate self-signed certificate
openssl x509 -req -days 365 -in ${CERT_DIR}/tls.csr -signkey ${KEY_FILE} -out ${CERT_FILE}

# Clean up CSR
rm ${CERT_DIR}/tls.csr

# Convert to base64 for Kubernetes Secret
echo ""
echo "Base64 encoded certificate (tls.crt):"
cat ${CERT_FILE} | base64 | tr -d '\n'
echo ""
echo ""
echo "Base64 encoded private key (tls.key):"
cat ${KEY_FILE} | base64 | tr -d '\n'
echo ""
echo ""
echo "Certificates generated in ${CERT_DIR}/"
echo "Add the base64 values to muffin-wallet/values.yaml under ingress.tls.certificate and ingress.tls.key"
