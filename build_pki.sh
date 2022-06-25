#!/bin/bash -e

read -p "Inform the desired location for the Root Certificate Authority directory (e.g., /tmp/root-ca): " -r
echo ""

# Set Root CA environment
ROOT_CA_DIR=${REPLY}
mkdir ${ROOT_CA_DIR}
mkdir ${ROOT_CA_DIR}/newcerts
touch ${ROOT_CA_DIR}/index.txt
echo "01" > ${ROOT_CA_DIR}/serial
cp certificate_authorities/root-ca/root-ca.cnf ${ROOT_CA_DIR}/root-ca.cnf

sed -i "s|<ROOT_CA_DIR>|${ROOT_CA_DIR}|g" ${ROOT_CA_DIR}/root-ca.cnf

echo "Creating the Root CA self-signed certificate.."
openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -keyout ${ROOT_CA_DIR}/rootCA.key -out ${ROOT_CA_DIR}/rootCA.crt

echo ""
read -p "Do you want to set up an Intermediate Certificate Authority? [Y/n] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ""
    read -p "Inform the desired location for the Intermediate Certificate Authority directory (e.g., /tmp/int-ca): " -r
    
    # Set Intermediate CA environment
    INT_CA_DIR=${REPLY}
    mkdir ${INT_CA_DIR}
    mkdir ${INT_CA_DIR}/newcerts
    touch ${INT_CA_DIR}/index.txt
    echo "01" > ${INT_CA_DIR}/serial
    cp certificate_authorities/int-ca/int-ca.cnf ${INT_CA_DIR}/int-ca.cnf
    
    sed -i "s|<INT_CA_DIR>|${INT_CA_DIR}|g" ${INT_CA_DIR}/int-ca.cnf

    echo "Creating the Intermediate CA key and CSR to be signed by Root CA.."
    openssl req -new \
                -newkey rsa:2048 \
                -nodes \
                -keyout ${INT_CA_DIR}/intCA.key -out ${INT_CA_DIR}/intCA.csr

    echo ""
    echo "Signing Intermediate CSR with Root CA private key.."
    openssl ca -batch \
               -notext \
               -extensions v3_intermediate_ca \
               -config ${ROOT_CA_DIR}/root-ca.cnf \
               -in ${INT_CA_DIR}/intCA.csr \
               -out ${INT_CA_DIR}/intCA.crt
    
fi