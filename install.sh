#!/bin/bash -e

# Setup the ca-test-env systemd service
# Create systemd configuration directory for the service
if [ ! -d /etc/systemd/ca-test-env ]
then
    sudo mkdir /etc/systemd/ca-test-env
fi

sudo cp ca-test-env.conf /etc/systemd/ca-test-env/
sudo cp services/ca-test-env/ca-test-env.sh /etc/systemd/ca-test-env/
sudo cp -r certificate_authorities/ /etc/systemd/ca-test-env/

# Install and reload the service
sudo cp services/ca-test-env/ca-test-env.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start ca-test-env.service