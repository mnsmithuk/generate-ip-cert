#!/bin/sh

IP=$(echo $1 | egrep -o "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")

if [ ! $IP ]
then
    echo "Usage: generate-ip-cert.sh 127.0.0.1"
    exit 1
fi

echo "[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = $IP: Self-signed certificate

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP
" > san.cnf

# Create PKCS#5 RSA private key
openssl genrsa -out key.pem 2048
# Create X.509 certificate
openssl req -x509 -nodes -days 730 -key key.pem -out cert.pem -config san.cnf
# Convert PKCS#5 RSA private key into a unencrypted PKCS#8 private key
openssl pkcs8 -in key.pem -topk8 -nocrypt -out pkcs8-key.pem -inform PEM -outform PEM

rm san.cnf
