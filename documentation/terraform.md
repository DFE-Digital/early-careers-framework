### Terraform setup
Instruction on setting up the Terraform CLI can be found on [their website](https://www.terraform.io/downloads.html)

### Creating a new Terraform environment
If we want to create a new long term environment, we need to create a new backing store for state.

We are using S3 buckets created through GovPaaS & Cloudfoundry to store terraform state.
In order to create a new bucket, you need to have the cloudfoundry cli installed and logged in to the GovPaaS account.

To create a new S3 bucket, run

```cf create-service aws-s3-bucket default dfe-ecf-terraform-state-<env>```

To create the access key, run

```cf create-service-key dfe-ecf-terraform-state-<env> terraform-state-key-<env> -c '{"allow_external_access": true}'```

To view the access key:

```cf service-key dfe-ecf-terraform-state-<env> terraform-state-key-<env>```

You should be able to see the bucket_name, aws_access_key_id and aws_secret_access_key. With these values, run

```terraform init -backend-config="bucket=<bucket_name>" -backend-config="access_key=<aws_access_key_id>" -backend-config="secret_key=<aws_secret_access_key>"```

### Running Terraform apply
```terraform apply --var-file=... -var='secret_paas_app_env_values={"GOVUK_NOTIFY_API_KEY":"...","SECRET_KEY_BASE":"..."}' -var='paas_user=...' -var='paas_password=...' -var='paas_app_docker_image=...'```