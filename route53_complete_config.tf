#
# Route53 Complete Configuration
# Infrastructure: Zone Sud-2, VPC 10.0.0.0/16, Clusters A/B, Bastion
#
# This configuration assumes:
# - AWS provider already configured
# - VPC, ALB, EC2 instances, and Bastion already exist
# - Registrar (GoDaddy) NS records point to Route53
#

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# VARIABLES
# ============================================================================

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "domaine.com"
}

variable "alb_dns_name" {
  description = "ALB DNS name from infrastructure"
  type        = string
  # Example: "alb-xxxxx.elb.amazonaws.com"
  # Set via -var or .tfvars
}

variable "alb_zone_id" {
  description = "ALB Zone ID (AWS-specific for Alias records)"
  type        = string
  # Example: "Z35SXDOTRQ7X7K"
  # Retrieved from ALB resource
}

variable "bastion_elastic_ip" {
  description = "Bastion public Elastic IP"
  type        = string
  # Example: "203.0.113.50"
}

variable "internal_service_ip" {
  description = "Internal service IP (private subnet)"
  type        = string
  default     = "10.0.20.50"
}

variable "external_partner_ip" {
  description = "External partner service IP"
  type        = string
  default     = "203.0.113.99"
}

variable "vpc_id" {
  description = "VPC ID for private hosted zones"
  type        = string
  # Example: "vpc-0123456789abcdef0"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "sa-east-2"  # South-2
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "enable_health_checks" {
  description = "Enable health checks for critical endpoints"
  type        = bool
  default     = true
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# 1. PUBLIC HOSTED ZONE
# ============================================================================

resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "Public hosted zone for ${var.domain_name} - ${var.environment}"

  tags = {
    Name        = "zone-${var.domain_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

output "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "nameservers" {
  description = "Route53 Nameservers (copy to registrar)"
  value       = aws_route53_zone.main.name_servers
}

# ============================================================================
# 2. APEX RECORDS (domaine.com)
# ============================================================================

# A record at apex - Alias to ALB for www traffic
resource "aws_route53_record" "apex_alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_route53_zone.main]
}

# Optional: AAAA record at apex (IPv6)
resource "aws_route53_record" "apex_alb_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_route53_zone.main]
}

# MX Records (if email hosting needed)
resource "aws_route53_record" "mx_records" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 3600

  # Example: Google Workspace
  records = [
    "10 aspmx.l.google.com",
    "20 alt1.aspmx.l.google.com",
    "30 alt2.aspmx.l.google.com"
  ]

  # Uncomment if using email service
  # depends_on = [aws_route53_zone.main]
}

# TXT Records (SPF, DKIM, DMARC)
resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = 3600

  records = [
    "v=spf1 include:_spf.google.com ~all"
  ]

  # Uncomment if using email service
  # depends_on = [aws_route53_zone.main]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = 3600

  records = [
    "v=DMARC1; p=quarantine; rua=mailto:admin@${var.domain_name}"
  ]

  # Uncomment if using email service
  # depends_on = [aws_route53_zone.main]
}

# ============================================================================
# 3. API RECORDS (api.domaine.com)
# ============================================================================

# Primary A record with weighted routing
resource "aws_route53_record" "api_weighted" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "api-primary"
  weighted_routing_policy {
    weight = 100  # 100% to primary (or 70 for canary)
  }

  depends_on = [
    aws_route53_zone.main,
    aws_route53_health_check.alb
  ]
}

# Optional: Secondary weighted record (for A/B testing)
# Uncomment to enable canary deployment (70/30 split)
# resource "aws_route53_record" "api_weighted_secondary" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "api.${var.domain_name}"
#   type    = "A"
#
#   alias {
#     name                   = var.alb_secondary_dns_name
#     zone_id                = var.alb_secondary_zone_id
#     evaluate_target_health = true
#   }
#
#   set_identifier = "api-secondary"
#   weighted_routing_policy {
#     weight = 30  # 30% to secondary (canary)
#   }
#
#   depends_on = [aws_route53_zone.main]
# }

# IPv6 record for API
resource "aws_route53_record" "api_ipv6" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_route53_zone.main]
}

# ============================================================================
# 4. ADMIN RECORDS (admin.domaine.com - Bastion)
# ============================================================================

# Simple A record pointing to Bastion Elastic IP
resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "admin.${var.domain_name}"
  type    = "A"
  ttl     = 3600
  records = [var.bastion_elastic_ip]

  depends_on = [
    aws_route53_zone.main,
    aws_route53_health_check.bastion
  ]
}

# Failover record (optional - secondary Bastion)
# Uncomment if you have a secondary Bastion
# resource "aws_route53_record" "admin_failover" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "admin.${var.domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [var.bastion_secondary_elastic_ip]
#
#   set_identifier = "admin-secondary"
#   failover_routing_policy {
#     type = "SECONDARY"
#   }
#
#   depends_on = [aws_route53_zone.main]
# }

