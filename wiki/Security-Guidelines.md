# Security Guidelines

## 🔐 Authentication & Authorization

### JWT Implementation
```javascript
// Secure JWT configuration
const jwtConfig = {
  secret: process.env.JWT_SECRET, // Use strong, random secret
  expiresIn: '15m',             // Short expiration
  issuer: 'flowops',
  audience: 'flowops-users'
};

// Token validation middleware
const authenticateToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Token required' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

### Password Security
```javascript
// Secure password hashing
const bcrypt = require('bcrypt');

const hashPassword = async (password) => {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
};

const verifyPassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

// Password strength requirements
const validatePassword = (password) => {
  const minLength = 12;
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumbers = /\d/.test(password);
  const hasSpecialChar = /[!@#$%^&*]/.test(password);
  
  return password.length >= minLength &&
         hasUpperCase &&
         hasLowerCase &&
         hasNumbers &&
         hasSpecialChar;
};
```

### Role-Based Access Control (RBAC)
```javascript
const roles = {
  admin: ['read', 'write', 'delete', 'manage_users'],
  operator: ['read', 'write'],
  viewer: ['read']
};

const checkPermission = (userRole, requiredPermission) => {
  return roles[userRole]?.includes(requiredPermission);
};

// Authorization middleware
const authorize = (requiredPermission) => {
  return (req, res, next) => {
    if (!checkPermission(req.user.role, requiredPermission)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};
```

## 🛡️ Input Validation & Sanitization

### Request Validation with Joi
```javascript
const Joi = require('joi');

const jobSchema = Joi.object({
  title: Joi.string().min(3).max(100).required(),
  description: Joi.string().min(10).max(1000).required(),
  priority: Joi.string().valid('low', 'medium', 'high').required(),
  schedule: Joi.string().pattern(/^(\d+\s+\d+\s+\*\s+\d+\s+\*)$/).required(),
  config: Joi.object({
    timeout: Joi.number().min(60).max(86400),
    retryCount: Joi.number().min(0).max(10)
  })
});

const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: error.details 
      });
    }
    next();
  };
};
```

### SQL Injection Prevention
```javascript
// Parameterized queries with pg
const { Pool } = require('pg');

const getJobs = async (filters = {}) => {
  const pool = new Pool();
  const client = await pool.connect();
  
  try {
    // Safe parameterized query
    const query = `
      SELECT * FROM jobs 
      WHERE status = $1 
      AND created_at >= $2 
      ORDER BY created_at DESC
      LIMIT $3
    `;
    
    const values = [
      filters.status || 'pending',
      filters.startDate || '1970-01-01',
      filters.limit || 20
    ];
    
    const result = await client.query(query, values);
    return result.rows;
  } finally {
    client.release();
  }
};
```

### XSS Protection
```javascript
// Content Security Policy headers
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
}));

// Input sanitization
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;');
};
```

## 🔒 Infrastructure Security

### Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

const createRateLimiter = (windowMs, max, message) => {
  return rateLimit({
    windowMs,
    max,
    message: { error: message },
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req, res) => {
      // Log rate limit violations
      console.warn(`Rate limit exceeded for IP: ${req.ip}`);
      res.status(429).json({ error: message });
    }
  });
};

// Apply different limits for different endpoints
app.use('/api/auth/', createRateLimiter(15 * 60 * 1000, 5, 'Too many authentication attempts'));
app.use('/api/jobs', createRateLimiter(15 * 60 * 1000, 100, 'Too many job requests'));
app.use('/api/ai/', createRateLimiter(15 * 60 * 1000, 50, 'Too many AI requests'));
```

### CORS Configuration
```javascript
const cors = require('cors');

const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      'https://flowops.com',
      'https://www.flowops.com',
      'https://app.flowops.com'
    ];
    
    if (!origin) return callback(null, true);
    if (allowedOrigins.indexOf(origin) !== -1) {
      return callback(new Error('Not allowed by CORS'));
    }
    return callback(null, true);
  },
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

### HTTPS Enforcement
```javascript
const https = require('https');
const fs = require('fs');

// SSL configuration
const sslOptions = {
  key: fs.readFileSync('/path/to/private.key'),
  cert: fs.readFileSync('/path/to/certificate.crt'),
  ca: fs.readFileSync('/path/to/ca_bundle.crt'),
  minVersion: 'TLSv1.2',
  ciphers: [
    'ECDHE-ECDSA-AES256-GCM-SHA384',
    'ECDHE-RSA-AES256-GCM-SHA384',
    'ECDHE-RSA-AES128-GCM-SHA256'
  ].join(':')
};

