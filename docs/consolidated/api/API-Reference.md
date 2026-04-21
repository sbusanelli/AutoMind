# API Reference

## 🔐 Authentication

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your_secure_password_here"
}
```

**Response:**
```json
{
  "success": true,
  "token": "example_jwt_token_here",
  "refreshToken": "example_refresh_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "role": "admin"
  }
}
```

### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "refresh_token_here"
}
```

### Logout
```http
POST /api/auth/logout
Authorization: Bearer your_jwt_token_here
```

## 📋 Job Management

### Get All Jobs
```http
GET /api/jobs
Authorization: Bearer your_jwt_token_here
```

**Response:**
```json
{
  "jobs": [
    {
      "id": "job_id",
      "title": "Job Title",
      "description": "Job Description",
      "status": "pending|running|completed|failed",
      "priority": "low|medium|high",
      "createdAt": "2026-04-10T10:00:00Z",
      "updatedAt": "2026-04-10T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### Create Job
```http
POST /api/jobs
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "title": "New Job Title",
  "description": "Job Description",
  "priority": "medium",
  "schedule": "0 2 * * *",
  "config": {
    "timeout": 3600,
    "retryCount": 3
  }
}
```

### Get Specific Job
```http
GET /api/jobs/:id
Authorization: Bearer your_jwt_token_here
```

### Update Job
```http
PUT /api/jobs/:id
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "title": "Updated Job Title",
  "status": "running"
}
```

### Delete Job
```http
DELETE /api/jobs/:id
Authorization: Bearer your_jwt_token_here
```

## 🤖 AI Endpoints

### Optimize Job
```http
POST /api/ai/optimize
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "jobId": "job_id",
  "optimizeFor": ["performance", "cost", "time"],
  "constraints": {
    "maxCost": 100,
    "maxTime": 7200
  }
}
```

**Response:**
```json
{
  "optimization": {
    "recommendedSchedule": "0 3 * * *",
    "estimatedCost": 85.50,
    "estimatedTime": 5400,
    "confidence": 0.92,
    "suggestions": [
      "Consider running during off-peak hours",
      "Batch similar jobs together"
    ]
  }
}
```

### Analyze Performance
```http
POST /api/ai/analyze
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "timeRange": "7d",
  "metrics": ["success_rate", "execution_time", "cost"],
  "jobIds": ["job_id_1", "job_id_2"]
}
```

**Response:**
```json
{
  "analysis": {
    "overallHealth": "good",
    "successRate": 0.95,
    "avgExecutionTime": 2400,
    "totalCost": 456.78,
    "trends": {
      "performance": "improving",
      "cost": "stable",
      "efficiency": 0.88
    },
    "recommendations": [
      "Consider increasing resource allocation for job_type_x",
      "Optimize database queries in job_type_y"
    ]
  }
}
```

### Natural Language Interface
```http
POST /api/ai/chat
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "message": "Show me all failed jobs from yesterday",
  "context": {
    "timeRange": "1d",
    "status": "failed"
  }
}
```

**Response:**
```json
{
  "response": "I found 3 failed jobs from yesterday. Job #123 failed due to timeout, Job #456 failed due to memory limits, and Job #789 failed due to network connectivity. Would you like me to analyze the root causes or suggest optimizations?",
  "actions": [
    {
      "type": "analyze",
      "description": "Analyze root causes"
    },
    {
      "type": "optimize",
      "description": "Suggest optimizations"
    }
  ],
  "data": {
    "jobIds": [123, 456, 789],
    "failures": [
      {
        "jobId": 123,
        "reason": "timeout",
        "timestamp": "2026-04-09T15:30:00Z"
      }
    ]
  }
}
```

##  TurboQuant Verification

### Quick Status Check
```http
GET /api/turboquant/status
Authorization: Bearer your_jwt_token_here
```

**Response:**
```json
{
  "success": true,
  "timestamp": "2026-04-21T03:04:21.716Z",
  "quickTest": {
    "originalSize": 1000,
    "compressedSize": 167,
    "compressionRatio": "6.00x",
    "memorySavings": "83.3%",
    "accuracy": "96.8%",
    "processingTime": "45ms",
    "is6xAchieved": true
  }
}
```

### Full Verification Report
```http
POST /api/turboquant/verify
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "testCases": ["small", "large", "real-world", "edge-cases"],
  "bitWidth": 3
}
```

**Response:**
```json
{
  "success": true,
  "timestamp": "2026-04-21T03:05:51.322Z",
  "summary": {
    "totalTests": 6,
    "passedTests": 6,
    "passRate": "100%",
    "averageCompressionRatio": "6.00x",
    "averageMemorySavings": "83.3%",
    "averageAccuracy": "96.8%",
    "sixxComplianceRate": "100%",
    "is6xAchieved": true
  },
  "testResults": [
    {
      "name": "Small Vector Compression",
      "description": "Test compression of small vectors (1KB)",
      "passed": true,
      "compressionRatio": "6.00x",
      "accuracy": "97.2%",
      "memorySavings": "83.3%",
      "processingTime": "12ms"
    }
  ],
  "recommendations": [
    "Excellent compression performance achieved",
    "6x compression target met with high accuracy",
    "Processing time within acceptable limits"
  ]
}
```

### Implementation Details
```http
GET /api/turboquant/implementation
Authorization: Bearer your_jwt_token_here
```

**Response:**
```json
{
  "success": true,
  "implementation": {
    "type": "OPTIMIZED_GOOGLE_TURBOQUANT",
    "description": "Optimized implementation of Google's TurboQuant algorithm with mathematical accuracy",
    "features": [
      "Real random rotation matrices",
      "Johnson-Lindenstrauss transform",
      "Adaptive bit-width quantization",
      "Pre-computed matrix caching",
      "Ultra-fast quantization with lookup tables"
    ],
    "performance": {
      "targetCompressionRatio": "6.00x",
      "targetAccuracy": ">95%",
      "targetProcessingTime": "<100ms",
      "supportedBitWidths": [3, 4, 8]
    }
  }
}
```

### System Optimization
```http
POST /api/turboquant/optimize
Authorization: Bearer your_jwt_token_here
Content-Type: application/json

