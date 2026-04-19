# Automotive Supply Chain Blockchain Solution

**An Enterprise-Grade Hyperledger Fabric Implementation for Transparent Vehicle Lifecycle Management**

A production-ready distributed ledger system that leverages Hyperledger Fabric to create an immutable, auditable record of vehicle movement through the automotive supply chain—solving critical problems of fraud, traceability, and multi-party trust.

🔗 **GitHub**: [SmaranBasnet9/automotive-blockchain-supplychain-mvp](https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp)

---

## 🎯 Problem & Solution

### The Challenge
The automotive supply chain faces critical trust and transparency issues:
- **Counterfeit Parts** - No cryptographic proof of authenticity
- **Manual Records** - Excel/PDF documents are tamper-prone
- **Siloed Systems** - Manufacturers, logistics, dealers operate independently
- **Fraud Vulnerability** - False ownership claims, mileage rollback
- **Recall Inefficiency** - No rapid identification of affected vehicles

**Impact**: Billions lost annually to fraud and inefficient processes across 7-10 parties.

### The Solution
A blockchain-based vehicle lifecycle tracker creating **immutable, timestamped records**:

```
[OEM Manufacturing] → [Logistics Tracking] → [Dealer Allocation] → [Customer Ownership]
         ↓                    ↓                      ↓                    ↓
    Ledger Entry         Shipment Events      Ownership Transfer      Final Record
```

**Key Benefits:**
✅ Immutable Records | ✅ Real-Time Visibility | ✅ Fraud Detection | ✅ Compliance | ✅ Automation

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │OEM Portal│  │Logistics │  │  Dealer  │  (Future)            │
│  │          │  │   App    │  │ Portal   │                      │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘                      │
└────────┼─────────────┼─────────────┼───────────────────────────┘
         │             │             │
┌────────▼─────────────▼─────────────▼───────────────────────────┐
│         NODE.JS EXPRESS API LAYER (5 REST Endpoints)           │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ POST /vehicle/create        GET /vehicle/:vin         │   │
│  │ POST /vehicle/shipment      (Query)                    │   │
│  │ POST /vehicle/dealer                                   │   │
│  │ POST /vehicle/transfer                                 │   │
│  └────────────────────────────────────────────────────────┘   │
│                       │                                        │
│  ┌────────────────────▼─────────────────────────────────┐    │
│  │  Fabric Gateway Service Layer                         │    │
│  │  • Connection Management  • Wallet Identity           │    │
│  │  • Transaction Submission • Event Listening           │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────┬──────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────────┐
│    HYPERLEDGER FABRIC BLOCKCHAIN NETWORK (Distributed Ledger)  │
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐          │
│  │  Peer 0     │ ──│  Orderer    │─── Peer 1      │          │
│  │ (Endorser)  │   │ (Consensus) │   │ (Committer) │          │
│  └─────────────┘   └─────────────┘   └─────────────┘          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ Channel: vehicle-channel                              │     │
│  │ • Vehicle State Database (Current Status)             │     │
│  │ • Complete Transaction History (Audit Trail)          │     │
│  └──────────────────────────────────────────────────────┘     │
└──────────────────────┬──────────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────────┐
│   SMART CONTRACT (Chaincode: vehicle-lifecycle)                 │
│                                                                  │
│  Functions:                                                     │
│  • createVehicle()          • updateShipment()                 │
│  • assignDealer()           • transferOwnership()              │
│  • getVehicle() [Query]                                        │
│                                                                  │
│  Features: ✓ State Machine  ✓ Event Emission  ✓ Access Control│
└──────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose | Version |
|-------|-----------|---------|---------|
| **Blockchain** | Hyperledger Fabric | Distributed ledger & smart contracts | 2.5 |
| **Backend API** | Node.js + Express.js | REST API server | 16+ / 4.18 |
| **Blockchain SDK** | Fabric Gateway | Blockchain connectivity & wallet mgmt | 1.1 |
| **Communication** | gRPC | Peer-to-peer protocol | 1.9 |
| **Container** | Docker & Compose | Orchestration | Latest |
| **Database** | Blockchain Ledger | Immutable state storage | Fabric |
| **Version Control** | Git | Source management | Latest |

**Why Hyperledger Fabric?**
- Permissioned network (known participants)
- Enterprise-grade security and finality
- Pluggable consensus
- Privacy and confidentiality
- Ideal for B2B supply chain

---

## 📊 Vehicle Lifecycle State Machine

```
┌──────────────┐
│   CREATED    │  OEM Manufacturing
│  Status: 0   │  • Vehicle registered on blockchain
└──────┬───────┘  • Immutable creation record
       │
       ▼
┌──────────────┐
│  IN_TRANSIT  │  Logistics Phase
│  Status: 1   │  • Location tracked
│ (repeatable) │  • Multiple updates allowed
└──────┬───────┘  • Real-time visibility
       │
       ▼
┌────────────────────┐
│ASSIGNED_TO_DEALER  │  Dealer Allocation
│   Status: 2        │  • Single dealer assignment
└──────┬─────────────┘  • Cannot reassign
       │
       ▼
┌────────────────────┐
│      SOLD          │  Final State (IMMUTABLE)
│   Status: 3 [✓]    │  • Ownership transferred
│   NO UPDATES       │  • Record locked permanently
└────────────────────┘  • Cannot modify
```

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
```bash
Node.js 16+ | Docker & Compose | Git
```

