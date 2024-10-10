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

For development purpose, the TLS certs can be generated with the script located on `./bin/gencerts.sh` 

Run this script from the parent directory with command
```
sh ./bin/gencerts.sh
```

This will create self-signed certs under `/tmp/rhtpa/certs/` directory which is default value for `tpa_single_node_certificates_dir` variable

Once the file is generated, copy the file to client machine from where the application is accessed.

Linux:

```
sudo cp rootCA.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```