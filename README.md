# Redis Cluster with SSL Proxy

A production-ready Redis cluster setup with secure SSL proxy and load balancing using Docker Compose and Nginx.

## Architecture

```
Client → Main Nginx (SSL/Non-SSL/Single) → Docker Nginx → Redis Cluster [3 Nodes]
```

**Flow:**
- **Port 6381**: SSL cluster endpoint (production)
- **Port 6382**: Non-SSL cluster endpoint (testing)
- **Port 6383**: Single node endpoint (GUI tools)
- **Internal**: Docker nginx (6380) → Redis nodes (7001, 7002, 7003)

## Features

- ✅ **3-Node Redis Cluster** with hash slot distribution
- ✅ **SSL Termination** with self-signed certificates
- ✅ **Load Balancing** across Redis nodes
- ✅ **GUI Tool Support** via single node endpoint
- ✅ **Security**: Internal services not exposed
- ✅ **High Availability** with auto-restart
- ✅ **Triple Access** modes (SSL + Non-SSL + Single Node)

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
  --cluster-replicas 0 --cluster-yes
```

## Access Methods

### SSL Cluster (Production)
```bash
redis-cli -h 100.81.111.21 -p 6381 -a kumar_house --user kumar_house --tls --insecure -c
```

### Non-SSL Cluster (Testing)
```bash
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house --no-auth-warning -c
```

### Single Node (GUI Tools)
```bash
redis-cli -h 100.81.111.21 -p 6383 -a kumar_house --user kumar_house --no-auth-warning
```

### Connection Strings

**SSL Cluster:**
```
rediss://kumar_house:kumar_house@100.81.111.21:6381
```

**Non-SSL Cluster:**
```
redis://kumar_house:kumar_house@100.81.111.21:6382
```

**Single Node (GUI):**
```
redis://kumar_house:kumar_house@100.81.111.21:6383
```

## GUI Tool Configuration

### VSCode Redis Extension
- **Host**: `100.81.111.21`
- **Port**: `6383`
- **Username**: `kumar_house`
- **Password**: `kumar_house`
- **TLS**: ❌ Disabled
- **Timeout**: `30`

### RedisInsight / Other GUI Tools
Use the same settings as VSCode extension above.

## Redis Commands & Information

### Cluster Information
```bash
# Cluster status and nodes
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster nodes
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster info
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster slots

# Individual node info
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info server
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info memory
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info replication
```

### Data Operations
```bash
# Scan data (cluster mode)
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c scan 0

# Count keys per node
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house dbsize
docker exec redis-node-2 redis-cli -p 7002 -a kumar_house --user kumar_house dbsize
docker exec redis-node-3 redis-cli -p 7003 -a kumar_house --user kumar_house dbsize

# Memory usage
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c info memory
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c memory usage user:1001
```

### Performance Monitoring
```bash
# Real-time monitoring
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c monitor

# Statistics
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c info stats
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c info commandstats

# Latency monitoring
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c latency latest
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c --latency
```

### Configuration
```bash
# View configuration
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c config get '*'
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c config get maxmemory*

# Client connections
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c client list
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c info clients
```

## Test Data

The cluster includes sample data for testing:

```bash
# Users (JSON)
GET user:1001  # John Doe
GET user:1002  # Jane Smith
GET user:1003  # Bob Wilson

# Products (Hash)
HGETALL product:2001  # Laptop - 99.99
HGETALL product:2002  # Phone - 99.99

# Orders (List)
LRANGE orders:queue 0 -1

# Categories (Set)
SMEMBERS categories

# Leaderboard (Sorted Set)
ZRANGE leaderboard 0 -1 WITHSCORES

# Configuration & Counters
GET config:timeout    # 30
GET counter:visits    # Auto-incrementing
GET session:abc123    # User session data

# Test commands
INCR counter:visits
ZINCRBY leaderboard 100 player1
LPOP orders:queue
HGET product:2001 price
```

## Monitoring

### Check Cluster Status
```bash
# Cluster health
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster nodes
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster info

