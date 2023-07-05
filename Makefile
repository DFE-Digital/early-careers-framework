ifndef VERBOSE
.SILENT:
endif

SERVICE_SHORT=cpdecf

aks:  ## Sets environment variables for aks deployment
	$(eval PLATFORM=aks)
	$(eval REGION=UK South)
	$(eval KEY_VAULT_PURGE_PROTECTION=false)

.PHONY: development
development:
	$(eval DEPLOY_ENV=development)
	$(eval include global_config/development_aks.sh)

.PHONY: staging
staging:
	$(eval DEPLOY_ENV=staging)

.PHONY: sandbox
sandbox:
	$(eval DEPLOY_ENV=sandbox)

.PHONY: review_aks
review_aks: aks ## Specify review AKS environment
	# PULL_REQUEST_NUMBER is set by the GitHub action
	$(if $(PULL_REQUEST_NUMBER), , $(error Missing environment variable "PULL_REQUEST_NUMBER"))
	$(eval include global_config/review_aks.sh)
	$(eval backend_config=-backend-config="key=terraform-$(PULL_REQUEST_NUMBER).tfstate")
	$(eval export TF_VAR_app_suffix=-$(PULL_REQUEST_NUMBER))
	$(eval export TF_VAR_uploads_storage_account_name=$(AZURE_RESOURCE_PREFIX)cpdecfrv$(PULL_REQUEST_NUMBER)sa)

.PHONY: production
production:
	$(eval DEPLOY_ENV=production)
	$(if $(CONFIRM_PRODUCTION), , $(error Production can only run with CONFIRM_PRODUCTION))

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
	# $(eval DISABLE_PASSCODE=true)
	# $(eval AUTO_APPROVE=-auto-approve)
	# $(eval CONFIRM_PRODUCTION=true)

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
