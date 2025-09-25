# Redis Cluster with SSL Proxy

A production-ready Redis cluster setup with secure SSL proxy and load balancing using Docker Compose and Nginx.

## Architecture

```
Client → Main Nginx (SSL/Non-SSL) → Docker Nginx → Redis Cluster [5 Nodes]
```

**Flow:**
- **Port 6381**: SSL endpoint (production)
- **Port 6382**: Non-SSL endpoint (testing)
- **Internal**: Docker nginx (6380) → Redis nodes (7001, 7002, 7003, 7004, 7005)

## Features

- ✅ **5-Node Redis Cluster** with hash slot distribution
- ✅ **SSL Termination** with self-signed certificates
- ✅ **Load Balancing** across Redis nodes
- ✅ **Security**: Internal services not exposed
- ✅ **High Availability** with auto-restart
- ✅ **Dual Access** modes (SSL + Non-SSL)

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Nginx with stream module
- Redis CLI

### 1. Clone and Setup
```bash
cd ~/Documents/DevOps
```

### 2. Environment Configuration
Create `.env` file:
```env
# Redis Configuration
REDIS_DB_IMAGE=redis:7.4.4-alpine
REDIS_DB_USERNAME=kumar_house
REDIS_DB_PASSWORD=kumar_house

# Redis Node Ports
REDIS_NODE_1_PORT=7001
REDIS_NODE_2_PORT=7002
REDIS_NODE_3_PORT=7003
REDIS_NODE_4_PORT=7004
REDIS_NODE_5_PORT=7005

# Nginx Proxy Ports
REDIS_HOST_PORT=6380
REDIS_SSL_PORT=6381
NGINX_STATUS_PORT=8080
```

### 3. Start Services
```bash
# Start Redis cluster and Docker nginx
docker compose -f docker-compose-cluster.yml --env-file .env up -d

# Start main nginx (SSL proxy)
sudo systemctl start nginx
```

### 4. Initialize Cluster
```bash
# Create Redis cluster
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house \
  --cluster create redis-node-1:7001 redis-node-2:7002 redis-node-3:7003 \
  redis-node-4:7004 redis-node-5:7005 \
  --cluster-replicas 0 --cluster-yes
```

## Access Methods

### Public Access Methods

**Non-SSL (Testing):**
```bash
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house --no-auth-warning -c
```

**SSL (Production):**
```bash
redis-cli -h 100.81.111.21 -p 6381 -a kumar_house --user kumar_house --tls --insecure -c
```

n**Security Note:** Port 6380 (Docker nginx) is internal-only for security.

### Connection Strings

**Non-SSL (Testing):**
```
redis://kumar_house:kumar_house@100.81.111.21:6382
```

**SSL (Production):**
```
rediss://kumar_house:kumar_house@100.81.111.21:6381
```

## Configuration Files

### Docker Compose
- `docker-compose-cluster.yml` - Redis cluster and Docker nginx
- `storage/nginx/nginx.conf` - Docker nginx configuration
- `storage/redis_cart_data/redis.conf` - Redis cluster configuration

### Main Nginx
- `/etc/nginx/nginx.conf` - SSL proxy configuration
- `/etc/ssl/certs/redis-public.crt` - SSL certificate
- `/etc/ssl/private/redis-private.key` - SSL private key

## Test Data

The cluster includes sample data for testing:

```bash
# Users (JSON)
GET user:1001  # John Doe
GET user:1002  # Jane Smith

# Products (Hash)
HGETALL product:2001  # Laptop details

# Orders (List)
LRANGE orders:queue 0 -1

# Categories (Set)
SMEMBERS categories

# Leaderboard (Sorted Set)
ZRANGE leaderboard 0 -1 WITHSCORES

# Counters
GET counter:visits
INCR counter:visits
```

## Monitoring

### Check Cluster Status
```bash
# Cluster nodes
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house cluster nodes

# Container health
docker ps

# Nginx status
sudo systemctl status nginx
```

### Logs
```bash
# Docker nginx logs
docker logs nginx-redis-proxy

# Redis logs
docker logs redis-node-1

# Main nginx logs
sudo tail -f /var/log/nginx/error.log
```

## Security Features

