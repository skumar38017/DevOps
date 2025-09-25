#!/bin/bash
# Elasticsearch Cluster Monitoring Script

# Load environment variables
source .env

echo "=== ELASTICSEARCH CLUSTER MONITORING ==="
echo "Timestamp: $(date)"
echo

echo "=== CLUSTER HEALTH ==="
curl -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -s http://localhost:80/_cluster/health?pretty

echo -e "\n=== NODE STATS ==="
curl -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -s http://localhost:80/_cat/nodes?v

echo -e "\n=== INDICES ==="
curl -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -s http://localhost:80/_cat/indices?v

echo -e "\n=== SYSTEM RESOURCES ==="
echo "Memory Usage:"
free -h
echo -e "\nDisk Usage:"
df -h /
echo -e "\nDocker Stats:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo -e "\n=== NGINX STATUS ==="
curl -s http://localhost:80/nginx-health
echo
