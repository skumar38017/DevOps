#!/bin/bash
# Elasticsearch Maintenance Script

BACKUP_DIR="/home/pi/elasticsearch-backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "=== ELASTICSEARCH MAINTENANCE ==="
echo "Timestamp: $(date)"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup configuration
echo "Backing up configuration..."
tar -czf $BACKUP_DIR/config_backup_$DATE.tar.gz storage/

# Clean old logs (keep last 7 days)
echo "Cleaning old logs..."
docker exec elasticsearch-es01 find /usr/share/elasticsearch/logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
docker exec elasticsearch-es02 find /usr/share/elasticsearch/logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
docker exec elasticsearch-es03 find /usr/share/elasticsearch/logs -name "*.log" -mtime +7 -delete 2>/dev/null || true

# Optimize indices
echo "Optimizing indices..."
curl -s -X POST "localhost:80/_forcemerge?max_num_segments=1" > /dev/null

# Clear cache
echo "Clearing cache..."
curl -s -X POST "localhost:80/_cache/clear" > /dev/null

# System cleanup
echo "System cleanup..."
docker system prune -f > /dev/null 2>&1

echo "Maintenance completed at $(date)"
