# Production Hardening & Enterprise Readiness Guide

This document outlines improvements and configurations required to move from MVP to production-grade system.

---

## 🔒 Security Hardening

### 1. Input Validation Enhancement

**Current State:** Basic field presence checks

**Production Enhancement:**
```javascript
// backend/middleware/validation.js
const validateVIN = (vin) => {
  // VIN format: 17 characters, alphanumeric
  // Pattern: ^[A-HJ-NPR-Z0-9]{17}$
  const vinRegex = /^[A-HJ-NPR-Z0-9]{17}$/;
  return vinRegex.test(vin);
};

const validateDealerId = (dealerId) => {
  // Dealer format: DEALER-[NAME]-[CODE]
  const dealerRegex = /^DEALER-[A-Z0-9\-]+$/;
  return dealerRegex.test(dealerId);
};

const validateLocation = (location) => {
  // Location: alphabetic + hyphens, max 100 chars
  const locRegex = /^[A-Za-z0-9\-\s]{1,100}$/;
  return locRegex.test(location);
};

module.exports = {
  validateVIN,
  validateDealerId,
  validateLocation
};
```

### 2. API Authentication & Authorization

**Add JWT token-based authentication:**

```javascript
// backend/middleware/auth.js
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

const authorizeRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
};

// Usage in routes:
// app.post('/vehicle/create', authenticateToken, authorizeRole(['OEM']), createVehicle);
// app.post('/vehicle/transfer', authenticateToken, authorizeRole(['DEALER']), transferOwnership);
```

### 3. Rate Limiting

**Prevent DDoS and brute force attacks:**

```javascript
// backend/middleware/rateLimiter.js
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later'
});

const updateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // strict limit on write operations
  skip: (req) => req.method === 'GET'
});

module.exports = { limiter, updateLimiter };
```

### 4. CORS Configuration

**Restrict cross-origin requests:**

```javascript
// backend/app.js
const cors = require('cors');

const corsOptions = {
  origin: [
    'https://oem-portal.example.com',
    'https://logistics-app.example.com',
    'https://dealer-portal.example.com'
  ],
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

### 5. HTTPS/TLS Configuration

```yaml
# docker-compose.prod.yml - Use TLS
environment:
  FABRIC_ENABLED_TLS: 'true'
  FABRIC_TLS_CERT_PATH: /etc/hyperledger/fabric/tls/server.crt
  FABRIC_TLS_KEY_PATH: /etc/hyperledger/fabric/tls/server.key
```

### 6. Secrets Management

**Never commit secrets to git:**

```bash
# .env.production (NOT committed)
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key-change-this
DB_PASSWORD=secure_database_password
FABRIC_MSP_PASSWORD=msp_identity_password

# Use AWS Secrets Manager or HashiCorp Vault:
# 1. Store secrets in external vault
# 2. Load at runtime: 
#    const secret = await AWS.SecretsManager.getSecretValue()
```

---

## 📊 Logging & Monitoring

### 1. Structured Logging

```javascript
// backend/logger.js
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ 
      filename: 'logs/error.log', 
      level: 'error' 
    }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

module.exports = logger;
```

### 2. Transaction Audit Logging

```javascript
// Log every blockchain transaction
const logTransaction = async (transactionId, action, vin, result, timestamp) => {
  logger.info({
    type: 'BLOCKCHAIN_TRANSACTION',
    transactionId,
    action,
    vin,
    status: result.status,
    timestamp,
    actor: result.actor,
    signature: result.signature
  });
};
```

### 3. Performance Monitoring

```javascript
// Middleware to track response times
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (duration > 5000) { // Log slow requests
      logger.warn(`Slow request: ${req.method} ${req.path} took ${duration}ms`);
    }
  });
  
  next();
});
```

### 4. Health Checks

```javascript
// backend/routes/health.js
app.get('/health', async (req, res) => {
  try {
    // Check API health
    const apiHealth = { status: 'ok' };
    
    // Check blockchain connectivity
    const fabricHealth = await checkFabricConnection();
    
    // Check database (if using)
    const dbHealth = await checkDatabaseConnection();
    
    const status = [apiHealth, fabricHealth, dbHealth].every(h => h.status === 'ok') 
      ? 'healthy' 
      : 'degraded';
    
    return res.json({
      status,
      timestamp: new Date(),
      services: { api: apiHealth, fabric: fabricHealth, db: dbHealth }
    });
  } catch (error) {
    return res.status(503).json({ status: 'unhealthy', error: error.message });
  }
});
```

---

## 🔄 Resilience & Retry Logic

### 1. Fabric Transaction Retry

```javascript
// backend/services/fabricService.js
async function submitTransactionWithRetry(
  chaincodeName, 
  functionName, 
  args,
  maxRetries = 3
) {
  let lastError;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const contract = await getGatewayContract(chaincodeName);
      return await contract.submitTransaction(functionName, ...args);
    } catch (error) {
      lastError = error;
      logger.warn(`Transaction attempt ${attempt} failed:`, error.message);
      
      if (attempt < maxRetries) {
        // Exponential backoff: 1s, 2s, 4s
        const waitTime = Math.pow(2, attempt - 1) * 1000;
        await new Promise(resolve => setTimeout(resolve, waitTime));
      }
    }
  }
  
  throw new Error(`Transaction failed after ${maxRetries} attempts: ${lastError.message}`);
}
```

### 2. Circuit Breaker Pattern

```javascript
// Prevent cascading failures
class CircuitBreaker {
  constructor(threshold = 5, resetTimeout = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.resetTimeout = resetTimeout;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
  }

