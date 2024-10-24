# Opentofu scripts to deploy AWS services for Trustification, including RDS, SQS, S3 and Cognito:

Note the dbms password is hard coded for now because we're not storing it in kubernetes secret anymore
This is a quick dirty solution, ultimately we could use AWS Secret manager, leave it to be set in RDS console.

# Get started

Setup your aws profile or use default (~/.aws/config and ~/.aws/credentials)

```sh
$ cat ~/.aws/config
[profile gildub]
region = eu-west-1
output = json
```

```sh
$ cat ~/.aws/credentials
[gildub]
aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Create an AWS VPC and replace the vpc id in main.tf

Replace any variable in maint.tf to fit your needs such as `environment`, `region`, `sso-domain`, `app-domain`, `admin-email` and `availability-zone`.

Finally replace private subnets ids in trustification/database.tf
The latter is a temporary workaround until automated)

# init

tofu init

# Prepare for deployment

tofu plan

# Deploy or redeploy (idempotent)

tofu apply

# Erase environment, will remove all components on AWS, make sure to do it before removing `terrraform*` files

tofu destroy

# Once RDS instance is created

Add missing security groups to RDS instance.

# For example : terraform-XXXXXXXXXXXXXXX1 (inbound), terraform-XXXXXXXXXXXXXXX2 (Outbound) and trustification-postgresql-gildub

# NOTES

## In case RHTPA admin password needs to (re)set

aws cognito-idp admin-set-user-password --user-pool-id eu-west-1_xd6z5R2I6 --username admin --password Passwd1234! --permanent

## How to install trustification in the cluster https://docs.staging.trustification.dev/trustification/admin/cluster-prereq.html

# Reset RDS Postgres main password
aws rds modify-db-instance --db-instance-identifier <your-db-instance-id> --master-user-password <new-password>  --apply-immediately
