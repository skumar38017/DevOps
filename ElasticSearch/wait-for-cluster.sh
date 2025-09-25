#!/bin/bash
source .env
echo "Waiting for cluster..."
for i in {1..20}; do
  echo "Check $i/20..."
  if curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD -s http://localhost:80/_cluster/health > /dev/null 2>&1; then
    echo "✅ CLUSTER READY!"
    curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD -s http://localhost:80/_cluster/health?pretty
    exit 0
  fi
  sleep 15
done
echo "❌ Timeout"
