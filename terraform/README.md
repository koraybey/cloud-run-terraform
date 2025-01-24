# GCP Cloud Run Deployment

This project contains Terraform configurations for deploying services to Google Cloud Run.

> This project demonstrates deploying a Koa.js application to Google Cloud Run, but can be adapted for any containerized application with minimal changes.

## Prerequisites

- Terraform installed
- Google Cloud SDK installed
- dotenvx installed
- Valid GCP account and permissions

## Environment Variables

Environment-specific variables are stored in encrypted `.env.[environment]` files:
- `.env.development`
- `.env.staging`
- `.env.production`

Required variables:
- `TF_VAR_project_id`: GCP project ID
- `TF_VAR_name`: Service name
- `TF_VAR_image_version`: Container image version
- `TF_VAR_region`: GCP region

> **Note**: All commands should be prefixed with `dotenvx run -f .env.[environment] --` where `[environment]` is either `development`, `staging`, or `production`.
>
> **Alternative**: A Makefile is provided to simplify these commands. You can use `make` commands instead of running them directly.

> **Note**: All commands should be prefixed with `dotenvx run -f .env.[environment] --` where `[environment]` is either `development`, `staging`, or `production`.

## Environment Setup

Select the appropriate Terraform workspace:
```bash
terraform workspace select development|staging|production
```

Note: The default workspace is not allowed. You must explicitly select an environment.

## GCP Setup Commands

### Initial Setup

1. Login to Google Cloud:
```bash
gcloud auth login
```

2. Create a new GCP project:
```bash
gcloud projects create $TF_VAR_project_id
```

### Service Account Setup

1. Create a service account:
```bash
gcloud iam service-accounts create deployer --project $TF_VAR_project_id
```

2. Generate service account keys:
```bash
gcloud iam service-accounts keys create service-account.json \
--iam-account deployer@$TF_VAR_project_id.iam.gserviceaccount.com \
--project $TF_VAR_project_id
```

3. Add IAM policy binding:
```bash
gcloud projects add-iam-policy-binding $TF_VAR_project_id \
--member=serviceAccount:deployer@$TF_VAR_project_id.iam.gserviceaccount.com \
--role=roles/admin \
--project $TF_VAR_project_id
```

### Enable Required APIs

Enable necessary Google Cloud APIs:
```bash
gcloud services enable cloudresourcemanager.googleapis.com --project $TF_VAR_project_id
gcloud services enable cloudbuild.googleapis.com --project $TF_VAR_project_id
gcloud services enable apigateway.googleapis.com --project $TF_VAR_project_id
gcloud services enable servicemanagement.googleapis.com --project $TF_VAR_project_id
gcloud services enable servicecontrol.googleapis.com --project $TF_VAR_project_id
gcloud services enable containerregistry.googleapis.com --project $TF_VAR_project_id
gcloud services enable run.googleapis.com --project $TF_VAR_project_id
```

### Deployment

Push container image to Google Container Registry:
```bash
gcloud builds submit --tag gcr.io/$TF_VAR_project_id/$TF_VAR_name:$TF_VAR_image_version
```