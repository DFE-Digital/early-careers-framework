ifndef VERBOSE
.SILENT:
endif

REGION=UK South
SERVICE_SHORT=cpdecf
KEY_VAULT_PURGE_PROTECTION=false
ARM_TEMPLATE_TAG=1.1.6
TERRAFILE_VERSION=0.8

.PHONY: review
review: test-cluster ## Specify review environment
	# PULL_REQUEST_NUMBER is set by the GitHub action
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval include global_config/review.sh)
	$(eval backend_config=-backend-config="key=terraform-$(PULL_REQUEST_NUMBER).tfstate")
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)$(SERVICE_SHORT)rv$(PULL_REQUEST_NUMBER)sa)

.PHONY: staging
staging: test-cluster
	$(eval include global_config/staging.sh)

.PHONY: sandbox
sandbox: production-cluster
	$(eval include global_config/sandbox.sh)

.PHONY: migration
migration: production-cluster
	$(eval include global_config/migration.sh)

.PHONY: production
production: production-cluster
	$(eval include global_config/production.sh)
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
	terraform -chdir=terraform/application init -backend-config workspace_variables/${CONFIG}_backend.tfvars $(backend_config) -upgrade -reconfigure

.PHONY: terraform-apply
terraform-apply: terraform-init
	terraform -chdir=terraform/application apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

.PHONY: terraform-plan
terraform-plan: terraform-init
	terraform -chdir=terraform/application plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

.PHONY: terraform-destroy
terraform-destroy: terraform-init
	terraform -chdir=terraform/application destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}


## DOCKER_IMAGE=fake-image make review terraform-unlock PULL_REQUEST_NUMBER=4169 LOCK_ID=123456
## DOCKER_IMAGE=fake-image make staging terraform-unlock LOCK_ID=123456
.PHONY: terraform-unlock
terraform-unlock: terraform-init
	terraform -chdir=terraform/application force-unlock ${LOCK_ID}

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

get-cluster-credentials: set-azure-account
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

.PHONY: terraform-refresh
terraform-refresh: terraform-init
	terraform -chdir=terraform/application refresh -var-file config/$(CONFIG)/variables.tfvars.json

define SET_APP_ID_FROM_PULL_REQUEST_NUMBER
	$(if $(PULL_REQUEST_NUMBER), $(eval export APP_ID=review-$(PULL_REQUEST_NUMBER)) , $(eval export APP_ID=$(CONFIG_LONG)))
endef

action-group-resources: set-azure-account # make env_aks action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com . Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=Manage training for early career teachers" "Environment=Test" "Service Offering=Teacher services cloud"
	az monitor action-group create -n ${AZURE_RESOURCE_PREFIX}-cpd-ecf -g ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

aks-console: get-cluster-credentials
	$(SET_APP_ID_FROM_PULL_REQUEST_NUMBER)
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-web -- /bin/sh -c "cd /app && bundle exec rails c"

aks-ssh: get-cluster-credentials
	$(SET_APP_ID_FROM_PULL_REQUEST_NUMBER)
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-web -- /bin/sh

aks-worker-ssh: get-cluster-credentials
	$(SET_APP_ID_FROM_PULL_REQUEST_NUMBER)
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/cpd-ecf-${APP_ID}-worker -- /bin/sh

# downloads the given file from the app/tmp directory of all
# pods in the cluster to the local computer (in a subdirectory matching the pod name).
## ie: FILENAME=restart.txt make staging aks-download-tmp-file
## ie: FILENAME=restart.txt make ci production aks-download-tmp-file
aks-download-tmp-file: get-cluster-credentials
	$(SET_APP_ID_FROM_PULL_REQUEST_NUMBER)
	$(if $(FILENAME), , $(error Usage: FILENAME=restart.txt make staging aks-download-tmp-file))
	kubectl get pods -n ${NAMESPACE} -l app=cpd-ecf-${APP_ID}-web -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -I {} sh -c 'mkdir -p {}/ && kubectl cp ${NAMESPACE}/{}:/app/tmp/${FILENAME} {}/${FILENAME}'

# uploads the given file to the app/tmp directory of all
# pods in the cluster.
## ie: FILENAME=local_file.txt make staging aks-upload-tmp-file
aks-upload-tmp-file: get-cluster-credentials
	$(SET_APP_ID_FROM_PULL_REQUEST_NUMBER)
	$(if $(FILENAME), , $(error Usage: FILENAME=restart.txt make staging aks-upload-tmp-file))
	kubectl get pods -n ${NAMESPACE} -l app=cpd-ecf-${APP_ID}-web -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | xargs -I {} kubectl cp ${FILENAME} ${NAMESPACE}/{}:/app/tmp/${FILENAME}

# Removes explicit postgres database URLs from database.yml
konduit-cleanup:
	sed -i '' -e '/url\: "postgres/d' config/database.yml; \
	exit 0

define KONDUIT_CONNECT
	trap 'make konduit-cleanup' INT; \
	tmp_file=$$(mktemp); \
	$(MAKE) konduit-cleanup; \
	{ \
		(tail -f -n0 "$$tmp_file" & ) | grep -q "postgres://"; \
		postgres_url=$$(grep -o 'postgres://[^ ]*' "$$tmp_file"); \
		echo "$$postgres_url"; \
		sed -i '' -e "s|database: \"early_careers_framework_development\"|&\\n  url: \"$$postgres_url\"|g" config/database.yml; \
	} & \
	bin/konduit.sh -d
endef

# Creates a konduit to the DB and points development to it. The konduit URL is removed when the konduit is closed.
konduit: get-cluster-credentials
	$(KONDUIT_CONNECT) ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-pg -n ${NAMESPACE} -k ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv cpd-ecf-${CONFIG_LONG}-web -- psql > "$$tmp_file"
	exit 0

# Creates a konduit to the snapshot DB and points development to it. The konduit URL is removed when the konduit is closed.
konduit-snapshot: get-cluster-credentials
	$(KONDUIT_CONNECT) ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-pg-snapshot -n ${NAMESPACE} -k ${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv cpd-ecf-${CONFIG_LONG}-web -- psql > "$$tmp_file"
	exit 0
