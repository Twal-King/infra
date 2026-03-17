#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[$(date)] Syncing repositories..."

cd "$SCRIPT_DIR/backend" && git pull --rebase
cd "$SCRIPT_DIR/frontend" && git pull --rebase

echo "[$(date)] Sync complete."
