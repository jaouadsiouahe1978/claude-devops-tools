#!/usr/bin/env python3
"""
Daily Prompt Guard Maintenance Routine
- Verifies hook configuration
- Analyzes logs and calculates statistics
- Generates daily reports
- Updates rules if needed
"""

import json
import sys
from datetime import datetime
from pathlib import Path
from collections import defaultdict

class PromptGuardMaintenance:
    def __init__(self):
        self.claude_dir = Path(__file__).parent
        self.budget_dir = self.claude_dir / "budget"
        self.budget_dir.mkdir(parents=True, exist_ok=True)
        self.log_file = self.budget_dir / "prompt_guard_log.json"
        self.today = datetime.now().strftime("%Y%m%d")
        self.report_file = self.budget_dir / f"prompt_guard_{self.today}.md"
        self.settings_file = self.claude_dir / "settings.json"

    def verify_hook_config(self) -> dict:
        """Verify Prompt Guard hook is properly configured."""
        status = {
            "hook_configured": False,
            "script_exists": False,
            "valid_config": False,
            "issues": []
        }

        # Check if settings.json exists
        if not self.settings_file.exists():
            status["issues"].append("settings.json not found")
            return status

        try:
            with open(self.settings_file, 'r') as f:
                settings = json.load(f)

            # Check if UserPromptSubmit hook is configured
            if "hooks" in settings and "UserPromptSubmit" in settings["hooks"]:
                hook_config = settings["hooks"]["UserPromptSubmit"]
                status["hook_configured"] = True

                # Check if script exists
                script_path = self.claude_dir / hook_config.get("script", "prompt-guard.py")
                if script_path.exists():
                    status["script_exists"] = True
                else:
                    status["issues"].append(f"Script not found: {script_path}")

                # Verify enabled status
                if hook_config.get("enabled", True):
                    status["valid_config"] = status["script_exists"]
                else:
                    status["issues"].append("Hook is disabled")
            else:
                status["issues"].append("UserPromptSubmit hook not configured in settings.json")

        except json.JSONDecodeError as e:
            status["issues"].append(f"Invalid JSON in settings.json: {e}")

        return status

    def analyze_logs(self) -> dict:
        """Analyze Prompt Guard logs and calculate statistics."""
        stats = {
            "total_prompts": 0,
            "prompts_optimized": 0,
            "total_tokens_saved": 0,
            "average_complexity": 0.0,
            "optimization_rate": 0.0,
            "average_tokens_saved_per_prompt": 0,
            "complexity_distribution": defaultdict(int),
            "suggestions_frequency": defaultdict(int)
        }

        if not self.log_file.exists():
            return stats

        try:
            with open(self.log_file, 'r') as f:
                logs = json.load(f)

            if not logs:
                return stats

            stats["total_prompts"] = len(logs)
            complexity_scores = []

            for entry in logs:
                if entry.get("was_optimized", False):
                    stats["prompts_optimized"] += 1

                stats["total_tokens_saved"] += entry.get("tokens_saved", 0)

                complexity = entry.get("complexity_score", 0)
                complexity_scores.append(complexity)
                stats["complexity_distribution"][complexity] += 1

                for suggestion in entry.get("suggestions", []):
                    stats["suggestions_frequency"][suggestion] += 1

            if stats["total_prompts"] > 0:
                stats["optimization_rate"] = (stats["prompts_optimized"] / stats["total_prompts"]) * 100
                stats["average_complexity"] = sum(complexity_scores) / len(complexity_scores)
                stats["average_tokens_saved_per_prompt"] = stats["total_tokens_saved"] // stats["total_prompts"]

        except json.JSONDecodeError:
            stats["issues"] = "Error reading log file"

        return stats

    def generate_report(self, hook_status: dict, stats: dict):
        """Generate daily maintenance report."""
        report_lines = [
            "# Prompt Guard Daily Report",
            f"\n**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}",
            "\n## Hook Configuration Status",
            f"- **Hook Configured:** {'✅ Yes' if hook_status['hook_configured'] else '❌ No'}",
            f"- **Script Exists:** {'✅ Yes' if hook_status['script_exists'] else '❌ No'}",
            f"- **Valid Configuration:** {'✅ Yes' if hook_status['valid_config'] else '❌ No'}",
        ]

        if hook_status["issues"]:
            report_lines.append("\n### Issues Found:")
            for issue in hook_status["issues"]:
                report_lines.append(f"- ⚠️ {issue}")

        report_lines.extend([
            "\n## Statistics",
            f"- **Total Prompts Analyzed:** {stats['total_prompts']}",
            f"- **Prompts Optimized:** {stats['prompts_optimized']}",
            f"- **Optimization Rate:** {stats['optimization_rate']:.1f}%",
            f"- **Total Tokens Saved:** {stats['total_tokens_saved']:,}",
            f"- **Average Tokens Saved/Prompt:** {stats['average_tokens_saved_per_prompt']}",
            f"- **Average Complexity Score:** {stats['average_complexity']:.1f}/10",
        ])

        if stats["complexity_distribution"]:
            report_lines.append("\n### Complexity Distribution:")
            for score in sorted(stats["complexity_distribution"].keys()):
                count = stats["complexity_distribution"][score]
                report_lines.append(f"- Score {score}: {count} prompts")

        if stats["suggestions_frequency"]:
            report_lines.append("\n### Most Common Simplification Suggestions:")
            sorted_suggestions = sorted(
                stats["suggestions_frequency"].items(),
                key=lambda x: x[1],
                reverse=True
            )
            for suggestion, count in sorted_suggestions[:5]:
                report_lines.append(f"- {suggestion}: {count} times")

        report_lines.extend([
            "\n## Recommendations",
            "- Review high-complexity prompts (score 8-10) for optimization opportunities",
            "- Consider adding custom simplification rules based on common patterns",
            "- Monitor optimization rate to ensure effectiveness",
            "\n---",
            f"*Generated by Prompt Guard Maintenance at {datetime.now().isoformat()}*"
        ])

        report_content = "\n".join(report_lines)

        with open(self.report_file, 'w') as f:
            f.write(report_content)

        return report_content

    def run_maintenance(self):
        """Execute complete maintenance routine."""
        print("🔍 Prompt Guard Daily Maintenance")
        print("=" * 50)

        # 1. Verify hook configuration
        print("\n1️⃣  Verifying hook configuration...")
        hook_status = self.verify_hook_config()
        if hook_status["valid_config"]:
            print("   ✅ Hook is properly configured")
        else:
            print("   ❌ Issues found with hook configuration:")
            for issue in hook_status["issues"]:
                print(f"      - {issue}")

        # 2. Analyze logs
        print("\n2️⃣  Analyzing logs...")
        stats = self.analyze_logs()
        print(f"   - Total prompts: {stats['total_prompts']}")
        print(f"   - Optimized: {stats['prompts_optimized']} ({stats['optimization_rate']:.1f}%)")
        print(f"   - Tokens saved: {stats['total_tokens_saved']:,}")
        print(f"   - Avg complexity: {stats['average_complexity']:.1f}/10")

        # 3. Generate report
        print("\n3️⃣  Generating report...")
        report = self.generate_report(hook_status, stats)
        print(f"   ✅ Report saved to: {self.report_file}")

        # 4. Print summary
        print("\n📊 Summary:")
        print(f"   Hook Status: {'✅ Ready' if hook_status['valid_config'] else '⚠️ Needs attention'}")
        print(f"   Active Monitoring: {'✅ Yes' if stats['total_prompts'] > 0 else '⚠️ No data yet'}")
        print(f"   Optimization Efficiency: {stats['optimization_rate']:.1f}%")

if __name__ == "__main__":
    maintenance = PromptGuardMaintenance()
    maintenance.run_maintenance()
