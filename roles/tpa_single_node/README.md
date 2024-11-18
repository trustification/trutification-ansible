<!--- to update this file, update files in the role's meta/ directory (and/or its README.j2 template) and run "make role-readme" -->
# Ansible Role: redhat.trusted_profile_analyzer.tpa_single_node
Version: 1.2.0

Deploy the [RHTPA](https://docs.redhat.com/en/documentation/red_hat_trusted_profile_analyzer/) service on a single managed node by using the `tpa_single_node` role.
 Requires RHEL 9.3 or later.

## Role Arguments
### Required
|Option|Description|Type|Default|
|---|---|---|---|
| tpa_single_node_pg_admin | DB admin user. | str |  |
| tpa_single_node_pg_admin_passwd | DB admin password. | str |  |
| tpa_single_node_pg_user | DB user. | str |  |
| tpa_single_node_pg_user_passwd | DB user password. | str |  |
| tpa_single_node_storage_access_key | Storage access key, readed form the env var TPA_STORAGE_ACCESS_KEY. | str |  |
| tpa_single_node_storage_secret_key | Storage access key, readed form the env var TPA_STORAGE_SECRET_KEY. | str |  |
| tpa_single_node_event_access_key_id | Kafka Username or AWS SQS Access Key ID, readed from TPA_EVENT_ACCESS_KEY_ID env var | str |  |
| tpa_single_node_event_secret_access_key | Kafka password or AWS SQS Secret Access Key, readed from TPA_EVENT_SECRET_ACCESS_KEY env var | str |  |
| tpa_single_node_root_ca | rootCA path on the controller machine | str |  |
| tpa_single_node_trust_cert_tls_crt_path | pem path on the controller machine | str |  |
| tpa_single_node_trust_cert_tls_key_path | key path on the controller machine | str |  |
| tpa_single_node_nginx_tls_crt_path | nginx-tls-certificate.pem path on the controller machine | str |  |
| tpa_single_node_nginx_tls_key_path | nginx-tls.key path on the controller machine | str |  |

### Optional
|Option|Description|Type|Default|
|---|---|---|---|
| tpa_single_node_trustification_image | Trustification image. | str |  `registry.redhat.io/rhtpa/rhtpa-trustification-service-rhel9:5f4dd4a048a212bdb17eedf6613af80df227efd1`  |
| tpa_single_node_guac_image | Guac image. | str |  `registry.redhat.io/rhtpa/rhtpa-guac-rhel9:7adca20ee17df2d863354c1861b31f47948d8839`  |
| tpa_single_node_base_hostname | The user name logging in to the registry to pull images. | str |  `trustification`  |
| tpa_single_node_rhel_host | Ip of the instance. | str |  |
| tpa_single_node_certificates_dir | Folder where to place the certificates to deploy on the instance. | str |  `certs`  |
| tpa_single_node_config_dir | Configuration directory on the instance. | str |  `/etc/rhtpa`  |
| tpa_single_node_kube_manifest_dir | Configuration directory on the instance containing the manifests. | str |  `/etc/rhtpa/manifests`  |
| tpa_single_node_namespace | Podman network namespace. | str |  `trustification`  |
| tpa_single_node_podman_network | Podman network name. | str |  `tcnet`  |
| tpa_single_node_systemd_directory | Folder where to store the systemd configurations files. | str |  `/etc/systemd/system`  |
| tpa_single_node_default_empty | Default empty value. | str |  |
| tpa_single_node_pg_host | Host ip of the postgresql db instance. Readed from the TPA_PG_HOST env | str |  |
| tpa_single_node_pg_port | Port of the postgresql db instance. | str |  `5432`  |
| tpa_single_node_pg_db | DB name. | str |  `guac`  |
| tpa_single_node_pg_ssl_mode | DB SSL mode require/disabled. | str |  `disable`  |
| tpa_single_node_storage_type | Storage type s3/minio/other s3 compatible. | str |  `minio`  |
| tpa_single_node_storage_bombastic_bucket | Bombastic storage bucket name. | str |  `bombastic-default`  |
| tpa_single_node_storage_v11y_bucket | V11y storage bucket name. | str |  `v11y-default`  |
| tpa_single_node_storage_vexination_bucket | V11y storage bucket name. | str |  `vexination-default`  |
| tpa_single_node_storage_region | AWS S3 Storage region | str |  `eu-west-1`  |
| tpa_single_node_storage_endpoint | Minio storage endpoint if used instead of S3 | str |  `eu-west-1`  |
| tpa_single_node_event_bus_type | Kafka or SQS | str |  `kafka`  |
| tpa_single_node_bombastic_topic_failed | Bombastic Events topic failed | str |  `bombastic-failed-default`  |
| tpa_single_node_bombastic_topic_indexed | Bombastic Events topic indexed | str |  `bombastic-indexed-default`  |
| tpa_single_node_bombastic_topic_stored | Bombastic Events topic stored | str |  `bombastic-stored-default`  |
| tpa_single_node_vexination_topic_failed | Vexination Events topic failed | str |  `vexination-failed-default`  |
| tpa_single_node_vexination_topic_indexed | Vexination Events topic indexed | str |  `vexination-indexed-default`  |
| tpa_single_node_vexination_topic_stored | Vexination Events topic stored | str |  `vexination-stored-default`  |
| tpa_single_node_v11y_topic_failed | V11y Events topic failed | str |  `vv1y-failed-default`  |
| tpa_single_node_v11y_topic_indexed | V11y Events topic indexed | str |  `v11y-indexed-default`  |
| tpa_single_node_v11y_topic_stored | V11y Events topic stored | str |  `v11y-stored-default`  |
| tpa_single_node_kafka_bootstrap_servers | Kafka bootstrap servers readed from TPA_EVENT_BOOTSTRAP_SERVER env var | str |  |
| tpa_single_node_kafka_security_protocol | Kafka security protocol | str |  `SASL_PLAINTEXT`  |
| tpa_single_node_kafka_auth_mechanism | Kafka auth mechanism | str |  `SCRAM-SHA-512`  |
| tpa_single_node_sqs_region | AWS SQS Region | str |  `eu-west-1`  |
| tpa_single_node_oidc_type | Keycloak or AWS Cognito | str |  `keycloak`  |
| tpa_single_node_oidc_issuer_url | Readed from TPA_OIDC_ISSUER_URL env var | str |  |
| tpa_single_node_oidc_frontend_id | Readed from TPA_OIDC_FRONTEND_ID env var | str |  |
| tpa_single_node_oidc_provider_client_id | Readed from TPA_OIDC_PROVIDER_CLIENT_ID env var | str |  |
| tpa_single_node_oidc_provider_client_secret | Readed from TPA_OIDC_PROVIDER_CLIENT_SECRET env var | str |  |
| tpa_single_node_aws_cognito_domain | Readed from TPA_OIDC_COGNITO_DOMAIN env var | str |  |
| tpa_single_node_storage_secret | storage-secret.yaml path on the target machine | str |  `/etc/rhtpa/manifests/storage-secret.yaml`  |
| tpa_single_node_event_secret | event-secret.yaml path on the target machine | str |  `/etc/rhtpa/manifests/event-secret.yaml`  |
| tpa_single_node_oidc_secret | oidc-secret.yaml path on the target machine | str |  `/etc/rhtpa/manifests/oidc-secret.yaml`  |
| tpa_single_node_spog_ui_port | Spog ui port | int |  `8080`  |
| tpa_single_node_vexination_api_port | Vexination api port | int |  `8081`  |
| tpa_single_node_bombastic_api_port | Bombastic api port | int |  `8082`  |
| tpa_single_node_spog_api_port | Spog api port | int |  `8084`  |
| tpa_single_node_collector_osv_port | Collector OSV api port | int |  `8085`  |
| tpa_single_node_v11y_api_port | V11y api port | int |  `8087`  |
| tpa_single_node_collectorist_api_port | Collectorist api port | int |  `8088`  |
| tpa_single_node_guac_graphql_port | Guac GraphQl port | int |  `8089`  |
| tpa_single_node_bombastic_walker_suspended | Bombastic walker suspended flag | bool |  `True`  |
| tpa_single_node_dataset_job_suspended | Dataset job suspended flag | bool |  `True`  |
| tpa_single_node_vexination_walker_suspended | Vexination walker job suspended flag | bool |  `True`  |
| tpa_single_node_v11y_walker_suspended | V11y walker job suspended flag | bool |  `False`  |

## Example Playbook

```
- hosts: rhtpa
  vars:
    tpa_single_node_pg_admin: # TODO: required, type: str
    tpa_single_node_pg_admin_passwd: # TODO: required, type: str
    tpa_single_node_pg_user: # TODO: required, type: str
    tpa_single_node_pg_user_passwd: # TODO: required, type: str
    tpa_single_node_storage_access_key: # TODO: required, type: str
    tpa_single_node_storage_secret_key: # TODO: required, type: str
    tpa_single_node_event_access_key_id: # TODO: required, type: str
    tpa_single_node_event_secret_access_key: # TODO: required, type: str
    tpa_single_node_root_ca: # TODO: required, type: str
    tpa_single_node_trust_cert_tls_crt_path: # TODO: required, type: str
    tpa_single_node_trust_cert_tls_key_path: # TODO: required, type: str
    tpa_single_node_nginx_tls_crt_path: # TODO: required, type: str
    tpa_single_node_nginx_tls_key_path: # TODO: required, type: str
    
  tasks:
    - name: Include TPA single node role
      ansible.builtin.include_role:
        name: redhat.trusted_profile_analyzer.tpa_single_node
      vars:
        ansible_become: true
```

## License

Apache-2.0

## Author and Project Information

Red Hat
