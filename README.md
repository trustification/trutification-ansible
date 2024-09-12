# trustification-ansible

Automation to deploy the Trustification project on RH OS family

:warning: **The contents of this repository are a Work in Progress.**

## Overview

The automation within this repository establishes the components of Trustification, the downstream redistribution of [Trustification project](https://github.com/trustification/trustification) within a single Red Hat Enterprise Linux (RHEL) or Fedora machine using a standalone containerized deployment. Containers are spawned using Kubernetes based manifests using
[podman kube play](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The following Trustification components are deployed as part of this architecture:

- [Trustification](https://github.com/trustification/trustification)
- [Guac](https://github.com/trustification/guac)

The following components are used if provided by the customers:

- RH Single Sign On
- RH Kafka streams
- Postgresql
- S3 or compatible service like Minio

Utilize the steps below to understand how to setup and execute the provisioning.

## Prerequisites

A RHEL 9.2+ server should be used to run the Trustification components.

Ansible must be installed and configured on a control node that will be used to perform the automation.

Perform the following steps to prepare the control node for execution.

### Dependencies

Install the required Ansible collections by executing the following

```shell
ansible-galaxy collection install -r requirements.yml
```

### OIDC provider

An installation of RH SSO/Keycloak/AWS Cognito must be provided to allow for integration with containerized Trustification.

## Provision

#### https://developer.hashicorp.com/vagrant/docs/provisioning/ansible

#### https://docs.ansible.com/ansible/2.9/scenario_guides/guide_vagrant.html

In order to deploy Trustification on a RHEL 9.2+ VM:

1. Create an `inventory.ini` file in the project with a single VM in the `trustification` group:

```
[trustification]
192.168.121.60 become=true

[trustification:vars]
ansible_user=vagrant
ansible_ssh_pass=vargrant
ansible_private_key_file=./vm-testing/images/rhel9-vm/.vagrant/machines/trustification/libvirt/private_key
```

2. Create `ansible.cfg` file in the project with a single VM in the `trustification` group:

```
[defaults]
inventory = ./inventory.ini
host_key_checking = False
```

3. Add the subscription, registry and certificates information :

- For Red Hat subscription define :
  export TPA_SINGLE_NODE_REGISTRATION_USERNAME=<Your Red Hat subscription username>
  export TPA_SINGLE_NODE_REGISTRATION_PASSWORD=<Your Red Hat subscription password>
- For Red Hat image registry define :
  export TPA_SINGLE_NODE_REGISTRY_USERNAME=<Your Red Hat image registry username>
  export TPA_SINGLE_NODE_REGISTRY_PASSWORD=<Your Red Hat image registry password>

# Todo - Remove ?

Alternatively vagrant will prompt for the registration username and password.

Provide TLS certificates :
export GUAC_CSUB_SECRET_FILE=./certificates/guac-collectsub-secret.yaml

# Todo - Give example how to generate secret manifest for TLS using kubectl or oc command

4. Create a simple Ansible playbook `play.yml`:

```
- hosts: trustification
  vars:
    base_hostname: TODO # e.g. example.com
    tpa_single_node_oidc_issuers: TODO # your OIDC provider (e.g. SSO/keycloak) URL
    tpa_single_node_issuer_url: TODO # your OIDC provider (e.g. SSO/keycloak) URL
  tasks:
    - name: Include TPA single node role
      ansible.builtin.include_role:
        name: tpa_single_node
```

5. Execute the following command (NOTE: you will have to provide credentials to authenticate to registry.redhat.io: https://access.redhat.com/RegistryAuthentication):

```shell
ANSIBLE_ROLES_PATH="roles/" ansible-playbook -i inventory.ini play.yml -vvvv -e registry_username='REGISTRY.REDHAT.IO_USERNAME' -e registry_password='REGISTRY.REDHAT.IO_PASSWORD'
```

## Contributing

### Testing Deployment on a VM

The [vm-testing/README.md](vm-testing/README.md) file contains instructions on testing the deployment on a VM. Right now, only Vagrant and libvirt are supported as testing VM provisioner.

## Feedback

Any and all feedback is welcome. Submit an [Issue](https://github.com/trustification/trustification-ansible/issues) or [Pull Request](https://github.com/trustification/trustification-ansible/pulls) as desired.