### Installation
```bash
# 1. Clone & install
git clone https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp.git
cd automotive-blockchain-supplychain-mvp
npm install && cd backend && npm install

# 2. Create environment
cp ../backend/.env.example ../backend/.env

# 3. Start blockchain network
cd ../blockchain-network && docker-compose up -d && sleep 30

# 4. Initialize wallet
cd ../backend && npm run setup-wallet

# 5. Start backend API
npm start  # Runs on localhost:3000
```

---

## 🎬 Live Demo (2-3 Minutes)

```bash
bash docs/DEMO_SCRIPT.sh
```

Demonstrates complete vehicle lifecycle:
1. Vehicle creation (OEM)
2. Multiple shipment updates (Logistics)
3. Dealer assignment
4. Ownership transfer (Customer)
5. Complete audit trail query

---

## 📚 API Endpoints

| Method | Endpoint | Purpose | Actor |
|--------|----------|---------|-------|
| **POST** | `/vehicle/create` | Create vehicle | OEM |
| **POST** | `/vehicle/shipment` | Update shipment location | Logistics |
| **POST** | `/vehicle/dealer` | Assign to dealer | OEM/Logistics |
| **POST** | `/vehicle/transfer` | Transfer ownership | Dealer |
| **GET** | `/vehicle/:vin` | Query complete history | Any |

**Example:**
```bash
# Create vehicle
curl -X POST http://localhost:3000/vehicle/create \
  -H "Content-Type: application/json" \
  -d '{"vin": "VIN2024001", "model": "Tesla-Model-S", "factoryId": "FAC-001"}'

# Query history
curl http://localhost:3000/vehicle/VIN2024001
```

---

## 📖 Full Documentation

| Document | Content |
|----------|---------|
| [README_PROFESSIONAL.md](README_PROFESSIONAL.md) | Detailed project overview |
| [PORTFOLIO_GUIDE.md](PORTFOLIO_GUIDE.md) | Interview prep & talking points |
| [docs/VEHICLE_LIFECYCLE_API.md](docs/VEHICLE_LIFECYCLE_API.md) | Complete API reference |
| [docs/STATE_MACHINE.md](docs/STATE_MACHINE.md) | State transitions & rules |
| [docs/PRODUCTION_HARDENING.md](docs/PRODUCTION_HARDENING.md) | Security & enterprise features |
| [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) | Local, Docker, AWS, Azure, GCP |
| [docs/DEMO_SCRIPT.sh](docs/DEMO_SCRIPT.sh) | Automated end-to-end demo |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Technical details |

---

## 🔐 Security & Production Features

✅ **Immutable Ledger** - Cryptographic tamper-proofing  
✅ **Cryptographic Signing** - All transactions digitally signed  
✅ **Identity-Based Access** - Wallet authorization  
✅ **State Validation** - Business rule enforcement  
✅ **Event Emission** - Real-time notifications  
✅ **Audit Trail** - Complete compliance history  

---

## 💼 Portfolio Highlights

**Full-Stack Blockchain Engineering:**
- Hyperledger Fabric smart contract development
- Fabric Gateway SDK integration (Node.js)
- Multi-layer REST API architecture
- Distributed ledger design patterns
- Docker containerization & orchestration
- Cloud deployment (AWS, Azure, GCP)

**Industry Domain Expertise:**
- Automotive supply chain operations
- Multi-party collaboration frameworks  
- Fraud prevention mechanisms
- Regulatory compliance requirements

---

## 🎯 Interview Talking Points

**"I designed an enterprise blockchain solution for supply chain transparency using Hyperledger Fabric. The challenge was enabling real-time trust and visibility across multiple parties (OEM, logistics, dealer, customer) without a central authority. I solved this using a permissioned blockchain where each vehicle's complete lifecycle is recorded immutably."**

👉 See [PORTFOLIO_GUIDE.md](PORTFOLIO_GUIDE.md) for complete interview preparation guide.

---

## 📊 Project Status

| Deliverable | Status |
|-------------|--------|
| 5-function Chaincode | ✅ Complete |
| REST API (5 endpoints) | ✅ Complete |
| Fabric Gateway Integration | ✅ Complete |
| Docker Compose Network | ✅ Complete |
| Comprehensive Documentation | ✅ Complete |
| Demo Scripts | ✅ Complete |
| Production Hardening Guide | ✅ Complete |
| Multi-Cloud Deployment | ✅ Complete |

**Version**: 1.0 | **Status**: Production-Ready MVP

---

## 🌟 Key Features

**Smart Contracts:**
- ✅ State machine enforcement
- ✅ Input validation
- ✅ Event emission
- ✅ Composite key indexing

**API:**
- ✅ JSON request/response
- ✅ Error handling
- ✅ Input validation
- ✅ HTTP status codes

**Deployment:**
- ✅ Docker containerization
- ✅ Multi-container orchestration
- ✅ Environment configuration
- ✅ Health checks

**Documentation:**
- ✅ API reference (400+ lines)
- ✅ Architecture diagrams
- ✅ Deployment guides (3 clouds)
- ✅ Production hardening

---

## 🚀 Deployment Options

### Local Development
```bash
docker-compose -f blockchain-network/docker-compose.yml up -d
npm start
```

### Docker
```bash
docker-compose -f docker/docker-compose.prod.yml up -d
```

### Cloud (AWS/Azure/GCP)
See [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for complete instructions

---

## 📄 License

Educational and portfolio use.

---

**Built by**: Smaran Basnet | **Repository**: [GitHub](https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp)