include .env
export $(shell sed 's/=.*//' .env)

IMAGE=gcr.io/$(TF_VAR_project_id)/$(TF_VAR_name):$(TF_VAR_image_version)
SERVICE_ACCOUNT=deployer

gc-login:
	gcloud auth login

gc-create-project:
	gcloud projects create $(TF_VAR_project_id)

gc-create-service-account:
	gcloud iam service-accounts create $(SERVICE_ACCOUNT) --project $(TF_VAR_project_id)

gc-create-service-account-keys:
	gcloud iam service-accounts keys create service-account.json \
	--iam-account $(SERVICE_ACCOUNT)@$(TF_VAR_project_id).iam.gserviceaccount.com \
	--project $(TF_VAR_project_id)

gc-add-iam-policy-binding:
	gcloud projects add-iam-policy-binding $(TF_VAR_project_id) \
	--member=serviceAccount:deployer@$(TF_VAR_project_id).iam.gserviceaccount.com \
	--role=roles/admin \
	--project $(TF_VAR_project_id)

gc-enable-apis:	
	gcloud services enable cloudresourcemanager.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable cloudbuild.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable apigateway.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable servicemanagement.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable servicecontrol.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable containerregistry.googleapis.com --project $(TF_VAR_project_id)
	gcloud services enable run.googleapis.com --project $(TF_VAR_project_id)

gc-push-image:
	gcloud builds submit --tag $(IMAGE) --project $(TF_VAR_project_id)