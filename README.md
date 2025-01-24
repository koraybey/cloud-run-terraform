# GCP Cloud Run Deployment with Terraform

This project contains Terraform configurations for deploying services to Google Cloud Run.

> This project demonstrates deploying a Koa.js application to Google Cloud Run, but can be adapted for any containerized application with minimal changes.

## Prerequisites

This project uses [asdf](https://asdf-vm.com/) for managing tool versions. The required versions are specified in `.tool-versions`:

```plaintext
terraform 1.9.5
gcloud   491.0.0
nodejs   20.9.0
pnpm     9.5.0
dotenvx  1.33.0
jq       1.7.1
```

### Installation

1. Install asdf:
```bash
# On macOS
brew install asdf

# On Linux
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
```

2. Add required plugins:
```bash
asdf plugin add terraform
asdf plugin add gcloud
asdf plugin add nodejs
asdf plugin add pnpm
asdf plugin add dotenvx
asdf plugin add jq
```

3. Install all tools:
```bash
asdf install
```

4. Verify installation:
```bash
asdf current
```

5. Configure Google Cloud SDK:
```bash
gcloud init
```

## Command Execution

### Shell Expansion and Environment Variables
When running commands that use environment variables, we need to prevent the shell from expanding variables before dotenvx can inject them. This is done using subshell syntax ($$) in the Makefile or single quotes in direct shell commands.

Using the Makefile:
```bash
make gc-create-project   # Makefile uses $$ for proper expansion
```

Direct shell command:
```bash
# Wrong ❌ - Shell expands variables before dotenvx
dotenvx run -f .env.development -- bash -c "gcloud projects create $TF_VAR_project_id"

# Correct ✅ - Using single quotes prevents premature expansion
dotenvx run -f .env.development -- bash -c 'gcloud projects create $TF_VAR_project_id'

# Also correct ✅ - Using escaped variables in double quotes
dotenvx run -f .env.development -- bash -c "gcloud projects create \$TF_VAR_project_id"
```

For more information about shell expansion with dotenvx, see the [official documentation](https://dotenvx.com/docs/advanced/run-shell-expansion#subshell).

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