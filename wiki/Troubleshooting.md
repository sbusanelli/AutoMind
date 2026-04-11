# Troubleshooting Guide

## 🚨 Common Issues

### Installation Problems

#### Node.js Version Incompatibility
**Issue**: `Node.js version X is not supported`
```bash
# Check current Node.js version
node --version

# Install required version (Node.js 20+)
nvm install 20
nvm use 20
```

#### Database Connection Errors
**Issue**: `ECONNREFUSED` connection refused
```bash
# Check PostgreSQL status
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart database
docker-compose restart postgres
```

#### Redis Connection Issues
**Issue**: `Redis connection timeout`
```bash
# Check Redis status
redis-cli ping

# Check Redis configuration
docker-compose exec redis redis-cli CONFIG GET timeout

# Restart Redis
docker-compose restart redis
```

### Application Errors

#### JWT Token Issues
**Issue**: `Invalid or expired token`
```bash
# Clear local storage
localStorage.clear()
sessionStorage.clear()

# Request new token
POST /api/auth/login

# Check token expiration
console.log(JSON.parse(atob(token.split('.')[1])).exp)
```

#### API Rate Limiting
**Issue**: `429 Too Many Requests`
```bash
# Check rate limit headers
curl -I https://api.flowops.com/jobs

# Implement exponential backoff
const delay = Math.min(1000 * Math.pow(2, attempt), 30000);
setTimeout(() => retryRequest(), delay);
```

#### Socket.IO Connection Issues
**Issue**: WebSocket connection failed
```javascript
// Check connection status
socket.on('connect', () => console.log('Connected'));
socket.on('disconnect', () => console.log('Disconnected'));

// Reconnection logic
socket.on('disconnect', () => {
  setTimeout(() => socket.connect(), 5000);
});
```

### Performance Issues

#### Slow Database Queries
**Issue**: Query taking > 5 seconds
```sql
-- Add indexes for slow queries
CREATE INDEX idx_jobs_status_created_at ON jobs(status, created_at);
CREATE INDEX idx_jobs_priority_created_at ON jobs(priority, created_at);

-- Use EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM jobs WHERE status = 'pending';
```

#### Memory Leaks
**Issue**: Memory usage continuously increasing
```bash
# Monitor Node.js memory
node --inspect app.js

# Check for memory leaks
node --inspect --trace-warnings app.js

# Use heap snapshot
const heapdump = require('heapdump');
heapdump.writeSnapshot();
```

#### High CPU Usage
**Issue**: CPU usage > 80%
```bash
# Profile Node.js application
node --prof app.js

# Analyze profile
node --prof-process isolate-*.log > processed.txt

# Use clinic.js
npm install -g clinic
clinic doctor -- node app.js
```

### Deployment Issues

#### Docker Container Fails to Start
**Issue**: Container exits immediately
```bash
# Check container logs
docker-compose logs [service-name]

# Check container status
docker-compose ps

# Debug container interactively
docker-compose run --rm [service-name] sh
```

#### Kubernetes Pod Crashes
**Issue**: Pod in CrashLoopBackOff
```bash
# Check pod status
kubectl get pods -n flowops-prod

# Check pod logs
kubectl logs [pod-name] -n flowops-prod

# Describe pod for errors
kubectl describe pod [pod-name] -n flowops-prod

# Check resource limits
kubectl describe pod [pod-name] -n flowops-prod | grep -A 10 Limits:
```

#### SSL/TLS Certificate Issues
**Issue**: Certificate not trusted
```bash
# Check certificate validity
openssl s_client -connect api.flowops.com:443 -servername api.flowops.com

# Check certificate chain
curl -I https://api.flowops.com

# Renew Let's Encrypt certificate
kubectl cert-manager renew --namespace flowops-prod
```

### AI Service Issues

#### OpenAI API Errors
**Issue**: `Invalid API key` or rate limit
```bash
# Test API key
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/models

# Check usage limits
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     https://api.openai.com/v1/usage

# Implement retry logic
const retry = async (fn, attempts = 3) => {
  for (let i = 0; i < attempts; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === attempts - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, i)));
    }
  }
};
```

#### AI Model Timeout
**Issue**: AI responses taking too long
```javascript
// Add timeout to AI requests
const controller = new AbortController();
setTimeout(() => controller.abort(), 30000);

const response = await fetch('/api/ai/optimize', {
  method: 'POST',
  signal: controller.signal,
  // ... other options
});
```

## 🔧 Debugging Tools

### Application Debugging
```bash
# Enable debug mode
export DEBUG=flowops:*
export NODE_ENV=development

# Run with debugger
node --inspect-brk src/index.js

# Use VS Code debugger
# Launch with "Debug: Node.js" configuration
```

### Database Debugging
```sql
-- Enable query logging
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000;

-- Monitor active connections
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

### Network Debugging
```bash
# Check port availability
netstat -tulpn | grep :3000

# Test API endpoints
curl -v http://localhost:3000/health

# Monitor network traffic
tcpdump -i any port 3000
```

## 📊 Performance Monitoring

### Application Metrics
```javascript
// Add performance monitoring
const perf = require('perf_hooks');

const obs = new perf.PerformanceObserver((list) => {
  list.forEach((entry) => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
});

obs.observe({ entryTypes: ['measure'] });
```

### Database Performance
```sql
-- Monitor query performance
SELECT 
  schemaname,
  tablename,
  seq_scan,
  idx_scan,
  n_tup_ins,
  n_tup_upd,
  n_tup_del
FROM pg_stat_user_tables 
ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC;
```

### System Resources
```bash
# Monitor system resources
htop                          # CPU and memory
iotop                          # Disk I/O
nethogs                         # Network usage
df -h                           # Disk space
free -h                          # Memory usage
```

## 🚨 Emergency Procedures

### Database Recovery
```bash
# Emergency database restart
docker-compose restart postgres

# Check database consistency
docker-compose exec postgres pg_isready -U postgres

# Restore from backup if needed
docker-compose exec postgres psql -U postgres -d flowops < backup.sql
```

### Application Recovery
```bash
# Force restart application
docker-compose restart backend
docker-compose restart frontend

# Clear application cache
docker-compose exec backend npm run cache:clear

# Reset to last known good state
git reset --hard HEAD~1
docker-compose up -d --force-recreate
```

### Full System Recovery
```bash
# Complete system restart
docker-compose down
docker system prune -f
docker-compose up -d

# Verify all services
docker-compose ps
curl http://localhost:3000/health
```

## 📞 Getting Help

### Log Collection
```bash
# Collect application logs
docker-compose logs --tail=1000 backend > backend.log
docker-compose logs --tail=1000 frontend > frontend.log
docker-compose logs --tail=1000 postgres > postgres.log

# Collect system logs
journalctl --since "1 hour ago" > system.log
dmesg > kernel.log
```

### Support Information
When creating support requests, include:
- **Environment**: Development/Staging/Production
- **Error Logs**: Complete error messages and stack traces
- **Steps to Reproduce**: Detailed reproduction steps
- **System Information**: OS, Node.js version, Docker version
- **Configuration**: Environment variables and configuration files

### Contact Channels
- **GitHub Issues**: [Create new issue](https://github.com/sbusanelli/FlowOps/issues)
- **Documentation**: [Wiki](https://github.com/sbusanelli/FlowOps/wiki)
- **API Reference**: [API Docs](https://github.com/sbusanelli/FlowOps/wiki/API-Reference)

---

**Last Updated**: 2026-04-10  
**Version**: 1.0.0
