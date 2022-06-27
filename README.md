# CA Test Env

Create your own Certificate Authority test environment. This project makes use of a systemd service to setup a PKI infrastructure.

## Getting Started

First, clone this repo and access the created directory:
```bash
git clone https://github.com/hsoulsboy/ca-test-env
cd ca-test-env/
```

Now, edit `ca-test-env.conf` configuration file with the desired values for your PKI. The file has the following fields:
```
- pki_application_directory: Directory where your PKI infrastructure will be deployed, e.g., /tmp/froogle-pki
- configure_intermediate_ca: Boolean value for if you either want to setup an Intermediate CA along with the Root CA or not, e.g., True
- root_country: Country name for the Root CA certificate, e.g., "US"
- root_state_or_province: State or Province name for the Root CA certificate, e.g., "CA"
- root_locality: City name for the Root CA certificate, e.g., "Mountain View"
- root_organization_name: Organization name for the Root CA certificate, e.g., "Froogle"
- root_organizational_unit: Organizational Unit name for the Root CA certificate, e.g., "IT"
- root_common_name: Common Name for the Root CA certificate, e.g., "Froogle-Root-CA"
- intermediate_country: Country name for the Intermediate CA certificate, e.g., "US"
- intermediate_state_or_province: State or Province name for the Intermediate CA certificate, e.g., "CA"
- intermediate_locality: City name for the Intermediate CA certificate, e.g., "Mountain View"
- intermediate_organization_name: Organization name for the Intermediate CA certificate, e.g., "Froogle"
- intermediate_organizational_unit: Organizational Unit name for the Intermediate CA certificate, e.g., "IT"
- intermediate_common_nam: Common Name for the Intermediate CA certificate, e.g., "Froogle-Int-CA"
```

After finishing your PKI configuration, install the service:
```bash
sudo ./install.sh
```

There you have it! Now you have a Root and an Intermediate CA inside your `$pki_application_directory`. You can check both certificates contents with:
```bash
openssl -in $pki_application_directory/rootCA/rootCA.crt -text -noout
openssl -in $pki_application_directory/intCA/intCA.crt -text -noout
```

If you want to deploy another PKI or overwrite your last one, edit `ca-test-env.conf` with the new values and stop the service:
```bash
sudo systemctl stop ca-test-env.service
```

Then, install it once more:
```bash
sudo ./install.sh
```
