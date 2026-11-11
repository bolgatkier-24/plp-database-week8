#!/bin/bash
# MediTrack – Database Backup Script
# Usage: ./backup.sh

set -e

BACKUP_DIR="$(dirname "$0")/../backups"
DATE=$(date +%F)
FILENAME="capstone_${DATE}.dump"
FULL_PATH="${BACKUP_DIR}/${FILENAME}"

mkdir -p "$BACKUP_DIR"

echo "Starting backup of database 'capstone'..."
pg_dump -Fc -f "$FULL_PATH" -h localhost -U postgres capstone

echo "Backup completed: $FULL_PATH"
ls -lh "$FULL_PATH"
