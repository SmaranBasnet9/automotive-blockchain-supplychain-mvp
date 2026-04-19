# Deployment Guide: Local, Docker, Cloud

Full deployment instructions for all environments.

---

## 🚀 Quick Start (Local Development)

### Prerequisites Check
```bash
# Verify Node.js installation
node --version  # Should be v16+
npm --version   # Should be v8+

# Verify Docker installation
docker --version
docker-compose --version

# Verify Hyperledger Fabric binaries (if using local Fabric)
fabric-ca-server --version
orderer version
peer version
```

### Step 1: Clone & Install
```bash
git clone https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp.git
cd automotive-blockchain-supplychain-mvp

# Install dependencies
npm install
cd backend && npm install
cd ../chaincode/vehicle-lifecycle && npm install
cd ../../
```

### Step 2: Create Environment File
```bash
cat > backend/.env << 'EOF'
# Application
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# Fabric Configuration
FABRIC_CHANNEL=vehicle-channel
FABRIC_CHAINCODE=vehicle-lifecycle
FABRIC_MSP_ID=Org1MSP
FABRIC_PEER=peer0.org1.example.com:7051
FABRIC_PEER_ALIAS=peer0.org1.example.com
FABRIC_USER=appUser

# Paths (relative to backend directory)
WALLET_PATH=./wallet
CONNECTION_PROFILE=../blockchain-network/connection-org1.json
CRYPTO_CONFIG_PATH=../blockchain-network/crypto-config
EOF
```

### Step 3: Start Blockchain Network
```bash
cd blockchain-network
docker-compose up -d

# Wait for network initialization (30-60 seconds)
sleep 30

# Verify all containers running
docker-compose ps
```

### Step 4: Setup Wallet Identity
```bash
cd ../backend
npm run setup-wallet
```

Expected output:
```
✓ Wallet created at ./wallet
✓ Identity 'appUser' registered
✓ Ready for Fabric Gateway connection
```

### Step 5: Start Backend API
```bash
npm start
```

Expected output:
```
✓ Express server listening on port 3000
✓ Fabric Gateway connection ready
✓ Vehicle API endpoints registered
```

### Step 6: Test the API
```bash
# In a new terminal
curl -X POST http://localhost:3000/vehicle/create \
  -H "Content-Type: application/json" \
  -d '{"vin": "TEST-001", "model": "Tesla-Model-S", "factoryId": "FAC-001"}'
```

Expected response:
```json
{
  "transactionId": "uuid-...",
  "status": "CREATED",
  "vin": "TEST-001",
  "model": "Tesla-Model-S"
}
```

---

## 🐳 Docker Deployment

### Purpose
Containerize the complete application stack for consistent environments.

### Prerequisites
- Docker ≥ 20.10
- Docker Compose ≥ 1.29

### Architecture
```
┌─────────────────────────────────────────┐
│     Docker Compose Network              │
├─────────────────────────────────────────┤
│  Backend Service  (Node.js)   :3000     │
│  Hyperledger CA   (fabric-ca)  :7054    │
│  Orderer          (orderer)    :7050    │
│  Peer0            (peer)       :7051    │
│  CLI              (tools)      (interactive)
│  PostgreSQL       (database)   :5432    │
└─────────────────────────────────────────┘
```

### Build Backend Image
```bash
# Create Dockerfile for backend
cat > docker/Dockerfile.backend << 'EOF'
FROM node:16-alpine

WORKDIR /app

# Copy backend code
COPY backend/package*.json ./backend/
COPY backend/src ./backend/src
COPY backend/routes ./backend/routes
COPY backend/services ./backend/services

# Copy blockchain network config
COPY blockchain-network ./blockchain-network

# Install dependencies
RUN cd backend && npm install --production

WORKDIR /app/backend

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

EXPOSE 3000

CMD ["npm", "start"]
EOF

# Build image
docker build -f docker/Dockerfile.backend -t autoblockchain-backend:1.0 .

# Verify build
docker images autoblockchain-backend
```

### Start Complete Stack
```bash
cd docker

# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Follow logs
docker-compose -f docker-compose.prod.yml logs -f

# Check service health
docker-compose -f docker-compose.prod.yml ps

# Stop all services
docker-compose -f docker-compose.prod.yml down

# Stop and remove volumes
docker-compose -f docker-compose.prod.yml down -v
```