# ============================================================================
# 5. EXTERNAL PARTNER RECORDS (aden.domaine.com)
# ============================================================================

resource "aws_route53_record" "external_partner" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "aden.${var.domain_name}"
  type    = "A"
  ttl     = 300  # Short TTL for external services
  records = [var.external_partner_ip]

  depends_on = [aws_route53_zone.main]
}

# Alternative: CNAME record (if partner provides CNAME)
# resource "aws_route53_record" "aden_cname" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "aden.${var.domain_name}"
#   type    = "CNAME"
#   ttl     = 300
#   records = ["partner.example.com"]
#
#   depends_on = [aws_route53_zone.main]
# }

# ============================================================================
# 6. HEALTH CHECKS
# ============================================================================

# Health check for ALB
resource "aws_route53_health_check" "alb" {
  count = var.enable_health_checks ? 1 : 0

  type              = "HTTPS"
  resource_path     = "/health"
  fqdn              = var.alb_dns_name
  port              = 443
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "health-check-alb"
  }
}

# Health check for Bastion (TCP SSH)
resource "aws_route53_health_check" "bastion" {
  count = var.enable_health_checks ? 1 : 0

  type              = "TCP"
  ip_address        = var.bastion_elastic_ip
  port              = 22
  failure_threshold = 2
  request_interval  = 30

  tags = {
    Name = "health-check-bastion"
  }
}

# CloudWatch alarm for ALB health check
resource "aws_cloudwatch_metric_alarm" "alb_health" {
  count = var.enable_health_checks ? 1 : 0

  alarm_name          = "route53-alb-health-check-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    HealthCheckId = aws_route53_health_check.alb[0].id
  }

  alarm_description = "Alert when ALB health check fails"
  treat_missing_data = "breaching"
}

# CloudWatch alarm for Bastion health check
resource "aws_cloudwatch_metric_alarm" "bastion_health" {
  count = var.enable_health_checks ? 1 : 0

  alarm_name          = "route53-bastion-health-check-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    HealthCheckId = aws_route53_health_check.bastion[0].id
  }

  alarm_description = "Alert when Bastion health check fails"
  treat_missing_data = "breaching"
}

# ============================================================================
# 7. PRIVATE HOSTED ZONE (internal.domaine.com)
# ============================================================================

resource "aws_route53_zone" "private" {
  name    = "internal.${var.domain_name}"
  comment = "Private hosted zone for internal VPC services"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name        = "zone-internal-${var.domain_name}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Private A record for internal service
resource "aws_route53_record" "internal_service" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "internal.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.internal_service_ip]

  depends_on = [aws_route53_zone.private]
}

# Service discovery pattern: database.internal.domaine.com
resource "aws_route53_record" "internal_database" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.internal.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["10.0.10.20"]  # Example: RDS endpoint in private subnet

  depends_on = [aws_route53_zone.private]
}

# Service discovery pattern: cache.internal.domaine.com
resource "aws_route53_record" "internal_cache" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "cache.internal.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["10.0.11.30"]  # Example: Redis/ElastiCache endpoint

  depends_on = [aws_route53_zone.private]
}

output "private_hosted_zone_id" {
  description = "Private Hosted Zone ID"
  value       = aws_route53_zone.private.zone_id
}

# ============================================================================
# 8. WILDCARD RECORDS (OPTIONAL)
# ============================================================================

# Wildcard for subdomains not explicitly defined
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }

  # Uncomment to enable wildcard routing
  # depends_on = [aws_route53_zone.main]
}

# ============================================================================
# 9. OUTPUTS
# ============================================================================

output "dns_configuration" {
  description = "Complete DNS configuration summary"
  value = {
    zone_id     = aws_route53_zone.main.zone_id
    domain      = var.domain_name
    nameservers = aws_route53_zone.main.name_servers
    records = {
      apex              = "Alias to ALB (${var.alb_dns_name})"
      api               = "Alias to ALB (weighted routing)"
      admin             = "A record to Bastion (${var.bastion_elastic_ip})"
      external_partner  = "A record to external (${var.external_partner_ip})"
      internal_zone     = "Private zone: internal.${var.domain_name}"
    }
    health_checks = {
      alb_enabled     = var.enable_health_checks
      bastion_enabled = var.enable_health_checks
    }
  }
}

output "migration_guide" {
  description = "Steps to configure registrar"
  value = <<-EOT
    1. Copy these nameservers to your registrar (GoDaddy):
       ${join("\n       ", aws_route53_zone.main.name_servers)}

    2. Wait 24-48 hours for DNS propagation

    3. Verify with:
       dig @${aws_route53_zone.main.name_servers[0]} api.${var.domain_name}

    4. Test from multiple locations:
       https://www.whatsmydns.net/
  EOT
}

# ============================================================================
# TERRAFORM WORKSPACE SUPPORT
# ============================================================================

output "terraform_workspace" {
  description = "Terraform workspace for multi-environment"
  value       = terraform.workspace
}
