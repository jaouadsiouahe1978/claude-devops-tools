#!/bin/bash
set -e

CERT_NAME="${1:-unknown}"
DAYS_LEFT="${2:-0}"
EXPIRY_DATE="${3:-unknown}"
STATUS="${4:-UNKNOWN}"

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
EMAIL_TO="${EMAIL_TO:-}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ALERT] $*"
}

log "Sending alerts for: $CERT_NAME | Status: $STATUS | Days left: $DAYS_LEFT"

# Slack notification
if [ -n "$SLACK_WEBHOOK_URL" ]; then
  log "Sending Slack notification..."

  COLOR="warning"
  if [ "$STATUS" = "EXPIRED" ]; then
    COLOR="danger"
  fi

  PAYLOAD=$(cat <<EOF
{
  "text": "SSL Certificate Alert",
  "attachments": [
    {
      "color": "$COLOR",
      "title": "Certificate: $CERT_NAME",
      "fields": [
        {
          "title": "Status",
          "value": "$STATUS",
          "short": true
        },
        {
          "title": "Days Left",
          "value": "$DAYS_LEFT",
          "short": true
        },
        {
          "title": "Expiry Date",
          "value": "$EXPIRY_DATE",
          "short": false
        }
      ],
      "footer": "SSL/TLS Certificate Monitor",
      "ts": $(date +%s)
    }
  ]
}
EOF
)

  curl -X POST \
    -H 'Content-type: application/json' \
    --data "$PAYLOAD" \
    "$SLACK_WEBHOOK_URL" 2>/dev/null \
    && log "Slack notification sent" \
    || log "Failed to send Slack notification"
fi

# Email notification
if [ -n "$EMAIL_TO" ]; then
  log "Sending email notification to $EMAIL_TO..."

  SUBJECT="SSL Certificate Alert: $CERT_NAME - $STATUS"
  BODY="Certificate: $CERT_NAME\nStatus: $STATUS\nDays Left: $DAYS_LEFT\nExpiry Date: $EXPIRY_DATE\n\nPlease renew this certificate as soon as possible."

  echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL_TO" 2>/dev/null \
    && log "Email notification sent" \
    || log "Failed to send email (mail not configured or unreachable)"
fi

log "Alert processing completed for $CERT_NAME"