### Verify Deployment
```bash
# Check backend health
curl http://localhost:3000/health

# Check database connectivity
docker-compose -f docker-compose.prod.yml exec postgres \
  psql -U blockchain_user -d vehicle_ledger -c "SELECT version();"

# View logs
docker-compose -f docker-compose.prod.yml logs backend | tail -50
```

---

## ☁️ AWS Deployment (ECS + RDS + Fabric)

### Architecture
```
AWS Account
├── VPC
│   ├── ECS Cluster
│   │   ├── Backend Task (multi-instance)
│   │   └── Load Balancer (ALB)
│   └── RDS PostgreSQL
├── S3 (backups)
├── CloudWatch (logs & monitoring)
└── Route53 (DNS)
```

### prerequisites
- AWS Account with appropriate permissions
- AWS CLI v2 configured
- ECR (Elastic Container Registry) access

### Step 1: Push Docker Image to ECR
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag autoblockchain-backend:1.0 \
  123456789.dkr.ecr.us-east-1.amazonaws.com/autoblockchain-backend:1.0

# Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/autoblockchain-backend:1.0
```

### Step 2: Create RDS PostgreSQL Instance
```bash
aws rds create-db-instance \
  --db-instance-identifier autoblockchain-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.2 \
  --master-username blockchain_user \
  --master-user-password $DB_PASSWORD \
  --allocated-storage 20 \
  --storage-type gp3 \
  --vpc-security-group-ids sg-xxxxxxxx \
  --publicly-accessible false \
  --backup-retention-period 7
