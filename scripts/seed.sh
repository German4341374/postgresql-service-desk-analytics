#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck source=common.sh
source "$(dirname "$0")/common.sh"

SEED_SCALE="${SEED_SCALE:-0.01}"
if ! counts="$(awk -v scale="$SEED_SCALE" 'BEGIN {
  if (scale <= 0 || scale > 1) { exit 2 }
  users = int(100000 * scale); if (users < 100) users = 100;
  devices = int(200000 * scale); if (devices < 200) devices = 200;
  technicians = int(2000 * scale); if (technicians < 20) technicians = 20;
  incidents = int(1000000 * scale); if (incidents < 1000) incidents = 1000;
  printf "%d %d %d %d", users, devices, technicians, incidents;
}')"; then
  printf 'SEED_SCALE must be a number greater than 0 and no greater than 1: %s\n' "$SEED_SCALE" >&2
  exit 1
fi
read -r USER_COUNT DEVICE_COUNT TECHNICIAN_COUNT INCIDENT_COUNT <<<"$counts"

printf 'Generating deterministic dataset: users=%d devices=%d technicians=%d incidents=%d scale=%s\n' \
  "$USER_COUNT" "$DEVICE_COUNT" "$TECHNICIAN_COUNT" "$INCIDENT_COUNT" "$SEED_SCALE"

psql_db \
  --set=user_count="$USER_COUNT" \
  --set=device_count="$DEVICE_COUNT" \
  --set=technician_count="$TECHNICIAN_COUNT" \
  --set=incident_count="$INCIDENT_COUNT" \
  --file=/workspace/seed/001_reference_data.sql

psql_db \
  --set=user_count="$USER_COUNT" \
  --set=device_count="$DEVICE_COUNT" \
  --set=technician_count="$TECHNICIAN_COUNT" \
  --set=incident_count="$INCIDENT_COUNT" \
  --file=/workspace/seed/010_generate_data.sql
