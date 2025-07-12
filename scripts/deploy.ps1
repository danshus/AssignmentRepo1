# Sentinel Deployment Script (PowerShell)
# This script deploys the complete infrastructure on Windows

param(
    [string]$AWSRegion = "us-west-2",
    [string]$Environment = "production",
    [switch]$SkipInfrastructure,
    [switch]$SkipApplications,
    [switch]$ValidateOnly
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Sentinel deployment..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check if Terraform is installed
try {
    $terraformVersion = terraform version
    Write-Status "Terraform is installed: $($terraformVersion.Split("`n")[0])"
} catch {
    Write-Error "Terraform is not installed or not in PATH"
    Write-Info "Please install Terraform from https://www.terraform.io/downloads.html"
    exit 1
}

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client
    Write-Status "kubectl is installed: $($kubectlVersion.Split("`n")[0])"
} catch {
    Write-Error "kubectl is not installed or not in PATH"
    Write-Info "Please install kubectl from https://kubernetes.io/docs/tasks/tools/"
    exit 1
}

# Check if AWS CLI is installed
try {
    $awsVersion = aws --version
    Write-Status "AWS CLI is installed: $awsVersion"
} catch {
    Write-Error "AWS CLI is not installed or not in PATH"
    Write-Info "Please install AWS CLI from https://aws.amazon.com/cli/"
    exit 1
}

# Check AWS credentials
try {
    $awsIdentity = aws sts get-caller-identity
    $accountId = ($awsIdentity | ConvertFrom-Json).Account
    Write-Status "AWS credentials configured for account: $accountId"
} catch {
    Write-Error "AWS credentials not configured or invalid"
    Write-Info "Please run 'aws configure' to set up your credentials"
    exit 1
}

Write-Status "All prerequisites are satisfied"

# Set environment variables
$env:AWS_REGION = $AWSRegion
$env:TF_VAR_environment = $Environment

# Deploy Infrastructure
if (-not $SkipInfrastructure) {
    Write-Info "Deploying infrastructure..."
    
    # Change to terraform directory
    Push-Location terraform
    
    try {
        # Initialize Terraform
        Write-Info "Initializing Terraform..."
        terraform init
        
        # Validate Terraform configuration
        Write-Info "Validating Terraform configuration..."
        terraform validate
        
        # Run TFLint
        Write-Info "Running TFLint for code quality..."
        try {
            tflint --init
            tflint
        } catch {
            Write-Warning "TFLint not available, skipping code quality checks"
        }
        
        if ($ValidateOnly) {
            Write-Info "Validation only mode - skipping deployment"
            terraform plan
        } else {
            # Plan Terraform deployment
            Write-Info "Planning Terraform deployment..."
            terraform plan -out=tfplan
            
            # Apply Terraform deployment
            Write-Info "Applying Terraform deployment..."
            terraform apply tfplan
            
            Write-Status "Infrastructure deployment completed successfully"
        }
    } catch {
        Write-Error "Infrastructure deployment failed: $($_.Exception.Message)"
        Pop-Location
        exit 1
    } finally {
        Pop-Location
    }
} else {
    Write-Info "Skipping infrastructure deployment"
}

# Deploy Applications
if (-not $SkipApplications) {
    Write-Info "Deploying applications..."
    
    try {
        # Update kubeconfig for both clusters
        Write-Info "Configuring kubectl for EKS clusters..."
        aws eks update-kubeconfig --name eks-gateway --region $AWSRegion
        aws eks update-kubeconfig --name eks-backend --region $AWSRegion
        
        # Wait for clusters to be ready
        Write-Info "Waiting for EKS clusters to be ready..."
        Start-Sleep -Seconds 30
        
        # Deploy backend service
        Write-Info "Deploying backend service..."
        kubectl apply -f kubernetes/backend/
        
        # Wait for backend deployment
        Write-Info "Waiting for backend deployment to complete..."
        kubectl rollout status deployment/backend-service -n backend --timeout=300s
        
        # Deploy gateway service
        Write-Info "Deploying gateway service..."
        kubectl apply -f kubernetes/gateway/
        
        # Wait for gateway deployment
        Write-Info "Waiting for gateway deployment to complete..."
        kubectl rollout status deployment/proxy-service -n gateway --timeout=300s
        
        Write-Status "Application deployment completed successfully"
        
    } catch {
        Write-Error "Application deployment failed: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Info "Skipping application deployment"
}

# Validate deployment
if (-not $ValidateOnly) {
    Write-Info "Validating deployment..."
    
    try {
        # Run validation script
        & "$PSScriptRoot\validate.ps1" -AWSRegion $AWSRegion
        
        Write-Status "Deployment validation completed successfully"
    } catch {
        Write-Error "Deployment validation failed: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 Sentinel deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "  • Infrastructure: $(if ($SkipInfrastructure) { 'Skipped' } else { 'Deployed' })"
Write-Host "  • Applications: $(if ($SkipApplications) { 'Skipped' } else { 'Deployed' })"
Write-Host "  • Validation: $(if ($ValidateOnly) { 'Only' } else { 'Completed' })"
Write-Host "  • Region: $AWSRegion"
Write-Host "  • Environment: $Environment"
Write-Host ""
Write-Host "🔗 Useful Commands:" -ForegroundColor Yellow
Write-Host "  • View backend pods: kubectl get pods -n backend"
Write-Host "  • View gateway pods: kubectl get pods -n gateway"
Write-Host "  • Get LoadBalancer URL: kubectl get svc proxy-service -n gateway"
Write-Host "  • View logs: kubectl logs -f deployment/backend-service -n backend"
Write-Host "  • Destroy infrastructure: terraform destroy (in terraform directory)"
Write-Host ""
Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Test the application using the LoadBalancer URL"
Write-Host "  2. Review the security configurations"
Write-Host "  3. Set up monitoring and alerting"
Write-Host "  4. Implement the suggested enhancements from README.md"
Write-Host "" 