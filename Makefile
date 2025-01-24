include .env
export $(shell sed 's/=.*//' .env)

IMAGE=gcr.io/$(TF_VAR_PROJECT_ID)/$(TF_VAR_NAME):$(TF_VAR_VERSION)
SERVICE_ACCOUNT=deployer

gc-login:
	gcloud auth login

gc-create-service-account:
	gcloud iam service-accounts create $(SERVICE_ACCOUNT) --project $(TF_VAR_PROJECT_ID)

gc-add-iam-policy-binding:
	gcloud projects add-iam-policy-binding $(TF_VAR_PROJECT_ID) \
	--member=serviceAccount:deployer@$(TF_VAR_PROJECT_ID).iam.gserviceaccount.com \
	--role=roles/admin \
	--project $(TF_VAR_PROJECT_ID)

gc-create-service-account-keys:
	gcloud iam service-accounts keys create service-account.json \
	--iam-account $(SERVICE_ACCOUNT)@$(TF_VAR_PROJECT_ID).iam.gserviceaccount.com \
	--project $(TF_VAR_PROJECT_ID)

gc-create-project:
	gcloud projects create $(TF_VAR_PROJECT_ID)

gc-enable-apis:
	gcloud services enable cloudresourcemanager.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable cloudbuild.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable apigateway.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable servicemanagement.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable servicecontrol.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable containerregistry.googleapis.com --project $(TF_VAR_PROJECT_ID)
	gcloud services enable run.googleapis.com --project $(TF_VAR_PROJECT_ID)

gc-push-image:
	gcloud builds submit --tag $(IMAGE) --project $(TF_VAR_PROJECT_ID)

tf-init:
	TF_LOG=$(TF_LOG) \
	TF_VAR_REGION=$(TF_VAR_REGION) \
	TF_VAR_PROJECT_ID=$(TF_VAR_PROJECT_ID) \
	TF_VAR_VERSION=$(TF_VAR_VERSION) \
	TF_VAR_NAME=$(TF_VAR_NAME) \
	cd terraform && terraform init

tf-plan:
	TF_LOG=$(TF_LOG) \
	TF_VAR_REGION=$(TF_VAR_REGION) \
	TF_VAR_PROJECT_ID=$(TF_VAR_PROJECT_ID) \
	TF_VAR_VERSION=$(TF_VAR_VERSION) \
	TF_VAR_NAME=$(TF_VAR_NAME) \
	cd terraform && terraform plan

tf-apply:
	TF_LOG=$(TF_LOG) \
	TF_VAR_REGION=$(TF_VAR_REGION) \
	TF_VAR_PROJECT_ID=$(TF_VAR_PROJECT_ID) \
	TF_VAR_VERSION=$(TF_VAR_VERSION) \
	TF_VAR_NAME=$(TF_VAR_NAME) \
	cd terraform && terraform apply

get-gateway-url:	
	$(eval GATEWAY_URL=$(shell gcloud beta api-gateway gateways describe api-gateway \
	--location=$(TF_VAR_REGION) --project=$(TF_VAR_PROJECT_ID) \
	--format=json | jq ".defaultHostname"))
	@echo https://$(GATEWAY_URL)