// HTTPS server
https.createServer(sslOptions, app).listen(443);
```

## 🔍 Security Monitoring

### Security Event Logging
```javascript
const winston = require('winston');

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'security.log' }),
    new winston.transports.Console()
  ]
});

const logSecurityEvent = (event, details) => {
  securityLogger.info({
    type: 'security_event',
    event,
    timestamp: new Date().toISOString(),
    ip: details.ip,
    userAgent: details.userAgent,
    userId: details.userId,
    severity: details.severity
  });
};
```

### Authentication Monitoring
```javascript
// Track failed authentication attempts
const failedAttempts = new Map();

const trackFailedLogin = (email, ip) => {
  const key = `${email}:${ip}`;
  const attempts = (failedAttempts.get(key) || 0) + 1;
  failedAttempts.set(key, attempts);
  
  if (attempts >= 5) {
    logSecurityEvent('brute_force_detected', {
      email,
      ip,
      attempts,
      severity: 'high'
    });
    
    // Block IP temporarily
    blockIP(ip, 15 * 60 * 1000); // 15 minutes
  }
};
```

### Intrusion Detection
```javascript
// Detect suspicious patterns
const detectSuspiciousActivity = (req, res, next) => {
  const suspiciousPatterns = [
    /\.\./,                    // Path traversal
    /<script/i,               // XSS attempts
    /union.*select/i,          // SQL injection
    /cmd\.exe/i,              // Command injection
    /\$\{.*\}/                // Template injection
  ];
  
  const url = req.url;
  const userAgent = req.headers['user-agent'];
  
  for (const pattern of suspiciousPatterns) {
    if (pattern.test(url)) {
      logSecurityEvent('suspicious_request', {
        url,
        userAgent,
        ip: req.ip,
        pattern: pattern.toString(),
        severity: 'high'
      });
      
      return res.status(400).json({ error: 'Invalid request' });
    }
  }
  
  next();
};
```

## 🔧 Security Best Practices

### Environment Variables
```bash
# Use environment-specific configurations
export NODE_ENV=production
export JWT_SECRET=$(openssl rand -hex 32)  # Generate strong secret
export DATABASE_URL=postgresql://user:password@localhost:5432/flowops

# Never commit secrets to version control
echo ".env" >> .gitignore
echo "secrets/" >> .gitignore
```

### Database Security
```sql
-- Create dedicated database user
CREATE USER flowops_app WITH PASSWORD 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON jobs TO flowops_app;
GRANT SELECT ON job_logs TO flowops_app;

-- Enable row-level security
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_jobs_policy ON jobs
  FOR ALL TO flowops_app
  USING (user_id = current_user_id());
```

### API Security Headers
```javascript
// Security middleware
app.use((req, res, next) => {
  // Security headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  
  // Remove server information
  res.removeHeader('X-Powered-By');
  res.removeHeader('Server');
  
  next();
});
```

## 🚨 Incident Response

### Security Incident Checklist
1. **Containment**
   - [ ] Isolate affected systems
   - [ ] Block suspicious IPs
   - [ ] Disable compromised accounts
   
2. **Investigation**
   - [ ] Collect logs and evidence
   - [ ] Analyze attack vectors
   - [ ] Determine data impact
   
3. **Recovery**
   - [ ] Patch vulnerabilities
   - [ ] Reset credentials
   - [ ] Restore from clean backups
   
4. **Prevention**
   - [ ] Update security controls
   - [ ] Review monitoring rules
   - [ ] Conduct security training

### Incident Reporting
```javascript
const reportSecurityIncident = async (incident) => {
  const incidentReport = {
    id: generateUUID(),
    timestamp: new Date().toISOString(),
    severity: incident.severity, // low, medium, high, critical
    type: incident.type,        // data_breach, unauthorized_access, malware
    description: incident.description,
    affectedSystems: incident.systems,
    actions: incident.actions,
    status: 'investigating'
  };
  
  // Store incident
  await db.collection('incidents').insertOne(incidentReport);
  
  // Notify security team
  await notifySecurityTeam(incidentReport);
};
```

## 📋 Security Checklist

### Development Security
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention implemented
- [ ] XSS protection enabled
- [ ] Authentication and authorization
- [ ] Rate limiting configured
- [ ] HTTPS enforced
- [ ] Security headers set
- [ ] Error handling doesn't leak information
- [ ] Dependencies security scanned

### Production Security
- [ ] Environment variables secured
- [ ] Database access restricted
- [ ] Firewall rules configured
- [ ] SSL/TLS certificates valid
- [ ] Monitoring and alerting active
- [ ] Backup procedures tested
- [ ] Incident response plan ready
- [ ] Regular security audits scheduled

---

**Last Updated**: 2026-04-10  
**Version**: 1.0.0
