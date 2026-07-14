# Prompt Guard System

A Claude Code hook system that automatically intercepts and optimizes prompts to reduce token consumption and improve efficiency.

## Overview

The Prompt Guard system monitors all prompts submitted to Claude and:
- **Detects** unnecessarily complex or verbose prompts
- **Suggests** simplifications to reduce token usage
- **Optimizes** prompts automatically when complexity is high (score 6+)
- **Logs** all interactions for analysis
- **Reports** daily statistics on optimization effectiveness

## Components

### 1. **prompt-guard.py**
The main hook script that runs on every UserPromptSubmit event.

**Features:**
- Calculates complexity score (1-10 scale)
- Suggests simplifications based on patterns
- Optimizes prompts by removing filler words
- Estimates token savings
- Logs all interactions to JSON

**Complexity Scoring:**
- Length (>500 chars: +2, >1000 chars: +2)
- Word count (>100: +1, >250: +1)
- Sentence count (>5: +1)
- Code/structure markers ({}, [], <>: +1)
- **Result:** Score between 1-10

**Simplification Rules:**
- Remove courtesy phrases (please, kindly, could you)
- Remove opinion markers (I think, I believe, in my opinion)
- Clean up whitespace
- Simplify verbose introductions

### 2. **maintain-prompt-guard.py**
Daily maintenance routine for monitoring and reporting.

**Functions:**
- Verifies hook configuration is valid
- Analyzes logs and calculates statistics
- Generates daily reports
- Identifies optimization opportunities
- Tracks complexity trends

**Run with:**
```bash
python3 .claude/maintain-prompt-guard.py
```

### 3. **settings.json**
Project-level configuration for Claude Code hooks.

**Hook Configuration:**
```json
{
  "hooks": {
    "UserPromptSubmit": {
      "description": "Prompt Guard - Intercepts and optimizes prompts",
      "script": "prompt-guard.py",
      "timeout": 2000,
      "enabled": true
    }
  }
}
```

## Log Files

### Location
- **Log file:** `.claude/budget/prompt_guard_log.json`
- **Reports:** `.claude/budget/prompt_guard_YYYYMMDD.md`

### Log Structure
Each entry contains:
```json
{
  "timestamp": "2026-07-14T06:58:00.000Z",
  "original_length": 500,
  "optimized_length": 450,
  "original_tokens": 125,
  "optimized_tokens": 112,
  "tokens_saved": 13,
  "complexity_score": 7,
  "suggestions": ["Remove courtesy phrases"],
  "was_optimized": true
}
```

## Statistics & Reporting

### Daily Report Includes
- **Hook Status:** Configuration validation
- **Statistics:**
  - Total prompts analyzed
  - Optimization rate %
  - Total tokens saved
  - Average complexity score
- **Distribution:** Complexity breakdown
- **Suggestions:** Most common optimization opportunities

### Example Report
See `prompt_guard_20260714.md` for daily reports.

## Usage

### Automatic Monitoring
The hook runs automatically on every prompt submission. No action needed.

### Manual Analysis
```bash
# Run daily maintenance
python3 .claude/maintain-prompt-guard.py

# View today's report
cat .claude/budget/prompt_guard_20260714.md

# View all logs
cat .claude/budget/prompt_guard_log.json | jq '.'
```

### View Optimization Metrics
```bash
# Count optimized prompts
cat .claude/budget/prompt_guard_log.json | jq '[.[] | select(.was_optimized)] | length'

# Total tokens saved
cat .claude/budget/prompt_guard_log.json | jq '[.[] | .tokens_saved] | add'

# Average complexity
cat .claude/budget/prompt_guard_log.json | jq '[.[] | .complexity_score] | add / length'
```

## Configuration

### Enable/Disable Hook
Edit `.claude/settings.json`:
```json
"enabled": true  // Set to false to disable
```

### Adjust Timeout
Hook processing timeout in milliseconds:
```json
"timeout": 2000  // 2 seconds
```

### Add Custom Rules
Edit `prompt-guard.py` `patterns` list to add new simplification rules:
```python
self.patterns = [
    (r'pattern', 'replacement', 'category'),
    # Add your rules here
]
```

## Performance

### Token Estimation
Uses rough approximation: **1 token ≈ 4 characters** for English text.

### Hook Overhead
- **Execution time:** ~50-100ms per prompt
- **Memory:** Minimal (logs stored to disk)
- **Disk usage:** ~1-5KB per prompt (logs)

## Troubleshooting

### Hook Not Running
1. Check hook is enabled: `settings.json` → `enabled: true`
2. Verify script path exists: `.claude/prompt-guard.py`
3. Check file permissions: Should be executable (`-rwx`)

### No Logs Generated
- Hook may need a new prompt submission to trigger
- Check log file exists: `.claude/budget/prompt_guard_log.json`
- Try manual test with `python3 prompt-guard.py <<< "test prompt"`

### Invalid Configuration
- Validate JSON: `python3 -m json.tool settings.json`
- Ensure script path is relative to `.claude/` directory
- Restart Claude Code after config changes

## Future Enhancements

1. **ML-based complexity detection** using transformers
2. **Custom rule engine** for domain-specific optimization
3. **Integration with token counting API** for precise estimates
4. **Visualization dashboards** for metrics
5. **Rule suggestions** based on frequent patterns
6. **Batch processing** for historical prompt analysis

## Related Files

- `.claude/settings.json` - Hook configuration
- `.claude/prompt-guard.py` - Main hook script
- `.claude/maintain-prompt-guard.py` - Maintenance routine
- `.claude/budget/` - Logs and reports directory

## Support

For issues or questions, check the maintenance report:
```bash
python3 .claude/maintain-prompt-guard.py
```

The report will indicate any configuration issues and provide optimization recommendations.
