# Sentinel Split - DevSecOps Technical Challenge

A proof-of-concept environment demonstrating a secure, modular infrastructure for the Sentinel threat intelligence platform using Terraform, EKS, and GitHub Actions CI/CD.

## Architecture Overview

This project implements a split architecture with two isolated domains:

1. **Gateway Layer (Public)** - Hosts internet-facing APIs and proxies
2. **Backend Layer (Private)** - Runs internal processing and sensitive services

### Key Components

- **Two AWS VPCs**: `vpc-gateway` and `vpc-backend` with isolated networking
- **Two EKS Clusters**: `eks-gateway` and `eks-backend` (one per VPC)
- **VPC Peering**: Secure cross-VPC communication
- **Private Subnets**: All workloads run in private subnets for security
- **NAT Gateways**: Minimal public subnets only for outbound internet access
- **Security Groups**: Restrictive access controls between services
- **Cost-Optimized Instances**: t3.micro instances for simple workloads

## How the Proxy Talks to the Backend

1. **External Request** → LoadBalancer (Gateway VPC)
2. **LoadBalancer** → Proxy Pod (Gateway Cluster)
3. **Proxy Pod** → Backend Service (Backend Cluster) via VPC Peering
4. **Backend Service** → Backend Pod (Backend Cluster)

### Service Discovery

The proxy uses Kubernetes DNS to reach the backend:
```
backend-service.backend.svc.cluster.local:80
```

This works because:
- Both clusters are in peered VPCs
- Route tables are configured for cross-VPC traffic
- Security groups allow traffic from gateway to backend

## Security Model

### Network Security

- **Private Subnets**: All workloads run in private subnets
- **No Public EC2s**: EKS nodes are in private subnets only
- **NAT Gateways**: Minimal public subnets for outbound internet access
- **Security Groups**: Restrictive ingress/egress rules

### Kubernetes Security

- **Network Policies**: Applied to both gateway and backend namespaces
- **Namespace Isolation**: Gateway and backend run in separate namespaces
- **Service Mesh Ready**: Architecture supports future Istio/Linkerd deployment

### Network Policies

**Gateway Network Policy**:
- Allows ingress from any namespace on port 80
- Allows egress to backend namespace on port 80
- Allows egress to internet for HTTPS (443) and DNS (53)

**Backend Network Policy**:
- Only allows ingress from gateway namespace on port 80
- No egress rules (default deny)

## CI/CD Pipeline Structure

### GitHub Actions Workflow

1. **Validate Terraform**:
   - `terraform fmt -check`
   - `terraform validate`
   - `tflint`

2. **Security Scan**:
   - Trivy vulnerability scanning
   - Results uploaded to GitHub Security tab

3. **Deploy Infrastructure**:
   - Terraform plan and apply
   - Creates VPCs, EKS clusters, and networking

4. **Validate Kubernetes**:
   - `kubeval` for schema validation
   - `kubectl apply --dry-run` for dry-run validation

5. **Deploy Applications**:
   - Deploy backend service first
   - Deploy gateway proxy
   - Wait for rollouts and test connectivity

### Pipeline Features

- **Triggered on push** to main branch
- **Parallel validation** jobs for efficiency
- **Security scanning** integrated
- **Rollback capability** through Terraform
- **Status notifications** on completion

## License

This project is for educational purposes as part of the Sentinel DevSecOps technical challenge.