```

### Step 3: Create ECS Task Definition
```json
{
  "family": "autoblockchain-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/autoblockchain-backend:1.0",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "FABRIC_Channel",
          "value": "vehicle-channel"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:db-password"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/autoblockchain",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

### Step 4: Create ECS Service
```bash
aws ecs create-service \
  --cluster autoblockchain \
  --service-name autoblockchain-backend \
  --task-definition autoblockchain-backend:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-xxxxx,subnet-yyyyy],
    securityGroups=[sg-zzzzz],
    assignPublicIp=DISABLED
  }" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...,containerName=backend,containerPort=3000"
```

### Step 5: Setup Application Load Balancer
```bash
aws elbv2 create-load-balancer \
  --name autoblockchain-alb \
  --subnets subnet-xxxxx subnet-yyyyy \
  --security-groups sg-zzzzz \
  --scheme internet-facing \
  --type application
```

### Step 6: Configure CloudWatch Monitoring
```bash
# Create log group
aws logs create-log-group --log-group-name /ecs/autoblockchain

# Create CloudWatch dashboard
aws cloudwatch put-dashboard \
  --dashboard-name autoblockchain-metrics \
  --dashboard-body file://dashboard-config.json
```

### Verification
```bash
# Get service details
aws ecs describe-services \
  --cluster autoblockchain \
  --services autoblockchain-backend

# Get task details
aws ecs list-tasks --cluster autoblockchain
aws ecs describe-tasks \
  --cluster autoblockchain \
  --tasks <task-arn>

# View logs
aws logs tail /ecs/autoblockchain --follow
```

---

## 🔵 Azure Deployment (AKS + Azure Database)

### Architecture
```
Azure Subscription
├── AKS Cluster
│   ├── Backend Deployment (3 replicas)
│   └── Ingress Controller
├── Azure Database for PostgreSQL
├── Azure Container Registry
└── Azure Monitor
```

### Step 1: Create AKS Cluster
```bash
# Create resource group
az group create \
  --name autoblockchain-rg \
  --location eastus

# Create AKS cluster
az aks create \
  --resource-group autoblockchain-rg \
  --name autoblockchain-aks \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity

# Get credentials
az aks get-credentials \
  --resource-group autoblockchain-rg \
  --name autoblockchain-aks
```

### Step 2: Create Azure Container Registry
```bash
az acr create \
  --resource-group autoblockchain-rg \
  --name autoblockchaincr \
  --sku Basic

# Push image
az acr build \
  --registry autoblockchaincr \
  --image autoblockchain-backend:1.0 \
  -f docker/Dockerfile.backend \
  .
```

### Step 3: Create Azure Database
```bash
az postgres server create \
  --resource-group autoblockchain-rg \
  --name autoblockchain-db \
  --location eastus \
  --admin-user blockchain_user \
  --admin-password $DB_PASSWORD \
  --sku-name B_Gen5_1 \
  --storage-size 51200 \
  --version 12
```

### Step 4: Deploy to AKS
```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoblockchain-backend
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: autoblockchain
  template:
    metadata:
      labels:
        app: autoblockchain
    spec:
      containers:
      - name: backend
        image: autoblockchaincr.azurecr.io/autoblockchain-backend:1.0
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db-host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: autoblockchain-service
spec:
  type: LoadBalancer
  selector:
    app: autoblockchain
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
```

Deploy:
```bash
# Create namespace
kubectl create namespace autoblockchain

# Create secrets
kubectl create secret generic db-secret \
  --from-literal=password=$DB_PASSWORD \
  -n autoblockchain

# Create config map
kubectl create configmap app-config \
  --from-literal=db-host=autoblockchain-db.postgres.database.azure.com \
  -n autoblockchain

# Deploy
kubectl apply -f kubernetes/deployment.yaml

# Monitor deployment
kubectl rollout status deployment/autoblockchain-backend -n autoblockchain
kubectl get pods -n autoblockchain
kubectl logs <pod-name> -n autoblockchain
```

---

## 📊 GCP Deployment (Cloud Run + Cloud SQL)

### Step 1: Create Cloud SQL Instance
```bash
gcloud sql instances create autoblockchain-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1
```

### Step 2: Build and Push to Artifact Registry
```bash
# Enable Artifact Registry API
gcloud services enable artifactregistry.googleapis.com

# Create repository
gcloud artifacts repositories create autoblockchain \
  --repository-format=docker \
  --location=us-central1

# Build and push
gcloud builds submit \
  --tag us-central1-docker.pkg.dev/$PROJECT_ID/autoblockchain/backend:1.0 \
  --dockerfile=docker/Dockerfile.backend
```

### Step 3: Deploy to Cloud Run
```bash
gcloud run deploy autoblockchain-backend \
  --image=us-central1-docker.pkg.dev/$PROJECT_ID/autoblockchain/backend:1.0 \
  --platform=managed \
  --region=us-central1 \
  --memory=512Mi \
  --cpu=1 \
  --set-cloudsql-instances=$PROJECT_ID:us-central1:autoblockchain-db \
  --set-env-vars=NODE_ENV=production,FABRIC_CHANNEL=vehicle-channel \
  --min-instances=1 \
  --max-instances=10
```

---

## 🔍 Monitoring & Logs

### Local Development
```bash
# View all container logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# Stream logs with filters
docker-compose logs -f backend | grep -i error
```

### AWS CloudWatch
```bash
# View logs
aws logs tail /ecs/autoblockchain --follow

# Get specific time range
aws logs get-log-events \
  --log-group-name /ecs/autoblockchain \
  --log-stream-name backend-stream \
  --start-time $(($(date +%s)*1000 - 3600000))
```

### Azure Monitor
```bash
# Get logs from AKS
kubectl logs -f deployment/autoblockchain-backend

# Get metrics
az monitor metrics list \
  --resource /subscriptions/.../resourceGroups/autoblockchain-rg/providers/Microsoft.ContainerService/managedClusters/autoblockchain-aks
```

### GCP Cloud Logging
```bash
# Stream logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=autoblockchain-backend" \
  --limit 50 \
  --format json
```

---

## 🧹 Cleanup

### Remove Local Containers
```bash
docker-compose down
docker-compose down -v  # Remove volumes too
docker system prune -a  # Remove unused images
```

### Remove AWS Resources
```bash
aws ecs delete-service --cluster autoblockchain --service autoblockchain-backend --force
aws ecs delete-cluster --cluster autoblockchain
aws rds delete-db-instance --db-instance-identifier autoblockchain-db --skip-final-snapshot
aws ecr delete-repository --repository-name autoblockchain-backend --force
```

### Remove Azure Resources
```bash
az aks delete --resource-group autoblockchain-rg --name autoblockchain-aks
az postgres server delete --resource-group autoblockchain-rg --name autoblockchain-db
az group delete --name autoblockchain-rg
```

### Clean up GCP
```bash
gcloud run services delete autoblockchain-backend --region=us-central1
gcloud sql instances delete autoblockchain-db
gcloud artifacts repositories delete autoblockchain --location=us-central1
```

