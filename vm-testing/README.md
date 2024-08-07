# VM testing

This directory contains tooling to (manually) test the collection using Vagrant.

General prerequisites:
```
dnf install @virtualization @vagrant libvirt-devel
systemctl enable --now virtqemud.service
systemctl enable --now virtnetworkd.service
usermod -aG libvirt $USER
loginctl terminate-user $USER
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-registration
systemctl enable --now libvirtd
systemctl restart libvirtd
```

## Vagrant
First setup
```
cd images/rhel9-vm
vagrant up
```
If you haven't provided the subscription details on the Vagrantfile, or as a env variables
during the startup will be asked you RH username and password to enable the repos on RHEL.
Without can't be installed podman and the other libs.
```
==> trustification: Registering box with vagrant-registration...
trustification: Would you like to register the system now (default: yes)? [y|n]y
trustification: username: <your subscription username>
trustification: password: <your subscription password>
```
To enter in the running instance
```
vagrant ssh-config
vagrant ssh
hostnamectl
ansible all -m ping
```

Stop
This unregister and stop your instance
```
vagrant halt
```

Destroy
```
vagrant destroy
```

Reload
```
vagrant reload --provision
```

## Ansible 
From the root of the project



