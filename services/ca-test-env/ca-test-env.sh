#!/bin/bash -e

# Read configuration file
if [ -f /etc/systemd/ca-test-env/ca-test-env.conf ]
then
    . /etc/systemd/ca-test-env/ca-test-env.conf
else
    echo "Couldn't find '/etc/systemd/ca-test-env/ca-test-env.conf'."
    echo "Exiting.."
    exit 1
fi

if [ $1 -eq 1 ]
then
    # Setup pki environment
    mkdir $pki_application_directory

    # Set Root CA environment
    ROOT_DIR=$pki_application_directory/rootCA
    mkdir -p $ROOT_DIR/newcerts
    mkdir -p $ROOT_DIR/index.txt
    echo "01" > $ROOT_DIR/serial
    cp /etc/systemd/ca-test-env/certificate_authorities/root-ca/root-ca.cnf $ROOT_DIR/root-ca.cnf
    sed -i "s|<ROOT_CA_DIR>|${ROOT_DIR}|g" $ROOT_DIR/root-ca.cnf

    # Create Root CA private key and certificate
    openssl req -x509 \
                -sha256 -days 356 \
                -nodes \
                -newkey rsa:2048 \
                -subj "/C=$root_country/ST=$root_state_or_province/L=$root_locality/O=$root_organization_name/OU=$root_organizational_unit/CN=$root_common_name" \
                -keyout $ROOT_DIR/rootCA.key -out $ROOT_DIR/rootCA.crt

    if [ $configure_intermediate_ca = True ]
    then
        # Set Intermediate CA environment
        INT_DIR=$pki_application_directory/intCA
        mkdir -p $INT_DIR/newcerts
        mkdir -p $INT_DIR/index.txt
        echo "01" > $INT_DIR/serial
        cp /etc/systemd/ca-test-env/certificate_authorities/int-ca/int-ca.cnf $INT_DIR/int-ca.cnf
        sed -i "s|<INT_CA_DIR>|${INT_DIR}|g" $INT_DIR/int-ca.cnf

        # Create the Intermediate CA key and CSR to be signed by Root CA
        openssl req -new \
                    -newkey rsa:2048 \
                    -nodes \
                    -subj "/C=$intermediate_country/ST=$intermediate_state_or_province/L=$intermediate_locality/O=$intermediate_organization_name/OU=$intermediate_organizational_unit/CN=$intermediate_common_name" \
                    -keyout $INT_DIR/intCA.key -out $INT_DIR/intCA.csr

        # Sign the Intermediate CSR with Root CA private key
        openssl ca -batch \
                   -notext \
                   -extensions v3_intermediate_ca \
                   -config $ROOT_DIR/root-ca.cnf \
                   -in $INT_DIR/intCA.csr \
                   -out $INT_DIR/intCA.crt

    fi
elif [ $1 -eq 2 ]
then
    sudo rm -r $pki_application_directory
else
    exit 1
fi