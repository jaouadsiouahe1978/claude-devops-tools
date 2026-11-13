#!/bin/bash
set -euo pipefail
echo 'Backing up...'
tar -czf backup_$(date +%s).tar.gz /data
echo 'Done!'
