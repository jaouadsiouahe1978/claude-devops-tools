#!/usr/bin/env python3
"""
Prompt Guard Hook - Intercepts and optimizes prompts to reduce token consumption.
Hooks into Claude Code UserPromptSubmit event.
"""

import json
import sys
import os
import re
from datetime import datetime
from pathlib import Path

class PromptGuard:
    def __init__(self):
        self.budget_dir = Path.home() / ".claude" / "budget"
        self.budget_dir.mkdir(parents=True, exist_ok=True)
        self.log_file = self.budget_dir / "prompt_guard_log.json"
        self.today = datetime.now().strftime("%Y%m%d")
        self.report_file = self.budget_dir / f"prompt_guard_{self.today}.md"

        # Simplification patterns
        self.patterns = [
            (r'\b(please|kindly|could you|would you|can you|could you please)\b', '', 'filler_words'),
            (r'\b(I think|I believe|in my opinion|it seems like)\b', '', 'opinion_markers'),
            (r'\s+', ' ', 'extra_whitespace'),
            (r'(the\s+)?following\s+(is|are)', 'this', 'verbose_intro'),
        ]

    def calculate_complexity(self, prompt: str) -> int:
        """Calculate complexity score 1-10."""
        length = len(prompt)
        word_count = len(prompt.split())
        sentence_count = len(re.split(r'[.!?]+', prompt))

        score = 1
        if length > 500: score += 2
        if length > 1000: score += 2
        if word_count > 100: score += 1
        if word_count > 250: score += 1
        if sentence_count > 5: score += 1
        if re.search(r'[{}\[\]<>]', prompt): score += 1  # Code/structure

        return min(score, 10)

    def suggest_simplifications(self, prompt: str) -> list:
        """Suggest simplifications for the prompt."""
        suggestions = []

        if len(prompt) > 500:
            suggestions.append("Consider breaking into multiple focused prompts")

        if re.search(r'(please|kindly|could you)', prompt, re.I):
            suggestions.append("Remove courtesy phrases (please, kindly, could you)")

        if re.search(r'(I think|I believe|in my opinion)', prompt, re.I):
            suggestions.append("Remove personal opinion markers")

        if re.search(r'\s{2,}', prompt):
            suggestions.append("Remove extra whitespace")

        if prompt.count('\n') > 10:
            suggestions.append("Consider formatting long lists or code more efficiently")

        return suggestions

    def optimize_prompt(self, prompt: str) -> str:
        """Optimize prompt by applying simplification rules."""
        optimized = prompt

        # Apply patterns carefully
        optimized = re.sub(r'\b(please|kindly)\b', '', optimized, flags=re.I)
        optimized = re.sub(r'\b(could you|would you|can you)\s+', '', optimized, flags=re.I)
        optimized = re.sub(r'\s+', ' ', optimized)
        optimized = optimized.strip()

        return optimized

    def estimate_tokens(self, text: str) -> int:
        """Rough token estimation (1 token ≈ 4 chars for English)."""
        return max(1, len(text) // 4)

    def log_prompt(self, original: str, optimized: str, complexity: int, suggestions: list):
        """Log prompt analysis to JSON file."""
        entry = {
            "timestamp": datetime.now().isoformat(),
            "original_length": len(original),
            "optimized_length": len(optimized),
            "original_tokens": self.estimate_tokens(original),
            "optimized_tokens": self.estimate_tokens(optimized),
            "tokens_saved": self.estimate_tokens(original) - self.estimate_tokens(optimized),
            "complexity_score": complexity,
            "suggestions": suggestions,
            "was_optimized": len(optimized) < len(original)
        }

        # Append to log
        logs = []
        if self.log_file.exists():
            with open(self.log_file, 'r') as f:
                logs = json.load(f)

        logs.append(entry)

        with open(self.log_file, 'w') as f:
            json.dump(logs, f, indent=2)

        return entry

    def process_prompt(self, prompt: str) -> dict:
        """Main processing function."""
        complexity = self.calculate_complexity(prompt)
        suggestions = self.suggest_simplifications(prompt)
        optimized = self.optimize_prompt(prompt) if complexity >= 6 else prompt

        log_entry = self.log_prompt(prompt, optimized, complexity, suggestions)

        return {
            "original": prompt,
            "optimized": optimized,
            "complexity": complexity,
            "suggestions": suggestions,
            "tokens_saved": log_entry["tokens_saved"],
            "was_optimized": log_entry["was_optimized"]
        }

def main():
    """Hook entry point - receives prompt on stdin."""
    try:
        # Read input
        input_data = sys.stdin.read()

        if not input_data.strip():
            sys.stdout.write("")
            return

        # Parse input (should be JSON from Claude Code hook)
        try:
            data = json.loads(input_data)
            prompt = data.get("prompt", input_data)
        except json.JSONDecodeError:
            prompt = input_data

        # Process with Prompt Guard
        guard = PromptGuard()
        result = guard.process_prompt(prompt)

        # Output optimized prompt
        sys.stdout.write(result["optimized"])

    except Exception as e:
        # On error, pass through original prompt
        sys.stdout.write(sys.stdin.read() if hasattr(sys.stdin, 'read') else "")

if __name__ == "__main__":
    main()
