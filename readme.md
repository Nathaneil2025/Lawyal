# Step 1 — AWS Infra (VPC + EKS + Node Groups + ECR)

This module provisions:
- VPC `192.168.0.0/16` with:
  - Public subnet `192.168.0.0/24` in `eu-central-1a`
  - Private subnet `192.168.1.0/24` in `eu-central-1b`
- Internet Gateway + 1x NAT Gateway
- EKS cluster `${project_name}-eks` (default `lawyal-eks`)
- 2 managed node groups:
  - `public-ng` in the public subnet
  - `private-ng` in the private subnet
- ECR repo `${project_name}/flask-app`
- IAM roles and policy attachments

> **Prereqs**:  
> - S3 bucket `lawyal-terraform-state` (versioning + AES256)  
> - DynamoDB table `terraform-locks`  
> - AWS CLI configured with permissions  
> - Terraform v1.5+  

## How to deploy

```powershell
cd C:\TRT\AfterCourse\Lawyal\Project\terraform

# (Optional) override defaults in a tfvars file
# echo 'project_name="lawyal"' > terraform.tfvars

terraform init
terraform plan -out tfplan
terraform apply tfplan