- **No Direct Access**: Redis nodes only accessible through proxies
- **Port Security**: Only ports 6381 (SSL) and 6382 (non-SSL) publicly exposed
- **SSL Encryption**: Production traffic encrypted
- **ACL Users**: Custom Redis user with restricted permissions
- **Command Restrictions**: Dangerous commands disabled
- **Network Isolation**: Docker network for internal communication

## Troubleshooting

### Connection Issues
```bash
# Test Redis nodes directly
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house ping

# Test Docker nginx
redis-cli -h 172.20.0.5 -p 6380 -a kumar_house --user kumar_house ping

# Check nginx connectivity
sudo netstat -tlnp | grep nginx
```

### Cluster Issues
```bash
# Reset cluster
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house cluster reset

# Recreate cluster
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house \
  --cluster create redis-node-1:7001 redis-node-2:7002 redis-node-3:7003 \
  redis-node-4:7004 redis-node-5:7005 \
  --cluster-replicas 0 --cluster-yes
```

## Performance Tuning

### Redis Configuration
- **Memory Policy**: `noeviction` (unlimited storage)
- **I/O Threads**: 4 threads for better performance
- **Persistence**: AOF + RDB for data safety
- **Clustering**: Optimized for high availability

### Nginx Configuration
- **Load Balancing**: `least_conn` algorithm
- **Timeouts**: Optimized for Redis protocol
- **Worker Processes**: Auto-scaled based on CPU cores

## Production Deployment

### SSL Certificates
Replace self-signed certificates with proper CA-signed certificates:
```bash
sudo cp your-certificate.crt /etc/ssl/certs/redis-public.crt
sudo cp your-private-key.key /etc/ssl/private/redis-private.key
sudo systemctl restart nginx
```

### Firewall Rules
```bash
# Allow only necessary ports
sudo ufw allow 6381/tcp  # SSL Redis
sudo ufw allow 6382/tcp  # Non-SSL Redis (optional)
```

### Auto-Start Services
```bash
# Enable services on boot
sudo systemctl enable nginx
sudo systemctl enable docker

# Docker containers auto-restart with "unless-stopped" policy
```

## Backup & Recovery

### Data Backup
```bash
# Backup Redis data
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house BGSAVE

# Copy backup files
docker cp redis-node-1:/data/dump.rdb ./backup/
```

### Configuration Backup
```bash
# Backup configurations
tar -czf redis-cluster-backup.tar.gz \
  docker-compose-cluster.yml \
  .env \
  storage/ \
  /etc/nginx/nginx.conf
```

n## Code Integration

n**Security Note:** Port 6380 (Docker nginx) is internal-only for security.

### Connection Strings

**Production (SSL):** rediss://kumar_house:kumar_house@100.81.111.21:6381
**Testing (Non-SSL):** redis://kumar_house:kumar_house@100.81.111.21:6382
**GUI Tools:** redis://kumar_house:kumar_house@100.81.111.21:6383

### Node.js


### Python


### Environment Variables


## Code Integration

n**Security Note:** Port 6380 (Docker nginx) is internal-only for security.

### Connection Strings

**Production (SSL):**
```
rediss://kumar_house:kumar_house@100.81.111.21:6381
```

**Testing (Non-SSL):**
```
redis://kumar_house:kumar_house@100.81.111.21:6382
```

**GUI Tools:**
```
redis://kumar_house:kumar_house@100.81.111.21:6383
```

### Node.js

```javascript
const Redis = require('ioredis');
const redis = new Redis('redis://kumar_house:kumar_house@100.81.111.21:6382');
```

### Python

```python
import redis
r = redis.Redis(host='100.81.111.21', port=6383, username='kumar_house', password='kumar_house')
```

### Environment Variables

```bash
export REDIS_URL="redis://kumar_house:kumar_house@100.81.111.21:6382"
```
## License

This project is licensed under the MIT License.

## Support

For issues and questions:
1. Check logs for error messages
2. Verify all containers are healthy
3. Test individual components
4. Review configuration files

---

**Redis Cluster Status**: ✅ Production Ready  
**SSL Support**: ✅ Enabled  
**High Availability**: ✅ 3-Node Cluster  
**Security**: ✅ Hardened Configuration

- **Web UI**: http://100.81.111.21:8080 (Proxy Flow)
- **SSL Redis**: rediss://kumar_house:kumar_house@100.81.111.21:6381  
- **Non-SSL Redis**: redis://kumar_house:kumar_house@100.81.111.21:6382
