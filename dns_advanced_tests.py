#!/usr/bin/env python3

"""
Route53 Advanced DNS Testing & Monitoring Suite

Infrastructure: Zone Sud-2, VPC 10.0.0.0/16, Clusters A/B, Bastion

Features:
  - Multi-threaded DNS resolution testing
  - Global DNS propagation checks
  - Health check status monitoring
  - Performance metrics collection
  - JSON report generation
  - Continuous monitoring mode

Usage:
  python3 dns_advanced_tests.py --domain domaine.com --environment production
  python3 dns_advanced_tests.py --domain domaine.com --monitor --interval 60
  python3 dns_advanced_tests.py --domain domaine.com --report json
"""

import sys
import json
import time
import socket
import subprocess
import threading
from datetime import datetime
from typing import Dict, List, Tuple, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse
import logging

try:
    import boto3
    import requests
except ImportError:
    print("Error: Missing required packages")
    print("Install with: pip install boto3 requests")
    sys.exit(1)

# ============================================================================
# CONFIGURATION
# ============================================================================

DNS_SERVERS = {
    "Google": "8.8.8.8",
    "Cloudflare": "1.1.1.1",
    "Quad9": "9.9.9.9",
    "OpenDNS": "208.67.222.222",
    "Verisign": "64.6.64.6",
}

HEALTH_CHECK_TIMEOUT = 5  # seconds
MAX_RETRIES = 3
THREAD_POOL_SIZE = 10

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================================================
# CLASSES
# ============================================================================

class DNSResolver:
    """DNS resolution testing with multiple resolvers"""

    def __init__(self, domain: str):
        self.domain = domain
        self.results = {}

    def resolve_via_dig(self, hostname: str, nameserver: str) -> Optional[str]:
        """Resolve using dig command"""
        try:
            result = subprocess.run(
                ['dig', '+short', f'@{nameserver}', hostname, 'A'],
                capture_output=True,
                text=True,
                timeout=HEALTH_CHECK_TIMEOUT
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split('\n')[0]
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        return None

    def resolve_via_socket(self, hostname: str) -> Optional[str]:
        """Resolve using Python socket"""
        try:
            return socket.gethostbyname(hostname)
        except socket.gaierror:
            return None

    def test_resolution(self, hostname: str, resolver_name: str, resolver_ip: str) -> Dict:
        """Test DNS resolution against specific resolver"""
        result = {
            "hostname": hostname,
            "resolver": resolver_name,
            "resolver_ip": resolver_ip,
            "ip": None,
            "method": None,
            "success": False,
            "latency_ms": 0,
        }

        # Try via dig first
        start = time.time()
        ip = self.resolve_via_dig(hostname, resolver_ip)
        latency = (time.time() - start) * 1000

        if ip:
            result["ip"] = ip
            result["method"] = "dig"
            result["success"] = True
            result["latency_ms"] = latency
        else:
            # Fallback to socket
            start = time.time()
            ip = self.resolve_via_socket(hostname)
            latency = (time.time() - start) * 1000

            if ip:
                result["ip"] = ip
                result["method"] = "socket"
                result["success"] = True
                result["latency_ms"] = latency

        return result

    def test_all_resolvers(self, hostname: str) -> List[Dict]:
        """Test resolution against all configured resolvers"""
        results = []

        with ThreadPoolExecutor(max_workers=THREAD_POOL_SIZE) as executor:
            futures = {
                executor.submit(
                    self.test_resolution,
                    hostname,
                    name,
                    ip
                ): (name, ip) for name, ip in DNS_SERVERS.items()
            }

            for future in as_completed(futures):
                try:
                    result = future.result()
                    results.append(result)
                except Exception as e:
                    logger.error(f"Resolution test failed: {e}")

        return results


class Route53Monitor:
    """Monitor Route53 hosted zones and health checks"""

    def __init__(self):
        self.route53 = boto3.client('route53')
        self.cloudwatch = boto3.client('cloudwatch')

    def get_hosted_zone_id(self, domain: str) -> Optional[str]:
        """Get Route53 hosted zone ID for domain"""
        try:
            response = self.route53.list_hosted_zones_by_name(DNSName=domain)
            for zone in response.get('HostedZones', []):
                if zone['Name'] == domain + '.':
                    return zone['Id'].split('/')[-1]
        except Exception as e:
            logger.error(f"Failed to get hosted zone: {e}")
        return None

    def get_records(self, zone_id: str) -> List[Dict]:
        """Get all records in a hosted zone"""
        try:
            records = []
            paginator = self.route53.get_paginator('list_resource_record_sets')
            for page in paginator.paginate(HostedZoneId=zone_id):
                records.extend(page.get('ResourceRecordSets', []))
            return records
        except Exception as e:
            logger.error(f"Failed to get records: {e}")
            return []

    def get_health_check_status(self) -> List[Dict]:
        """Get status of all health checks"""
        try:
            health_checks = []
            response = self.route53.list_health_checks()

            for hc in response.get('HealthChecks', []):
                hc_id = hc['Id']
                status_response = self.route53.get_health_check_status(
                    HealthCheckId=hc_id
                )

                status = {
                    "id": hc_id,
                    "type": hc['HealthCheckConfig'].get('Type', 'Unknown'),
                    "resource_path": hc['HealthCheckConfig'].get('ResourcePath', 'N/A'),
                    "observations": []
                }

                for obs in status_response.get('HealthCheckObservations', [])[:3]:
                    status['observations'].append({
                        "region": obs.get('Region', 'Unknown'),
                        "ip": obs.get('IPAddress', 'Unknown'),
                        "status": obs.get('StatusReport', {}).get('Status', 'Unknown')
                    })

                health_checks.append(status)

            return health_checks
        except Exception as e:
            logger.error(f"Failed to get health check status: {e}")
            return []

    def get_cloudwatch_alarms(self) -> List[Dict]:
        """Get Route53-related CloudWatch alarms"""
        try:
            alarms = []
            response = self.cloudwatch.describe_alarms(AlarmNamePrefix='route53')

            for alarm in response.get('MetricAlarms', []):
                alarms.append({
                    "name": alarm['AlarmName'],
                    "state": alarm['StateValue'],
                    "description": alarm.get('AlarmDescription', 'N/A'),
                    "threshold": alarm.get('Threshold', 'N/A'),
                })

            return alarms
        except Exception as e:
            logger.error(f"Failed to get alarms: {e}")
            return []


class HealthChecker:
    """Test endpoint health"""

    @staticmethod
    def check_http(url: str, timeout: int = HEALTH_CHECK_TIMEOUT) -> Tuple[bool, int, float]:
        """Check HTTP endpoint"""
        try:
            start = time.time()
            response = requests.get(url, timeout=timeout, verify=False)
            latency = (time.time() - start) * 1000
            return response.status_code < 500, response.status_code, latency
        except requests.RequestException:
            return False, 0, 0

    @staticmethod
    def check_tcp(host: str, port: int, timeout: int = HEALTH_CHECK_TIMEOUT) -> Tuple[bool, float]:
        """Check TCP connectivity"""
        try:
            start = time.time()
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))
            latency = (time.time() - start) * 1000
            sock.close()
            return result == 0, latency
        except Exception:
            return False, 0


class ReportGenerator:
    """Generate various report formats"""

    @staticmethod
    def generate_json_report(
        domain: str,
        environment: str,
        dns_results: Dict,
        route53_info: Dict,
        health_status: List[Dict],
        alarms: List[Dict],
    ) -> str:
        """Generate JSON report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "domain": domain,
            "environment": environment,
            "dns_resolution": dns_results,
            "route53": route53_info,
            "health_checks": health_status,
            "cloudwatch_alarms": alarms,
            "summary": {
                "total_checks": len(dns_results.get("records", [])) * len(DNS_SERVERS),
                "propagated_globally": all(
                    result.get("success", False)
                    for records in dns_results.values()
                    if isinstance(records, list)
                    for result in records
                ),
            }
        }
        return json.dumps(report, indent=2, default=str)

    @staticmethod
    def generate_text_report(
        domain: str,
        environment: str,
        dns_results: Dict,
        route53_info: Dict,
        health_status: List[Dict],
        alarms: List[Dict],
    ) -> str:
        """Generate human-readable text report"""
        report = []
        report.append("=" * 70)
        report.append("DNS ROUTE53 VALIDATION REPORT")
        report.append("=" * 70)
        report.append(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Domain: {domain}")
        report.append(f"Environment: {environment}")
        report.append("")

        # DNS Resolution Summary
        report.append("DNS RESOLUTION STATUS")
        report.append("-" * 70)
        for hostname, results in dns_results.items():
            if isinstance(results, list):
                success_count = sum(1 for r in results if r.get("success"))
                report.append(f"{hostname}: {success_count}/{len(results)} resolvers OK")
                for result in results:
                    status = "✓" if result.get("success") else "✗"
                    ip = result.get("ip", "N/A")
                    latency = result.get("latency_ms", 0)
                    report.append(
                        f"  {status} {result['resolver']:15} → {ip:15} ({latency:.1f}ms)"
                    )

        report.append("")

        # Health Checks
        report.append("HEALTH CHECKS")
        report.append("-" * 70)
        if health_status:
            for hc in health_status:
                report.append(f"Health Check {hc['id'][:16]}... ({hc['type']})")
                for obs in hc.get("observations", []):
                    report.append(
                        f"  Region: {obs['region']:15} IP: {obs['ip']:15} Status: {obs['status']}"
                    )
        else:
            report.append("No health checks configured")

        report.append("")

        # CloudWatch Alarms
        report.append("CLOUDWATCH ALARMS")
        report.append("-" * 70)
        if alarms:
            for alarm in alarms:
                status = "🔴" if alarm["state"] == "ALARM" else "🟢"
                report.append(f"{status} {alarm['name']}: {alarm['state']}")
        else:
            report.append("No Route53 alarms configured")

        report.append("")
        report.append("=" * 70)

        return "\n".join(report)


# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

def run_tests(
    domain: str,
    environment: str = "production",
    report_format: str = "text"
) -> Dict:
    """Run all DNS tests"""
    logger.info(f"Starting DNS validation for {domain} ({environment})")

    # Initialize clients
    resolver = DNSResolver(domain)
    monitor = Route53Monitor()
    health_checker = HealthChecker()

    # Get Route53 zone
    zone_id = monitor.get_hosted_zone_id(domain)
    if not zone_id:
        logger.error(f"Hosted zone not found for {domain}")
        return {}

    logger.info(f"Found hosted zone: {zone_id}")

    # Get records
    records = monitor.get_records(zone_id)
    record_names = [r['Name'] for r in records if r['Type'] in ['A', 'AAAA']]

    logger.info(f"Found {len(record_names)} A/AAAA records")

    # Test DNS resolution for each record
    dns_results = {}
    for record_name in record_names[:5]:  # Limit to first 5 for demo
        logger.info(f"Testing resolution for {record_name}")
        results = resolver.test_all_resolvers(record_name.rstrip('.'))
        dns_results[record_name] = results

    # Get health check status
    health_status = monitor.get_health_check_status()

    # Get alarms
    alarms = monitor.get_cloudwatch_alarms()

    # Build route53 info
    route53_info = {
        "zone_id": zone_id,
        "record_count": len(records),
        "a_records": sum(1 for r in records if r['Type'] == 'A'),
        "cname_records": sum(1 for r in records if r['Type'] == 'CNAME'),
        "alias_records": sum(1 for r in records if r.get('AliasTarget')),
    }

    # Generate report
    if report_format == "json":
        report = ReportGenerator.generate_json_report(
            domain, environment, dns_results, route53_info, health_status, alarms
        )
    else:
        report = ReportGenerator.generate_text_report(
            domain, environment, dns_results, route53_info, health_status, alarms
        )

    return {
        "zone_id": zone_id,
        "dns_results": dns_results,
        "route53_info": route53_info,
        "health_status": health_status,
        "alarms": alarms,
        "report": report,
    }


def continuous_monitoring(
    domain: str,
    environment: str = "production",
    interval: int = 60
):
    """Continuous monitoring mode"""
    logger.info(f"Starting continuous monitoring (interval: {interval}s)")

    try:
        while True:
            results = run_tests(domain, environment)
            print(results.get("report", ""))
            print(f"\nNext check in {interval}s...")
            time.sleep(interval)
    except KeyboardInterrupt:
        logger.info("Monitoring stopped by user")


# ============================================================================
# CLI
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Route53 Advanced DNS Testing & Monitoring"
    )
    parser.add_argument(
        "--domain",
        required=True,
        help="Domain name to test"
    )
    parser.add_argument(
        "--environment",
        default="production",
        choices=["development", "staging", "production"],
        help="Environment name"
    )
    parser.add_argument(
        "--monitor",
        action="store_true",
        help="Continuous monitoring mode"
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=60,
        help="Monitoring interval in seconds"
    )
    parser.add_argument(
        "--report",
        default="text",
        choices=["text", "json"],
        help="Report format"
    )
    parser.add_argument(
        "--output",
        type=str,
        help="Save report to file"
    )

    args = parser.parse_args()

    if args.monitor:
        continuous_monitoring(args.domain, args.environment, args.interval)
    else:
        results = run_tests(args.domain, args.environment, args.report)

        report = results.get("report", "No report generated")
        print(report)

        if args.output:
            with open(args.output, 'w') as f:
                f.write(report)
            logger.info(f"Report saved to {args.output}")


if __name__ == "__main__":
    main()