  async execute(fn) {
    if (this.state === 'OPEN') {
      throw new Error('Circuit breaker is OPEN');
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      setTimeout(() => {
        this.state = 'HALF_OPEN';
        this.failureCount = 0;
      }, this.resetTimeout);
    }
  }
}
```

---

## 💾 Data Management & Backup

### 1. Database Backup Strategy

```bash
#!/bin/bash
# backup-ledger.sh - Regular blockchain state export

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Export current ledger state to JSON
curl -X GET http://localhost:3000/admin/export-ledger > \
  "$BACKUP_DIR/ledger_$TIMESTAMP.json"

# Compress and upload to S3
gzip "$BACKUP_DIR/ledger_$TIMESTAMP.json"
aws s3 cp "$BACKUP_DIR/ledger_$TIMESTAMP.json.gz" \
  s3://my-backups/ledger/
```

### 2. Disaster Recovery

```yaml
# Docker Compose with persistent volumes
volumes:
  fabric_ledger_data:
    driver: local
  fabric_wallet_data:
    driver: local
  
services:
  peer0:
    volumes:
      - fabric_ledger_data:/var/hyperledger/fabric/data
```

---

## 📈 Scalability Improvements

### 1. Load Balancing

```yaml
# docker-compose.prod.yml
services:
  nginx:
    image: nginx:alpine
    container_name: api-loadbalancer
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs/:/etc/nginx/certs/:ro
    depends_on:
      - backend1
      - backend2
      - backend3

  backend1:
    # ... service definition
    environment:
      INSTANCE_ID: backend-1
  
  backend2:
    # ... service definition
    environment:
      INSTANCE_ID: backend-2
```

### 2. Database Query Optimization

```javascript
// Use composite keys for efficient queries
async function getVehiclesByDealer(dealerId) {
  const dealer_vehicles_key = Fabric.compositeKey(
    'dealerVehicles',
    [dealerId]
  );
  
  const resultsIterator = await context.stub.getStateByPartialCompositeKey(
    dealer_vehicles_key.objectType,
    dealer_vehicles_key.attributes
  );
  
  // Returns all vehicles assigned to this dealer efficiently
}
```

---

## 🧪 Testing & Validation

### 1. Unit Tests (Chaincode)

```javascript
// chaincode/vehicle-lifecycle/__tests__/vehicleContract.test.js
const { Context, ClientIdentity } = require('fabric-contract-api');

describe('VehicleContract', () => {
  let ctx;
  let contract;

  beforeEach(() => {
    ctx = new Context();
    contract = new VehicleContract();
  });

  it('should create vehicle in CREATED state', async () => {
    await contract.createVehicle(ctx, 'VIN123', 'Model-S', 'FACTORY1');
    
    const vehicle = JSON.parse(
      await ctx.stub.getState('VIN123')
    );
    
    expect(vehicle.status).toBe('CREATED');
    expect(vehicle.factoryId).toBe('FACTORY1');
  });

  it('should prevent invalid state transitions', async () => {
    // Create vehicle
    await contract.createVehicle(ctx, 'VIN456', 'Model-3', 'FACTORY2');
    
    // Try to transfer before assigning dealer (should fail)
    expect(async () => {
      await contract.transferOwnership(ctx, 'VIN456', 'CUSTOMER1');
    }).rejects.toThrow();
  });
});
```

### 2. Integration Tests (API)

```javascript
// backend/__tests__/api.integration.test.js
const request = require('supertest');
const app = require('../app');

