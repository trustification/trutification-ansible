# Red Hat Trusted Profile Analyzer Ansible collection

The purpose of this Ansible collection is to automate the deployment of the Red Hat Trusted Profile Analyzer (RHTPA) service on Red Hat Enterprise Linux (RHEL).

> [!IMPORTANT]
Deploying RHTPA by using Ansible is a Technology Preview feature only.
Technology Preview features are not supported with Red Hat production service level agreements (SLAs), might not be functionally complete, and Red Hat does not recommend to use them for production.
These features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process.
See the support scope for [Red Hat Technology Preview](https://access.redhat.com/support/offerings/techpreview/) features for more details.


## Description

The RHTPA service is the downstream redistribution of the [Trustification](https://github.com/trustification/trustification) project.
The automation contained within this Git repository installs and configures the components of RHTPA to run on a single RHEL server, which uses a standalone containerized deployment.
A Kubernetes-based manifest creates containers that uses [`podman kube play`](https://docs.podman.io/en/latest/markdown/podman-kube-play.1.html).

The RHTPA Ansible collection deploys the following RHTPA components:

- [Trustification](https://github.com/trustification/trustification)
- [Guac](https://github.com/trustification/guac)

An [NGINX](https://www.nginx.com) front end places an entrypoint to the RHTPA UI.
A set of self-signed certificates get generated at runtime to establishing secure communications.

The ingress host name is follow, where `<base_hostname>` is your deployment's base hostname:
* https://`<base_hostname>`

## Requirements

* Ansible 2.16.0 or greater
* Python 3.9.0 or greater
* RHEL x86\_64 9.3 or greater.
* Installation and configuration of Ansible on a control node to perform the automation.
* Installation of the Ansible collections on the control node.
  * If installing from the Ansible Automation Hub, then run `ansible-galaxy install redhat.trusted_profile_analyzer`.
  * If installing from this Git repository, then clone it locally, and run `ansible-galaxy collection install -r requirements.yml`.
* An OpenID Connect (OIDC) provider, such as [Keycloak](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/sso/).
* A PostgreSQL instance
* SQS like [Kafka](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/amq_streams/)
* S3 service or S3 compatible service
* Optional:
  Installation of the `podman` binaries to verify that the RHTPA service is working as expected.

## Overview
The following components are provided by the customers:

### RedHat Single Sign On
  For this, you will need to:

  * Install Keycloak
  * Create a new realm
  * Create the following roles for this realm
   * `chicken-user`
   * `chicken-manager`
   * `chicken-admin`
  * Make the `chicken-user` a default role
  * Create the following scopes for this realm
    * `read:document`
    * `create:document`
    * `delete:document`
  * Add the `create:document` and `delete:document` scope to the `chicken-manager` role
  * Create two clients
    *  One public client
        * Set `standardFlowEnabled` to `true`
        * Set `fullScopedAllowed` to `true`
        * Set the following `defaultClientScopes`
          * `read:document`
          * `create:document`
          * `delete:document`
    * One protected client  
        * Set `publicClient` to `false`
        * Set `serviecAccountsEnabled` to `true`
        * Set `fullScopedAllowed` to `true`
        * Set the following `defaultClientScopes`
          * `read:document`
          * `create:document`
        * Add role `chicken-manager` to the service account of this client
    * Increase the token timeout for both clients to at least 5 minutes
    * Create a user, acting as administrator
    * Add the `chicken-manager` and `chicken-admin` role to this user



### RedHat Kafka streams  
  With the following topic names created:
```
  bombastic-failed-default
  bombastic-indexed-default
  bombastic-stored-default
  vexination-failed-default
  vexination-indexed-default
  vexination-stored-default
  v11y-failed-default
  v11y-indexed-default
  v11y-stored-default
```
configured in the main.yml

### Postgresql

Create a PostgreSQL database and configure your database credentials in the  environment variables, see 'Verifying the deployment section', 
other database configurations are in the roles/tpa_single_node/vars/main.yml

### S3 or S3 compatible service like Minio
  Have the following unversioned S3 bucket names created:
  ```
  bombastic-default
  vexination-default
  v11y-default 
  ```
  configured in the main.yml


*  Details about how to configure the services can be found here [RHTPA external services deploy](https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/1/html-single/deployment_guide/index#installing-trusted-profile-analyzer-by-using-helm-with-other-services_deploy)
* [Trustification](https://github.com/trustification/trustification/blob/main/docs/modules/admin/pages/cluster-preparing.adoc)




Utilize the steps below to understand how to setup and execute the provisioning.

## Installation


Before using this collection, you need to install it with the Ansible Galaxy command-line tool:

```
ansible-galaxy collection install redhat.trusted_profile_analyzer
```

You can also include it in a `requirements.yml` file and install it with `ansible-galaxy collection install -r requirements.yml`, using the format:


```yaml
collections:
  - name: redhat.trusted_profile_analyzer
```

Note that if you install any collections from Ansible Galaxy, they will not be upgraded automatically when you upgrade the Ansible package.
To upgrade the collection to the latest available version, run the following command:

```
ansible-galaxy collection install redhat.trusted_profile_analyzer --upgrade
```

You can also install a specific version of the collection, for example, if you need to downgrade when something is broken in the latest version (please report an issue in this repository). Use the following syntax to install version 1.2.0:

```
ansible-galaxy collection install redhat.trusted_profile_analyzer:==1.2.0
```

## Verifying the deployment

1. Export the following environment variables, replacing `TODO` with your relevant information:

   ```shell
      export TPA_SINGLE_NODE_REGISTRATION_USERNAME=<Your Red Hat subscription username>
      export TPA_SINGLE_NODE_REGISTRATION_PASSWORD=<Your Red Hat subscription password>
      export TPA_SINGLE_NODE_REGISTRY_USERNAME=<Your Red Hat image registry username>
      export TPA_SINGLE_NODE_REGISTRY_PASSWORD=<Your Red Hat image registry password>
      export TPA_PG_HOST=<POSTGRES_HOST_IP>
      export TPA_PG_USER=<DB_USER>
      export TPA_PG_PASSWORD==<DB_PASSWORD>
      export TPA_STORAGE_ACCESS_KEY=<Storage Access Key>
      export TPA_STORAGE_SECRET_KEY=<Storage Secret Key>
      export TPA_OIDC_ISSUER_URL=<AWS Cognito or Keycloak Issuer URL. Incase of Keycloak endpoint auth/realms/chicken is needed>
      export TPA_OIDC_FRONTEND_ID=<OIDC Frontend Id>
      export TPA_OIDC_PROVIDER_CLIENT_ID=<OIDC Walker Id>
      export TPA_OIDC_PROVIDER_CLIENT_SECRET=<OIDC Walker Secret>
      export TPA_EVENT_ACCESS_KEY_ID=<Kafka Username or AWS SQS Access Key>
      export TPA_EVENT_SECRET_ACCESS_KEY=<Kafka User Password or AWS SQS Secret Key>
   ```
2. In case of Kafka Events, create environmental variable for bootstrap server
```shell
export TPA_EVENT_BOOTSTRAP_SERVER=<Kafka Bootstrap Server>
```

3. In case of AWS Cognito as OIDC, create environmental variable for Cognito Domain
```shell
export TPA_OIDC_COGNITO_DOMAIN=<AWS Cognito Domain>
```

4. Open the browser to call the UI
   https://`<base_hostname>`










## Prerequisites

A RHEL 9.3+ server should be used to run the Trustification components.

Ansible must be installed and configured on a control node that will be used to perform the automation.

Perform the following steps to prepare the control node for execution.

### Dependencies

Install the required Ansible collections by executing the following

```shell
ansible-galaxy collection install -r requirements.yml
```

### OIDC provider

An installation of Red Hat SSO/Keycloak/AWS Cognito must be provided to allow for integration with containerized Trustification.

## Provision

#### https://developer.hashicorp.com/vagrant/docs/provisioning/ansible

#### https://docs.ansible.com/ansible/2.9/scenario_guides/guide_vagrant.html

In order to deploy Trustification on a RHEL 9.3+ VM:

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
  ```
  export TPA_SINGLE_NODE_REGISTRATION_USERNAME=<Your Red Hat subscription username>
  export TPA_SINGLE_NODE_REGISTRATION_PASSWORD=<Your Red Hat subscription password>
  ```
- For Red Hat image registry define :
  ```
  export TPA_SINGLE_NODE_REGISTRY_USERNAME=<Your Red Hat image registry username>
  export TPA_SINGLE_NODE_REGISTRY_PASSWORD=<Your Red Hat image registry password>
  ```

Alternatively vagrant will prompt you to provide the registration username and password.

4. Path for TLS certificates files:

Copy your certificate files in `certs/` directory using following names:

- trust-cert.crt
- trust-cert.key
- rootCA.crt

Optionally, the certs directory variable `tpa_single_node_certificates_dir` under `roles/tpa_single_node/vars/main.yml` file can also be updated with a directory certs for below variables:

- tpa_single_node_root_ca

- tpa_single_node_trust_cert_tls_crt_path
- tpa_single_node_trust_cert_tls_key_path
- tpa_single_node_nginx_tls_crt_path
- tpa_single_node_nginx_tls_key_path

5. Create Environment Variables for Storage, Events and OIDC

```
export TPA_PG_HOST=<POSTGRES_HOST_IP>
export TPA_PG_USER=<DB_USER>
export TPA_PG_PASSWORD==<DB_PASSWORD>
export TPA_STORAGE_ACCESS_KEY=<Storage Access Key>
export TPA_STORAGE_SECRET_KEY=<Storage Secret Key>
export TPA_OIDC_ISSUER_URL=<AWS Cognito or Keycloak Issuer URL. Incase of Keycloak endpoint auth/realms/chicken is needed>
export TPA_OIDC_FRONTEND_ID=<OIDC Frontend Id>
export TPA_OIDC_PROVIDER_CLIENT_ID=<OIDC Walker Id>
export TPA_OIDC_PROVIDER_CLIENT_SECRET=<OIDC Walker Secret>
export TPA_EVENT_ACCESS_KEY_ID=<Kafka Username or AWS SQS Access Key>
export TPA_EVENT_SECRET_ACCESS_KEY=<Kafka User Password or AWS SQS Secret Key>
export TPA_STORAGE_ENDPOINT = <Minio storage URL >
```

6. In case of Kafka Events, create environmental variable for bootstrap server

```
export TPA_EVENT_BOOTSTRAP_SERVER=<Kafka Bootstrap Server>
```

7. In case of AWS Cognito as OIDC, create environmental variable for Cognito Domain

```
export TPA_OIDC_COGNITO_DOMAIN=<AWS Cognito Domain>
```

8. Update `roles/tpa_single_node/vars/main.yml` file with the below values,

- Storage Service:

  1. Update the Storage type, eithe `s3` or `minio`
  2. Update the S3/Minio bucket names
  3. Update the AWS region for AWS S3 or keep `us-west-1` for minio
  4. In case of minio, update minio storage end point `tpa_single_node_storage_endpoint`

- SQS Service:
  1. Update the Event bus type, either `kafka` or `sqs`
  2. Update the topics for each events
  3. In case of Kafka, update the fields `tpa_single_node_kafka_security_protocol` and `tpa_single_node_kafka_auth_mechanism`
  4. In case of AWS SQS, update the AWS SQS region `tpa_single_node_sqs_region`

Refer `roles/tpa_single_node/vars/main_example_aws.yml` and `roles/tpa_single_node/vars/main_example_nonaws.yml`

9. Execute the following command (NOTE: you will have to provide credentials to authenticate to registry.redhat.io: https://access.redhat.com/RegistryAuthentication):

```shell
ANSIBLE_ROLES_PATH="roles/" ansible-playbook -i inventory.ini play.yml
```

## Contributing

### Testing Deployment on a VM

The [vm-testing/README.md](vm-testing/README.md) file contains instructions on testing the deployment on a VM. Right now, only Vagrant and libvirt are supported as testing VM provisioner.

## Feedback

Any and all feedback is welcome. Submit an [Issue](https://github.com/trustification/trustification-ansible/issues) or [Pull Request](https://github.com/trustification/trustification-ansible/pulls) as desired.
