# Elasticsearch Cluster with Two-Tier Nginx Security Architecture

Production-ready 3-node Elasticsearch cluster with advanced two-tier nginx security architecture, optimized for Raspberry Pi 4.

## 🏗️ Two-Tier Security Architecture

```
Public/Users → Host Nginx (80/443) → Docker Nginx (127.0.0.1:8080) → Elasticsearch Cluster
                                                                    ├── elasticsearch-es01
                                                                    ├── elasticsearch-es02  
                                                                    └── elasticsearch-es03
```

### Security Layers:
1. **Host Machine Nginx**: Public-facing proxy with SSL/TLS, rate limiting, security headers
2. **Docker Nginx**: Internal load balancer, no public exposure
3. **Elasticsearch Cluster**: Internal network only, no direct access

## 🚀 Quick Start

### Start Cluster
```bash
docker compose up -d
```

### Check Health
```bash
curl http://100.86.190.125:80/_cluster/health?pretty
# Or using server name
curl http://elasticsearch.local:80/_cluster/health?pretty
```

## 🌐 Access Points

### Development (HTTP)
```bash
# By IP address
http://100.86.190.125:80

# By server name (add to /etc/hosts)
http://elasticsearch.local:80
```

### Production (HTTPS)
```bash
# Secure access with SSL
https://elasticsearch.local:443
```

### Blocked Ports (Security)
- ❌ **Port 9200**: Completely blocked (no direct ES access)
- ❌ **Docker ports**: Internal only (127.0.0.1:8080)

## 💻 Code Integration Examples

### Base URLs for Applications
```bash
# Development
ES_DEV_URL="http://100.86.190.125:80"
ES_DEV_HOST="http://elasticsearch.local:80"

# Production  
ES_PROD_URL="https://elasticsearch.local:443"
```

### Python
```python
from elasticsearch import Elasticsearch

# Connect to cluster
es = Elasticsearch([
    {'host': '100.86.190.125', 'port': 80, 'scheme': 'http'},
    # Or using server name
    {'host': 'elasticsearch.local', 'port': 80, 'scheme': 'http'}
])

# Check cluster health
health = es.cluster.health()
print(f"Cluster status: {health['status']}")
```

### Node.js
```javascript
const { Client } = require('@elastic/elasticsearch');

// Connect to cluster
const client = new Client({
  node: 'http://100.86.190.125:80'
  // Or: node: 'http://elasticsearch.local:80'
});

// Check cluster health
async function checkHealth() {
  const health = await client.cluster.health();
  console.log('Cluster status:', health.body.status);
}
```

### Environment Variables
```bash
# Add to your application's .env file
ELASTICSEARCH_HOST=100.86.190.125
ELASTICSEARCH_PORT=80
ELASTICSEARCH_SCHEME=http
ELASTICSEARCH_URL=http://elasticsearch.local:80

# For production
ELASTICSEARCH_PROD_URL=https://elasticsearch.local:443
```

## 📊 API Usage Examples

### Basic Operations
```bash
# Cluster health
curl http://elasticsearch.local:80/_cluster/health?pretty

# Node information
curl http://elasticsearch.local:80/_cat/nodes?v

# Create index
curl -X PUT http://elasticsearch.local:80/my-index

# Add document
curl -X POST http://elasticsearch.local:80/my-index/_doc \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Elasticsearch"}'

# Search documents
curl http://elasticsearch.local:80/my-index/_search?pretty
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
sudo tail -f /var/log/nginx/elasticsearch-dev.access.log
```

## 🔒 Security Features

### Two-Tier Protection
1. **Host Nginx Security**:
   - Rate limiting (200 req/s dev, 100 req/s prod)
   - Security headers (XSS, CSRF, HSTS)
   - SSL/TLS encryption (production)

2. **Docker Network Isolation**:
   - Internal-only Docker nginx (127.0.0.1:8080)
   - No public port exposure for Elasticsearch
   - Container network isolation

3. **Access Control**:
   - Only standard ports exposed (80, 443)
   - Port 9200 completely blocked

## 🚨 Troubleshooting

### Common Issues
```bash
# Check services
docker ps
sudo systemctl status nginx

# Test connectivity
curl http://localhost:80/_cluster/health

# Verify blocked ports
curl http://localhost:9200/_cluster/health  # Should fail
```

## 🏆 Status: Production Ready ✅

- **Architecture**: Two-tier security (Host + Docker nginx)
- **Cluster**: GREEN (3/3 nodes healthy)
- **Security**: Maximum protection (no direct ES access)
- **SSL**: Enabled for production
- **Access**: Standard ports only (80, 443)

**Your Elasticsearch cluster is ready for production workloads with enterprise-grade security!**
