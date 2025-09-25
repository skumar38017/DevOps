# Elasticsearch Cluster with Nginx Load Balancer

Production-ready 3-node Elasticsearch cluster with nginx load balancer, optimized for Raspberry Pi 4.

## 🏗️ Architecture

```
Client → Nginx (Port 80) → Load Balancer → Elasticsearch Cluster
                                        ├── elasticsearch-es01 (Port 9200)
                                        ├── elasticsearch-es02 (Port 9200)  
                                        └── elasticsearch-es03 (Port 9200)
```

## 🚀 Quick Start

### Start Cluster
```bash
docker compose up -d
```

### Check Health
```bash
curl http://100.86.190.125:80/_cluster/health?pretty
```

## 📁 Project Structure

```
ElasticSearch/
├── docker-compose.yml              # Main orchestration
├── .env                            # Environment variables
├── storage/                        # Configuration storage
│   ├── elasticsearch/              # ES config templates
│   ├── es01/, es02/, es03/         # Node-specific configs
│   └── nginx/nginx.conf            # Load balancer config
├── monitor.sh                      # Monitoring script
└── maintenance.sh                  # Maintenance script
```

## 🌐 Access Points

### Load Balanced (Recommended)
```
http://100.86.190.125:80
```

### Direct Access
```
http://100.86.190.125:9200
```

## 📊 Essential Commands

### Cluster Operations
```bash
# Cluster health
curl http://100.86.190.125:80/_cluster/health?pretty

# Node info
curl http://100.86.190.125:80/_cat/nodes?v

# List indices
curl http://100.86.190.125:80/_cat/indices?v
```

### Index Operations
```bash
# Create index
curl -X PUT http://100.86.190.125:80/my-index

# Add document
curl -X POST http://100.86.190.125:80/my-index/_doc \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Elasticsearch"}'

# Search
curl http://100.86.190.125:80/my-index/_search?pretty
```

## 🔍 Monitoring

### Built-in Script
```bash
./monitor.sh
```

### Manual Checks
```bash
# Container status
docker ps

# Logs
docker logs elasticsearch-es01 --tail 20
docker logs nginx-elasticsearch-proxy --tail 20

# Resources
docker stats --no-stream
```

## 🛠️ Maintenance

### Automated
```bash
./maintenance.sh
```

### Manual
```bash
# Restart cluster
docker compose restart

# Update config and restart
docker compose down
docker compose up -d
```

## ⚡ Performance Features

### Optimizations Applied
- **Memory**: 1GB heap per ES node (3GB total)
- **CPU**: 4-core ARM64 optimized
- **Nginx**: 4 workers, 2048 connections
- **Security**: Rate limiting, headers, authentication

### Resource Usage
- **Total Memory**: ~4GB of 8GB Pi RAM
- **Storage**: Persistent volumes for data/logs
- **Network**: Docker bridge isolation

## 🔒 Security

### Features Enabled
- Basic authentication
- Rate limiting (100 req/s)
- Security headers (XSS, CSRF protection)
- Network isolation

### Access Control
```bash
# Health check endpoint
curl http://100.86.190.125:80/nginx-health
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Check cluster status
curl http://100.86.190.125:80/_cluster/health

# View logs for errors
docker logs elasticsearch-es01
docker logs nginx-elasticsearch-proxy

# Restart if needed
docker compose restart
```

### System Requirements
```bash
# Verify vm.max_map_count
sysctl vm.max_map_count
# Should be >= 262144

# Check available memory
free -h
# Should have 8GB total
```

## 📈 API Examples

### Basic Operations
```bash
# Create index with mapping
curl -X PUT http://100.86.190.125:80/products \
  -H "Content-Type: application/json" \
  -d '{
    "mappings": {
      "properties": {
        "name": {"type": "text"},
        "price": {"type": "float"}
      }
    }
  }'

# Bulk insert
curl -X POST http://100.86.190.125:80/_bulk \
  -H "Content-Type: application/json" \
  -d '
{"index":{"_index":"products"}}
{"name":"Laptop","price":999.99}
{"index":{"_index":"products"}}
{"name":"Mouse","price":29.99}
'

# Search with filters
curl -X POST http://100.86.190.125:80/products/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [{"match": {"name": "laptop"}}],
        "filter": [{"range": {"price": {"gte": 500}}}]
      }
    }
  }'
```

## 🔄 Backup & Recovery

### Configuration Backup
```bash
# Manual backup
tar -czf backup_$(date +%Y%m%d).tar.gz storage/

# Automated (weekly cron)
# Runs via maintenance.sh
```

### Data Snapshots
```bash
# Create snapshot repository
curl -X PUT http://100.86.190.125:80/_snapshot/backup \
  -H "Content-Type: application/json" \
  -d '{"type": "fs", "settings": {"location": "/backup"}}'

# Create snapshot
curl -X PUT http://100.86.190.125:80/_snapshot/backup/snap1
```

## 🎯 Best Practices

### Development
- Always use load balancer endpoint (port 80)
- Monitor cluster health regularly
- Use appropriate data types in mappings
- Keep indices reasonably sized

### Production
- Regular backups via maintenance script
- Monitor system resources
- Update security credentials
- Implement proper logging

## 📞 Quick Reference

### Health Checks
```bash
# All-in-one health check
curl http://100.86.190.125:80/nginx-health && \
curl http://100.86.190.125:80/_cluster/health
```

### Performance Stats
```bash
# Node performance
curl http://100.86.190.125:80/_nodes/stats?pretty

# Cluster stats
curl http://100.86.190.125:80/_cluster/stats?pretty
```

---

## 🏆 Status: Production Ready ✅

- **Cluster**: GREEN (3/3 nodes healthy)
- **Load Balancer**: Active
- **Security**: Enabled  
- **Monitoring**: Automated
- **Backups**: Scheduled

**Ready for production workloads!**
