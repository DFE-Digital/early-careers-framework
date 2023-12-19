ifndef VERBOSE
.SILENT:
endif

SERVICE_SHORT=cpdecf

aks:  ## Sets environment variables for aks deployment
	$(eval PLATFORM=aks)
	$(eval REGION=UK South)
	$(eval KEY_VAULT_PURGE_PROTECTION=false)

.PHONY: review
review: aks test-cluster ## Specify review AKS environment
	# PULL_REQUEST_NUMBER is set by the GitHub action
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval include global_config/review_aks.sh)
	$(eval backend_config=-backend-config="key=terraform-$(PULL_REQUEST_NUMBER).tfstate")
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)$(SERVICE_SHORT)rv$(PULL_REQUEST_NUMBER)sa)

.PHONY: staging
staging: aks test-cluster
	$(eval include global_config/staging_aks.sh)

.PHONY: sandbox
sandbox: production-cluster
	$(eval include global_config/sandbox_aks.sh)
	$(eval SPACE=early-careers-framework-sandbox)

.PHONY: migration
migration: production-cluster
	$(eval include global_config/migration_aks.sh)

.PHONY: production
production: production-cluster
	$(eval include global_config/production_aks.sh)
	$(eval SPACE=early-careers-framework-prod)
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Production can only run with CONFIRM_PRODUCTION))

load-domain-config:
	$(eval include global_config/cpd_ecf_domain.sh)

set-azure-account:
	echo "Logging on to ${AZURE_SUBSCRIPTION}"
	az account set -s $(AZURE_SUBSCRIPTION)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Teacher Continuing Professional Development", "Parent Business":"Teacher Training and Qualifications", "Product" : "Early Careers Framework", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Manage training for early career teachers", "Environment" : "$(ENV_TAG)"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.6)

set-production-subscription:
	$(eval AZURE_SUBSCRIPTION=s189-teacher-services-cloud-production)

set-what-if:
	$(eval WHAT_IF=--what-if)

.PHONY: deploy-azure-resources
deploy-azure-resources: check-auto-approve arm-deployment # make dev deploy-azure-resources AUTO_APPROVE=1

.PHONY: validate-azure-resources
validate-azure-resources: set-what-if arm-deployment # make dev validate-azure-resources

check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

domain-azure-resources: load-domain-config set-azure-account set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${AZURE_RESOURCE_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
		"tfStorageAccountName=${AZURE_RESOURCE_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${AZURE_RESOURCE_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make validate-domain-resources AUTO_APPROVE=1

deploy-domain-resources: check-auto-approve domain-azure-resources # make deploy-domain-resources AUTO_APPROVE=1

domains-infra-init: load-domain-config set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: load-domain-config set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  # make dev domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init # make dev domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

arm-deployment: set-azure-account set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			keyVaultNames='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")' \
			"enableKVPurgeProtection=${KEY_VAULT_PURGE_PROTECTION}" ${WHAT_IF}
.PHONY: ci
ci:	## Run in automation environment
	$(eval SP_AUTH=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SKIP_CONFIRM=true)

.PHONY: terraform-init
terraform-init:
	$(if $(DOCKER_IMAGE), , $(error Missing environment variable "DOCKER_IMAGE"))

	$(eval export TF_VAR_docker_image=$(DOCKER_IMAGE))

	$(eval export TF_VAR_config_short=$(CONFIG_SHORT))
	$(eval export TF_VAR_service_short=$(SERVICE_SHORT))
	$(eval export TF_VAR_azure_resource_prefix=$(AZURE_RESOURCE_PREFIX))

	[[ "${SP_AUTH}" != "true" ]] && az account show && az account set -s $(AZURE_SUBSCRIPTION) || true
	terraform -chdir=terraform/aks init -backend-config workspace_variables/${CONFIG}_backend.tfvars $(backend_config) -upgrade -reconfigure

.PHONY: terraform-apply
terraform-apply: terraform-init
	terraform -chdir=terraform/aks apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

.PHONY: terraform-plan
terraform-plan: terraform-init
	terraform -chdir=terraform/aks plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

.PHONY: terraform-destroy
terraform-destroy: terraform-init
	terraform -chdir=terraform/aks destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}


## DOCKER_IMAGE=fake-image make review terraform-unlock PULL_REQUEST_NUMBER=4169 LOCK_ID=123456
## DOCKER_IMAGE=fake-image make staging terraform-unlock LOCK_ID=123456
.PHONY: terraform-unlock
terraform-unlock: terraform-init
	terraform -chdir=terraform/aks force-unlock ${LOCK_ID}

