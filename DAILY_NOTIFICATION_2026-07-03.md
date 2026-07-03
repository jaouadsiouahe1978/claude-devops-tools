# 🚀 DevOps du Jour - 2026-07-03

## 📌 Projet du jour: **Terraform AWS - Infrastructure as Code**

---

## 🎯 Objectif

Apprendre à utiliser **Terraform** pour créer et gérer une infrastructure AWS complète (Infrastructure as Code).

### Architecture:
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24)
│   └── EC2 Web Server (t3.micro)
├── Private Subnet (10.0.2.0/24)
│   └── RDS PostgreSQL Database
└── Internet Gateway → Internet
```

---

## 📦 Technologies

- **Terraform** - Infrastructure as Code
- **AWS** - Cloud Provider (eu-west-1)
- **VPC** - Virtual Private Cloud
- **EC2** - Virtual Machines
- **RDS** - PostgreSQL Database
- **Security Groups** - Firewall Rules
- **CloudWatch** - Monitoring

---

## 📋 Contenu du projet

```
projects/2026-07-03_terraform-iac/
├── main.tf                 (103 lines) - VPC, Subnets, IGW
├── variables.tf            (104 lines) - Input variables
├── outputs.tf              (80 lines) - Export values
├── security.tf             (96 lines) - Security groups
├── ec2.tf                  (115 lines) - EC2 instances
├── rds.tf                  (118 lines) - PostgreSQL database
├── advanced.tf             (144 lines) - CloudWatch, NAT, etc.
├── terraform.tfvars        - Variable values
├── Makefile                (100 lines) - Commands
├── README.md               (350 lines) - Complete guide
└── scripts/
    ├── setup.sh            - Prerequisite check
    ├── deploy.sh           - Automated deployment
    ├── destroy.sh          - Infrastructure cleanup
    └── validate.sh         - Configuration validation
```

**Total:** 1,210+ lines of Terraform + 800+ lines of scripts = 2,000+ lines

---

## 🎓 Ce qu'on apprend

### Terraform Concepts
- Providers, Resources, Variables, State
- Data sources, Locals, Outputs
- for_each loops and dynamic blocks
- Validation and lifecycle rules

### AWS Networking & Services
- VPC setup and configuration
- Public/Private subnets
- Internet Gateway and Route Tables
- EC2 instances and Elastic IPs
- RDS PostgreSQL database
- Security Groups and firewall rules
- CloudWatch monitoring and alarms

### DevOps Best Practices
- Infrastructure as Code (IaC)
- Git version control for infra
- Automated deployment scripts
- Plan-before-apply workflow
- State management
- Variable parameterization
- Environment separation

---

## 🚀 Quick Start

```bash
cd projects/2026-07-03_terraform-iac
aws configure                  # Setup AWS credentials
terraform init               # Initialize
terraform plan -out=tfplan   # Review changes
terraform apply tfplan       # Deploy
terraform output             # Show results
terraform destroy            # Cleanup
```

Or use the automated scripts:
```bash
bash scripts/setup.sh       # Check prerequisites
bash scripts/deploy.sh      # Automated deployment
bash scripts/destroy.sh     # Cleanup everything
```

Or use Makefile commands:
```bash
make setup    # Check prerequisites
make plan     # Plan deployment
make apply    # Apply changes
make destroy  # Cleanup
make output   # Show outputs
```

---

## 📊 Example Outputs

```
vpc_id = "vpc-0123456789abcdef"
ec2_public_ips = ["54.123.45.67"]
rds_endpoint = "devops-training-db.xxxx.eu-west-1.rds.amazonaws.com:5432"
ssh_command = "ssh -i key.pem ec2-user@54.123.45.67"
```

---

## ✅ Success Criteria

- [ ] Terraform installed and verified
- [ ] AWS credentials configured
- [ ] Code reviewed and understood
- [ ] `terraform init` completes
- [ ] `terraform plan` shows changes
- [ ] `terraform apply` deploys successfully
- [ ] AWS Console shows new infrastructure
- [ ] EC2 is SSH accessible
- [ ] RDS is reachable from EC2
- [ ] `terraform destroy` cleans up

---

## 🎯 Variations to Try

1. Auto-Scaling Group (multiple EC2s)
2. Application Load Balancer
3. RDS Multi-AZ for HA
4. NAT Gateway for private subnet
5. Terraform Modules for reusability
6. Remote state in S3
7. Separate dev/prod workspaces

---

## 📚 Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Reference](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [AWS VPC Guide](https://docs.aws.amazon.com/vpc/)

---

**Durée:** ~1 jour  
**Niveau:** Débutant → Intermédiaire  
**Créé:** 2026-07-03  
**Repository:** https://github.com/jaouadsiouahe1978/claude-devops-tools