{
  "data": [0.1, 0.2, 0.3, 0.4, 0.5],
  "bitWidth": 3,
  "enableJLCorrection": true
}
```

**Response:**
```json
{
  "success": true,
  "optimization": {
    "originalSize": 20,
    "compressedSize": 4,
    "compressionRatio": "6.00x",
    "memoryReduction": "80.0%",
    "accuracy": "96.5%",
    "processingTime": "8ms",
    "metrics": {
      "compressionRatio": 6.0,
      "memoryReduction": 80.0,
      "accuracyRetention": 96.5,
      "processingSpeedup": 2.5
    }
  }
}
```

## 📊 Analytics

### Get Dashboard Data
```http
GET /api/analytics/dashboard
Authorization: Bearer your_jwt_token_here
```

**Response:**
```json
{
  "dashboard": {
    "summary": {
      "totalJobs": 1250,
      "activeJobs": 45,
      "successRate": 0.94,
      "avgExecutionTime": 1800,
      "totalCost": 2345.67
    },
    "charts": {
      "jobTrends": [
        {"date": "2026-04-09", "count": 45},
        {"date": "2026-04-10", "count": 52}
      ],
      "costBreakdown": {
        "compute": 0.65,
        "storage": 0.20,
        "network": 0.15
      }
    }
  }
}
```

### Get Performance Metrics
```http
GET /api/analytics/performance?timeRange=7d&granularity=hour
Authorization: Bearer your_jwt_token_here
```

## 🚨 Error Codes

### Authentication Errors
- `401`: Invalid or expired token
- `403`: Insufficient permissions
- `429`: Rate limit exceeded

### Job Management Errors
- `400`: Invalid job configuration
- `404`: Job not found
- `409`: Job conflict (duplicate schedule)

### AI Service Errors
- `502`: AI service unavailable
- `503`: AI service rate limit
- `422`: Invalid AI request format

### TurboQuant Errors
- `500`: TurboQuant engine initialization failed
- `400`: Invalid compression parameters
- `503`: TurboQuant service temporarily unavailable
- `422`: Unsupported data format for compression

## 🔒 Rate Limiting

| Endpoint | Limit | Window |
|-----------|--------|--------|
| Auth | 10 requests/min | 1 minute |
| Jobs | 100 requests/min | 1 minute |
| AI | 50 requests/min | 1 minute |
| TurboQuant | 30 requests/min | 1 minute |
| Analytics | 200 requests/min | 1 minute |

## 📝 Response Formats

### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {}
  }
}
```

---

**Last Updated**: 2026-04-21  
**API Version**: v1.1.0