enable-maintenance:
	cf target -s ${SPACE}
	cd service_unavailable_page && cf push
	cf map-route ecf-unavailable london.cloudapps.digital --hostname ${APP_NAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route ${APP_NAME} london.cloudapps.digital --hostname ${APP_NAME}

disable-maintenance:
	$(if ${DEPLOY_ENV} == "review_aks", $(eval VARIABLE_FILE_NAME=review), $(eval VARIABLE_FILE_NAME=${DEPLOY_ENV}))
	$(eval include terraform/workspace-variables/${VARIABLE_FILE_NAME}.tfvars)
	$(eval SPACE=${paas_space_name})

	cf target -s ${SPACE}
	cf map-route ${APP_NAME} london.cloudapps.digital --hostname ${APP_NAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route ecf-unavailable london.cloudapps.digital --hostname ${APP_NAME}
	cf delete -rf ecf-unavailable

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

.PHONY: terraform-refresh
terraform-refresh: terraform-init
	terraform -chdir=terraform/application refresh -var-file config/$(CONFIG)/variables.tfvars.json

action-group-resources: set-azure-account # make env_aks action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com . Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=Manage training for early career teachers" "Environment=Test" "Service Offering=Teacher services cloud"
	az monitor action-group create -n ${AZURE_RESOURCE_PREFIX}-cpd-ecf -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

aks-console: get-cluster-credentials
	$(if $(PULL_REQUEST_NUMBER), $(eval export APP_ID=review-$(PULL_REQUEST_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-web -- /bin/sh -c "cd /app && bundle exec rails c"

aks-ssh: get-cluster-credentials
	$(if $(PULL_REQUEST_NUMBER), $(eval export APP_ID=review-$(PULL_REQUEST_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-web -- /bin/sh

aks-worker-ssh: get-cluster-credentials
	$(if $(PULL_REQUEST_NUMBER), $(eval export APP_ID=review-$(PULL_REQUEST_NUMBER))-worker , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-worker -- /bin/sh

## ie: FILENAME=restart.txt make staging aks-copy-tmp-file
## ie: FILENAME=restart.txt make ci production aks-copy-tmp-file
aks-copy-tmp-file: get-cluster-credentials
	$(if $(PULL_REQUEST_NUMBER), $(eval export APP_ID=review-$(PULL_REQUEST_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
	$(if $(FILENAME), , $(error Usage: FILENAME=restart.txt make staging aks-copy-tmp-file))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-web -- cat /app/tmp/${FILENAME} > ${FILENAME}

# Removes explicit postgres database URLs from database.yml
konduit-cleanup-ecf:
	sed -i '' -e '/\*default_primary/,/url:/{/url: \"postgres/d;}' config/database.yml; \
	exit 0
konduit-cleanup-npq:
	sed -i '' -e '/\*default_npq_registration/,/url:/{/url: \"postgres/d;}' config/database.yml; \
	exit 0

# Creates a konduit to the snapshot DB and points development to
# it. The konduit URL is removed when the konduit is closed.
konduit-snapshot-ecf: get-cluster-credentials
	trap 'make konduit-cleanup-ecf' INT; \
	tmp_file=$$(mktemp); \
	$(MAKE) konduit-cleanup-ecf; \
	{ \
			(tail -f -n0 "$$tmp_file" & ) | grep -q "postgres://"; \
			postgres_url=$$(grep -o 'postgres://[^ ]*' "$$tmp_file"); \
			echo "$$postgres_url"; \
			sed -i '' -e "s|database: early_careers_framework_development|&\\n    url: \"$$postgres_url\"|g" config/database.yml; \
	} & \
	bin/konduit.sh -d s189p01-cpdecf-pd-pg-snapshot -k s189p01-cpdecf-pd-app-kv cpd-ecf-production-web -- psql > "$$tmp_file"
	exit 0

konduit-snapshot-npq: get-cluster-credentials
	trap 'make konduit-cleanup-npq' INT; \
	tmp_file=$$(mktemp); \
	$(MAKE) konduit-cleanup-npq; \
	{ \
			(tail -f -n0 "$$tmp_file" & ) | grep -q "postgres://"; \
			postgres_url=$$(grep -o 'postgres://[^ ]*' "$$tmp_file"); \
			echo "$$postgres_url"; \
			sed -i '' -e "s|database: npq_registration_development|&\\n    url: \"$$postgres_url\"|g" config/database.yml; \
	} & \
	bin/konduit.sh -d s189p01-cpdnpq-pd-pg-snapshot -k s189p01-cpdnpq-pd-app-kv npq-registration-production-web -- psql > "$$tmp_file"
	exit 0
