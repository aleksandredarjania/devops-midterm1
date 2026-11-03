#!/usr/bin/env bash
# გამოყენება: scripts/health_check.sh [URL]
# წერს შედეგს logs/health.log-ში. Exit code: 0 = OK, 1 = FAIL
URL="${1:-http://localhost:5000/health}"
LOG_DIR="$(cd "$(dirname "$0")/.." && pwd)/logs"
LOG_FILE="$LOG_DIR/health.log"
RETRIES="${RETRIES:-5}"
mkdir -p "$LOG_DIR"

for i in $(seq 1 "$RETRIES"); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" || true)
  NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  if [ "$CODE" = "200" ]; then
    echo "$NOW | UP | HTTP $CODE | $URL" | tee -a "$LOG_FILE"
    exit 0
  fi
  echo "$NOW | DOWN | HTTP ${CODE:-000} | $URL | attempt $i/$RETRIES" | tee -a "$LOG_FILE"
  sleep 2
done
exit 1
