# README.md - Documentation for the Terraform Cloud Run deployment

# Parking System - Cloud Run Deployment with Terraform

This repository contains Terraform configuration files to deploy a parking system API to Google Cloud Run.

## Prerequisites

1. **Google Cloud Platform Account**: Active GCP account with billing enabled
2. **Terraform**: Install Terraform (>= 1.0)
3. **Google Cloud SDK**: Install and configure `gcloud` CLI
4. **Container Image**: Your parking system application containerized and pushed to a registry

## Setup

### 1. Authentication

Authenticate with Google Cloud:

```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Enable APIs

Enable required Google Cloud APIs:

```bash
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable iam.googleapis.com
```

### 3. Configure Terraform

1. Copy the example configuration:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   project_id      = "your-gcp-project-id"
   container_image = "gcr.io/your-project-id/parking-system:latest"
   ```

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Plan the deployment

```bash
terraform plan
```

### Apply the configuration

```bash
terraform apply
```

### Get the service URL

```bash
terraform output service_url
```

## Configuration Options

### Required Variables

- `project_id`: Your GCP project ID
- `container_image`: Container image URL (e.g., `gcr.io/project/image:tag`)

### Optional Variables

- `region`: GCP region (default: `us-central1`)
- `service_name`: Cloud Run service name (default: `parking-system-api`)
- `container_port`: Container port (default: `8080`)
- `cpu_limit`: CPU limit (default: `1000m`)
- `memory_limit`: Memory limit (default: `512Mi`)
- `min_instances`: Minimum instances (default: `0`)
- `max_instances`: Maximum instances (default: `10`)
- `environment_variables`: Environment variables for the container

### Access Control

- `allow_public_access`: Allow public access (default: `true`)
- `allowed_members`: Specific members allowed to invoke the service

### Advanced Options

- `vpc_connector_name`: VPC connector for private networking
- `custom_domain`: Custom domain mapping
- `labels`: Resource labels

## Architecture

The Terraform configuration creates:

1. **Cloud Run Service**: Containerized application deployment
2. **Service Account**: Dedicated service account with minimal required permissions
3. **IAM Policies**: Access control for the Cloud Run service
4. **API Enablement**: Required Google Cloud APIs
5. **Domain Mapping**: Optional custom domain configuration

## Security Features

- Dedicated service account with least privilege access
- Configurable access control (public vs. restricted)
- Health checks and probes
- Resource limits and auto-scaling
- VPC integration support

## Monitoring and Logging

The deployed service includes:

- Automatic request logging to Cloud Logging
- Built-in metrics in Cloud Monitoring
- Health check endpoints
- Startup and liveness probes

## CI/CD Integration

This configuration works well with:

- GitHub Actions
- Cloud Build
- GitLab CI/CD
- Jenkins

Example GitHub Actions workflow is included in `.github/workflows/`.

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure your account has the necessary IAM roles
2. **API Not Enabled**: Run the API enablement commands
3. **Container Image**: Verify the image exists and is accessible
4. **Service Account**: Check service account permissions

### Useful Commands

```bash
# Check service status
gcloud run services describe parking-system-api --region=us-central1

# View logs
gcloud logs read "resource.type=cloud_run_revision" --limit=50

# List revisions
gcloud run revisions list --service=parking-system-api --region=us-central1
```

## Support

For issues and questions:
- Check the [Terraform Google Provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- Review [Cloud Run documentation](https://cloud.google.com/run/docs)
- Open an issue in this repository