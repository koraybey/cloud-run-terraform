# GCP Cloud Run Deployment with Terraform

This project contains Terraform configurations for deploying services to Google Cloud Run. 

> [!NOTE]
> This project demonstrates deploying a Koa.js application to Google Cloud Run, but can be adapted for any containerized application with minimal changes.

> [!NOTE]
> This documentation is intentionally detailed to serve as a comprehensive guide for team members new to Terraform and infrastructure as code. Each section includes explanations and examples to help understand the deployment process.


## Prerequisites

This project uses [asdf](https://asdf-vm.com/) for managing tool versions. Required runtime dependencies and their versions are specified in `.tool-versions`.

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

## Environment Variables

This project uses `dotenvx` for secure environment variable management. Variables are encrypted using public/private key encryption.

### Required Environment Variables

The following variables are required:

```plaintext
TF_VAR_region              # GCP region for deployment (e.g., us-central1)
TF_VAR_project_id          # Your GCP project ID
TF_VAR_image_version       # Version tag for your container image
TF_VAR_name               # Name of your application/service
TF_VAR_service_account_name # Name of the service account to be created
```

### Environment Variable Security

1. **Encryption**: 
   - Environment variables are encrypted using `dotenvx`
   - Public key is stored in `DOTENV_PUBLIC_KEY_DEVELOPMENT`
   - Private key is stored in `env.keys` and should never be commited to version control

2. **Usage with dotenvx**:
   ```bash
   # Load encrypted environment variables
   dotenvx run -f .env.development -- terraform plan
   ```

### Shell Expansion and Environment Variables

When using environment variables, be careful with shell expansion:

```bash
# Wrong ❌ - Shell expands variables before dotenvx
dotenvx run -f .env.development -- bash -c "terraform plan $TF_VAR_project_id"

# Correct ✅ - Using single quotes
dotenvx run -f .env.development -- bash -c 'terraform plan $TF_VAR_project_id'

# Also correct ✅ - Using escaped variables
dotenvx run -f .env.development -- bash -c "terraform plan \$TF_VAR_project_id"
```

For more information about shell expansion with dotenvx, see the [official documentation](https://dotenvx.com/docs/advanced/run-shell-expansion#subshell).

### Environment Specific Configuration

Different environments (development, staging, production) should have their own encrypted environment files:

- `.env.development` - Development environment variables
- `.env.staging` - Staging environment variables
- `.env.production` - Production environment variables

To use a specific environment:

```bash
dotenvx run -f .env.[environment] -- terraform [command]
```

## GCP Setup Commands

> [!TIP]
> All Google Cloud commands are available as Make targets for convenience. Use `make show-workspace` to verify your environment before running commands.

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

### Pushing Image to Registry

Push container image to Google Container Registry:
```bash
gcloud builds submit --tag gcr.io/$TF_VAR_project_id/$TF_VAR_name:$TF_VAR_image_version
```

## Deployment Commands

> [!CAUTION]
> Always import existing infrastructure state before making changes to avoid accidental resource destruction. **Remember: Skipping imports = Destroying existing infrastructure.**

```bash
# Initialize Terraform and select workspace
terraform init
terraform workspace select development

# Import existing state (REQUIRED for existing resources)
terraform import [RESOURCE_TYPE].[NAME] [RESOURCE_ID]

# Plan changes
terraform plan

# Apply changes
terraform apply

# Remove specific resource
terraform state rm [RESOURCE_TYPE].[NAME]

# Destroy infrastructure (use with caution)
terraform destroy
```