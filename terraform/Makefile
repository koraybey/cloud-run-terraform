WORKSPACE := $(shell terraform workspace show 2>/dev/null || echo "default")

ifeq ($(WORKSPACE),default)
$(error Please select a workspace using 'terraform workspace select [development|staging|production]')
endif

DOTENVX = dotenvx run -f .env.$(WORKSPACE) -- bash -c
APP_DIR=../apps/koa

show-workspace:
	@echo "Current workspace: $(WORKSPACE)"
	@echo "Using env file: .env.$(WORKSPACE)"

gc-login:
	$(DOTENVX) 'gcloud auth login'

gc-create-project:
	$(DOTENVX) 'gcloud projects create $$TF_VAR_project_id'

gc-create-service-account:
	$(DOTENVX) 'gcloud iam service-accounts create deployer --project $$TF_VAR_project_id'

gc-create-service-account-keys:
	$(DOTENVX) 'gcloud iam service-accounts keys create service-account.json --iam-account deployer@$$TF_VAR_project_id.iam.gserviceaccount.com --project $$TF_VAR_project_id'

gc-add-iam-policy-binding:
	$(DOTENVX) 'gcloud projects add-iam-policy-binding $$TF_VAR_project_id --member=serviceAccount:deployer@$$TF_VAR_project_id.iam.gserviceaccount.com --role=roles/admin --project $$TF_VAR_project_id'

gc-enable-apis:	
	$(DOTENVX) 'gcloud services enable cloudresourcemanager.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable cloudbuild.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable apigateway.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable servicemanagement.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable servicecontrol.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable containerregistry.googleapis.com --project $$TF_VAR_project_id && \
	gcloud services enable run.googleapis.com --project $$TF_VAR_project_id'

gc-push-image:
	$(DOTENVX) 'gcloud builds submit $(APP_DIR) --tag gcr.io/$$TF_VAR_project_id/$$TF_VAR_name:$$TF_VAR_image_version --project $$TF_VAR_project_id'

.PHONY: show-workspace gc-login gc-create-project gc-create-service-account gc-create-service-account-keys gc-add-iam-policy-binding gc-enable-apis gc-push-image