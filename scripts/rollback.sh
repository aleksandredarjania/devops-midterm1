#!/usr/bin/env bash
# ხელით Rollback: გადადის ერთი ვერსიით უკან
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${DEPLOY_DIR:-$ROOT/production}"
CUR="$(readlink "$BASE/current")"
PREV="$(ls -1dt "$BASE"/releases/* | grep -v "$CUR" | head -n 1)"
[ -z "$PREV" ] && { echo "წინა ვერსია არ მოიძებნა"; exit 1; }
ln -sfn "$PREV" "$BASE/current"
[ -f "$BASE/app.pid" ] && kill "$(cat "$BASE/app.pid")" 2>/dev/null || true
( cd "$BASE/current" && setsid nohup python run.py > "$BASE/app.log" 2>&1 < /dev/null & echo $! > "$BASE/app.pid" )
echo "$(date -u +%FT%TZ) | MANUAL ROLLBACK -> $PREV" | tee -a "$ROOT/logs/deploy.log"
