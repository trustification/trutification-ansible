# VM testing

This directory contains tooling to (manually) test the collection using Vagrant.

General prerequisites:
Vagrant 2.4.1 or later https://developer.hashicorp.com/vagrant/downloads

Run as admin

```
dnf install @virtualization @vagrant libvirt-devel
systemctl enable --now virtqemud.service
systemctl enable --now virtnetworkd.service
usermod -aG libvirt $USER
loginctl terminate-user $USER
```

Run as a normal user

```
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-registration
```

Run as admin

```
systemctl enable --now libvirtd
systemctl restart libvirtd
```

## Vagrant

First setup

```
cd rhel9-vm
vagrant up
```

If you haven't provided the subscription details as a env variables (see Vagranfile),
vagrant will ask for RH username and password in order to enable RHEL repos.
Without subscription the RHEL provisioning will fail.

```
==> trustification: Registering box with vagrant-registration...
trustification: Would you like to register the system now (default: yes)? [y|n]y
trustification: username: <your subscription username>
trustification: password: <your subscription password>
```

To Reload the configuration and execute again the playbook agains the vm

```
vagrant reload --provision
```

To enter in the running instance, automatically configured on the vagrant file

```
vagrant ssh
```

To see the networking configuration on the vm after the ssh login

```
hostnamectl
ansible all -m ping
```

Stop

```
vagrant halt
```

Destroy
This unregister your instance

```
vagrant destroy
```

All commands available

```
vagrant list-commands
```

## Ansible

From the root of the project

## TLS Certs

For development purposes, TLS certificates can be generated using the script located at `./bin/gencerts.sh`. This script utilizes OpenSSL to create the necessary certificates for secure communication.

Steps to Generate TLS Certificates:

 1. **Update IP Address**: If you are generating TLS certificates for virtual machines other than Vagrant, ensure to update the IP address within ./bin/gencerts.sh accordingly.

 2. **Run the Script**: Execute the script from the parent directory with the following command:
```
sh ./bin/gencerts.sh
```
 3. **Certificates to Client Machine**: After the certificate files are generated, you need to copy rootCA.crt to the client machine from which the application will be accessed. This step is crucial for establishing a trusted connection. This is needed for,
     - *Trust Establishment*: The client recognizes and trusts the server's TLS certificate, allowing for secure communication without warnings or errors about untrusted certificates.
     - *Secure Communication*: By adding rootCA.crt to the trusted certificate store, you mitigate potential man-in-the-middle attacks and ensure data integrity during transmission

For Linux Systems:
To install the `rootCA.crt`, execute the following commands:
```
sudo cp rootCA.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```
This will update the system's certificate store, enabling your applications to recognize the newly trusted root certificate


## Faq
Error at the vagrant startup
```
Name `rhel9-vm_trustification` of domain about to create is already taken. Please try to run
`vagrant up` command again.
```

Open the Virtual machine manager, or install if is not on the machine, and delete the image then run again ```vagrant up```