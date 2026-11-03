#!/usr/bin/env bash
# Blue-Green სტილის დეპლოი + ავტომატური Rollback.
# production/
#   releases/<timestamp>/   <- ყოველი ვერსია ცალკე საქაღალდეში
#   current -> releases/X   <- სიმბოლური ბმული აქტიურ ვერსიაზე
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${DEPLOY_DIR:-$ROOT/production}"
PORT="${PORT:-5000}"
LOG="$ROOT/logs/deploy.log"
mkdir -p "$BASE/releases" "$ROOT/logs"

log() { echo "$(date -u +%FT%TZ) | $*" | tee -a "$LOG"; }

stop_app() {
  if [ -f "$BASE/app.pid" ]; then
    kill "$(cat "$BASE/app.pid")" 2>/dev/null || true
    rm -f "$BASE/app.pid"
    sleep 1
  fi
}

start_app() {
  stop_app
  ( cd "$1" && PORT="$PORT" setsid nohup python run.py > "$BASE/app.log" 2>&1 < /dev/null & echo $! > "$BASE/app.pid" )
  sleep 3
}

NEW="$BASE/releases/$(date +%Y%m%d%H%M%S)"
PREV=""
[ -L "$BASE/current" ] && PREV="$(readlink "$BASE/current")"

log "DEPLOY START -> $NEW (previous: ${PREV:-none})"
mkdir -p "$NEW"
cp -r "$ROOT/app" "$ROOT/run.py" "$ROOT/requirements.txt" "$NEW/"

ln -sfn "$NEW" "$BASE/current"      # გადართვა ახალ ვერსიაზე
start_app "$BASE/current"

if bash "$ROOT/scripts/health_check.sh" "http://localhost:$PORT/health"; then
  log "DEPLOY SUCCESS"
  # ვინახავთ ბოლო 3 რელიზს
  ls -1dt "$BASE"/releases/* | tail -n +4 | xargs -r rm -rf
  exit 0
fi

log "HEALTH CHECK FAILED -> ROLLBACK"
if [ -n "$PREV" ] && [ -d "$PREV" ]; then
  ln -sfn "$PREV" "$BASE/current"
  start_app "$BASE/current"
  log "ROLLBACK DONE -> $PREV"
else
  stop_app
  log "ROLLBACK: წინა ვერსია არ არსებობს, აპლიკაცია გაჩერდა"
fi
rm -rf "$NEW"
exit 1