describe('Vehicle Lifecycle API', () => {
  it('should complete full lifecycle', async () => {
    // Create vehicle
    const createRes = await request(app)
      .post('/vehicle/create')
      .send({ vin: 'TEST123', model: 'Model-X', factoryId: 'FAC1' })
      .expect(201);

    expect(createRes.body.status).toBe('CREATED');

    // Update shipment
    const shipRes = await request(app)
      .post('/vehicle/shipment')
      .send({ vin: 'TEST123', location: 'Port1', status: 'TRANSIT' })
      .expect(200);

    expect(shipRes.body.status).toBe('IN_TRANSIT');

    // ... continue through complete lifecycle
  });
});
```

---

## 🔐 Role-Based Access Control (RBAC)

```javascript
// backend/middleware/rbac.js
const roles = {
  OEM: ['CREATE_VEHICLE'],
  LOGISTICS: ['UPDATE_SHIPMENT'],
  DEALER: ['ASSIGN_DEALER', 'TRANSFER_OWNERSHIP'],
  CUSTOMER: ['VIEW_VEHICLE'],
  ADMIN: ['*'] // All permissions
};

const checkPermission = (requiredPermission) => {
  return (req, res, next) => {
    const userRole = req.user.role;
    const userPermissions = roles[userRole] || [];
    
    if (!userPermissions.includes(requiredPermission) && 
        !userPermissions.includes('*')) {
      return res.status(403).json({ 
        error: `Role ${userRole} not authorized for ${requiredPermission}` 
      });
    }
    
    next();
  };
};

// Usage:
// POST /vehicle/create - OEM only
app.post(
  '/vehicle/create',
  authenticateToken,
  checkPermission('CREATE_VEHICLE'),
  createVehicle
);
```

---

## 🚨 Monitoring & Alerting

### 1. Prometheus Metrics

```javascript
// backend/metrics.js
const prometheus = require('prom-client');

const transactionCounter = new prometheus.Counter({
  name: 'blockchain_transactions_total',
  help: 'Total blockchain transactions',
  labelNames: ['function', 'status']
});

const transactionDuration = new prometheus.Histogram({
  name: 'blockchain_transaction_duration_seconds',
  help: 'Blockchain transaction duration',
  labelNames: ['function'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

module.exports = { transactionCounter, transactionDuration };
```

### 2. Alert Rules (Alert Manager)

```yaml
# prometheus/alert-rules.yml
groups:
  - name: blockchain_alerts
    rules:
      - alert: HighTransactionFailureRate
        expr: rate(blockchain_transactions_total{status="failed"}[5m]) > 0.05
        annotations:
          summary: "High transaction failure rate detected"

      - alert: SlowTransactions
        expr: histogram_quantile(0.95, blockchain_transaction_duration_seconds) > 10
        annotations:
          summary: "95th percentile transaction time exceeds 10 seconds"
```

---

## ✅ Pre-Production Checklist

- [ ] All inputs validated against regex patterns
- [ ] JWT authentication implemented on all endpoints
- [ ] Rate limiting configured
- [ ] CORS properly restricted
- [ ] HTTPS/TLS enabled
- [ ] Secrets in external vault (not git)
- [ ] Structured logging with timestamps
- [ ] Health check endpoint implemented
- [ ] Retry logic with exponential backoff
- [ ] Circuit breaker pattern implemented
- [ ] Backup strategy defined
- [ ] Load balancing configured
- [ ] Unit tests with >80% coverage
- [ ] Integration tests for full flows
- [ ] RBAC implemented
- [ ] Monitoring and alerting setup
- [ ] Documentation for operations
- [ ] Disaster recovery plan documented

---

## 📋 Required Dependencies

```json
{
  "joi": "^17.9.0",
  "jsonwebtoken": "^9.0.0",
  "express-rate-limit": "^6.7.0",
  "cors": "^2.8.5",
  "helmet": "^7.0.0",
  "winston": "^3.8.0",
  "prom-client": "^14.2.0"
}
```

Install with:
```bash
cd backend
npm install joi jsonwebtoken express-rate-limit cors helmet winston prom-client
```