# Container health
docker ps
docker stats --no-stream

# Nginx status
sudo systemctl status nginx
sudo netstat -tlnp | grep nginx
```

### Logs
```bash
# Docker nginx logs
docker logs nginx-redis-proxy --tail 20

# Redis logs
docker logs redis-node-1 --tail 20
docker logs redis-node-2 --tail 20
docker logs redis-node-3 --tail 20

# Main nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/redis-nossl-error.log
```

### Performance Metrics
```bash
# System resources
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info cpu
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info memory

# Network stats
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house info stats

# Slow queries
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house slowlog get 10
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

## Security Features

- **No Direct Access**: Redis nodes only accessible through proxies
- **SSL Encryption**: Production traffic encrypted
- **ACL Users**: Custom Redis user with restricted permissions
- **Command Restrictions**: Dangerous commands disabled (KEYS, FLUSHALL, etc.)
- **Network Isolation**: Docker network for internal communication
- **Port Isolation**: Different ports for different access levels

## Troubleshooting

### Connection Issues
```bash
# Test Redis nodes directly
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house ping
docker exec redis-node-2 redis-cli -p 7002 -a kumar_house --user kumar_house ping
docker exec redis-node-3 redis-cli -p 7003 -a kumar_house --user kumar_house ping

# Test nginx endpoints
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house ping  # Cluster
redis-cli -h 100.81.111.21 -p 6383 -a kumar_house --user kumar_house ping  # Single

# Check nginx connectivity
sudo netstat -tlnp | grep nginx
```

### Cluster Issues
```bash
# Check cluster state
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster nodes
redis-cli -h 100.81.111.21 -p 6382 -a kumar_house --user kumar_house -c cluster info

# Reset cluster (if needed)
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house cluster reset
docker exec redis-node-2 redis-cli -p 7002 -a kumar_house --user kumar_house cluster reset
docker exec redis-node-3 redis-cli -p 7003 -a kumar_house --user kumar_house cluster reset

# Recreate cluster
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house \
  --cluster create redis-node-1:7001 redis-node-2:7002 redis-node-3:7003 \
  --cluster-replicas 0 --cluster-yes
```

### GUI Connection Issues
```bash
# Test single node endpoint for GUI tools
redis-cli -h 100.81.111.21 -p 6383 -a kumar_house --user kumar_house ping

# Check if GUI tool supports clustering
# Use port 6383 for tools that don't support Redis cluster mode
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
sudo ufw allow 6383/tcp  # GUI Redis (optional)
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
# Backup Redis data from all nodes
docker exec redis-node-1 redis-cli -p 7001 -a kumar_house --user kumar_house BGSAVE
docker exec redis-node-2 redis-cli -p 7002 -a kumar_house --user kumar_house BGSAVE
docker exec redis-node-3 redis-cli -p 7003 -a kumar_house --user kumar_house BGSAVE

# Copy backup files
docker cp redis-node-1:/data/dump.rdb ./backup/node1-dump.rdb
docker cp redis-node-2:/data/dump.rdb ./backup/node2-dump.rdb
docker cp redis-node-3:/data/dump.rdb ./backup/node3-dump.rdb
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

## Port Summary

| Port | Purpose | Protocol | Access Level |
|------|---------|----------|--------------|
| 6381 | SSL Cluster | SSL/TLS | Production |
| 6382 | Non-SSL Cluster | TCP | Testing |
| 6383 | Single Node | TCP | GUI Tools |
| 6380 | Docker Nginx | TCP | Internal Only |
| 7001-7003 | Redis Nodes | TCP | Internal Only |

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
1. Check logs for error messages
2. Verify all containers are healthy
3. Test individual components
4. Review configuration files
5. Use appropriate port for your use case

---

**Redis Cluster Status**: ✅ Production Ready  
**SSL Support**: ✅ Enabled  
**GUI Support**: ✅ Enabled (Port 6383)  
**High Availability**: ✅ 3-Node Cluster  
**Security**: ✅ Hardened Configuration
