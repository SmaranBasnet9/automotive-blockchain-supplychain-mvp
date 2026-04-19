# Automotive Supply Chain Blockchain Solution

**An Enterprise-Grade Hyperledger Fabric Implementation for Transparent Vehicle Lifecycle Management**

A production-ready distributed ledger system that leverages Hyperledger Fabric to create an immutable, auditable record of vehicle movement through the automotive supply chain.

---

## 🎯 Problem Statement

The automotive supply chain faces critical trust and transparency challenges:

- **Counterfeit Parts Risk**: No cryptographic proof of authenticity or origin
- **Manual Paperwork**: Excel/PDF records are tamper-prone and inefficient
- **Siloed Data**: Manufacturers, logistics, dealers operate in isolated systems
- **Fraud Vulnerability**: Vehicle ownership, mileage, accident history can be falsified
- **Recall Inefficiency**: No rapid way to identify affected vehicles across networks

**Result**: Billions lost annually to fraud, inefficient processes, and untraceability across 7-10 parties.

---

## ✅ Solution Overview

A **blockchain-based vehicle lifecycle tracker** that creates an immutable, timestamped record of every vehicle's journey:

```
[OEM Manufacturing] → [Logistics Tracking] → [Dealer Allocation] → [Customer Ownership]
         ↓                    ↓                      ↓                    ↓
    Ledger Entry         Shipment Events      Ownership Transfer      Final Record
```

**Key Benefits:**
- ✅ **Immutable Records** - Once written, cannot be altered (cryptographic guarantee)
- ✅ **Real-Time Visibility** - All parties see current vehicle status instantly
- ✅ **Fraud Detection** - Tamper detection through cryptographic proofs
- ✅ **Compliance** - Complete audit trail for regulatory requirements
- ✅ **Automation** - Smart contracts enforce business rules automatically

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ OEM Portal   │  │ Logistics App│  │ Dealer Portal│          │
│  │ (Future)     │  │ (Future)     │  │ (Future)     │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼──────────────────┼──────────────────┼──────────────────┘
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼──────────────────┐
│                  NODE.JS EXPRESS API LAYER                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ REST Endpoints                                          │    │
│  │ • POST /vehicle/create        (OEM)                    │    │
│  │ • POST /vehicle/shipment      (Logistics)              │    │
│  │ • POST /vehicle/dealer        (Dealer)                 │    │
│  │ • POST /vehicle/transfer      (Customer)               │    │
│  │ • GET  /vehicle/:vin          (Query)                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                            ↓                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Fabric Gateway Service                                  │    │
│  │ • Connection Management                                 │    │
│  │ • Wallet Identity Loading                               │    │
│  │ • Transaction Submission                                │    │
│  │ • Event Listening                                       │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│         HYPERLEDGER FABRIC BLOCKCHAIN NETWORK                   │
│         (Distributed Ledger)                                    │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Peer 0     │  │  Orderer     │  │   Peer 1     │          │
│  │  (Endorser)  │  │  (Consensus) │  │  (Committer) │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Channel: vehicle-channel                                │   │
│  │ • Ledger State (Current Vehicle Data)                   │   │
│  │ • Transaction History (Immutable Audit Trail)           │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                   CHAINCODE (Smart Contract)                    │
│         vehicle-lifecycle-contract                              │
│                                                                 │
│  Functions:                                                     │
│  • createVehicle(vin, model, factoryId)                        │
│  • updateShipment(vin, location, status)                       │
│  • assignDealer(vin, dealerId)                                 │
│  • transferOwnership(vin, customerId)                          │
│  • getVehicle(vin)                                             │
│                                                                 │
│  Features:                                                      │
│  ✓ State Machine Validation                                    │
│  ✓ Event Emission                                              │
│  ✓ Access Control (via MSP)                                    │
│  ✓ Input Validation                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Blockchain** | Hyperledger Fabric v2.5 | Distributed ledger, smart contracts |
| **Backend API** | Node.js 16+ | REST API server, business logic |
| **Framework** | Express.js 4.18 | HTTP server, routing, middleware |
| **Blockchain SDK** | Fabric Gateway v1.1 | Blockchain connectivity, wallet mgmt |
| **Communication** | gRPC v1.9 | Peer-to-peer blockchain communication |
| **Container** | Docker & Docker Compose | Deployment, network orchestration |
| **Database** | blockchain ledger | Immutable state storage |
| **Version Control** | Git | Source code management |

**Why Hyperledger Fabric?**
- ✅ Permissioned network (known participants)
- ✅ Pluggable consensus mechanism
- ✅ Privacy & confidentiality features
- ✅ Enterprise-grade stability and maturity
- ✅ Rich smart contract language support
- ✅ Ideal for supply chain use cases

---

## 📊 Vehicle Lifecycle State Machine

```
┌──────────────┐
│   CREATED    │  (OEM Manufacturing Phase)
│  Status: 0   │  - Vehicle manufactured
│ Owner: OEM   │  - Ledger entry created
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  IN_TRANSIT  │  (Logistics Phase)
│  Status: 1   │  - Vehicle in shipment
│ Multiple     │  - Location tracked
│ updates OK   │  - Can update N times
└──────┬───────┘
       │
       ▼
┌──────────────────────────┐
│ ASSIGNED_TO_DEALER       │  (Dealer Allocation Phase)
│  Status: 2               │  - Assigned to dealer
│ Dealer set               │  - Cannot reassign
│ Owner: OEM               │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│       SOLD               │  (Final State - IMMUTABLE)
│   Status: 3 [FINAL]      │  - Ownership transferred
│ Owner: Customer          │  - Record locked
│ Dealer: Set              │  - No further updates
│ No more updates          │
└──────────────────────────┘
```

**Key Constraints:**
- ✅ Each VIN is globally unique
- ✅ State transitions are sequential and non-reversible
- ✅ Must assign dealer before transferring ownership
- ✅ SOLD state is immutable (no further modifications)
- ✅ Shipment can be updated multiple times during transit

---

## 🚀 API Endpoints

### 1. Create Vehicle (OEM Manufacturing)
```bash
POST /vehicle/create
{
  "vin": "VIN2024001",
  "model": "Tesla-Model-S-Plaid",
  "factoryId": "FACTORY-FREMONT-001"
}
```
**Response**: Vehicle asset created with CREATED status
**Business Actor**: OEM/Manufacturer

### 2. Update Shipment (Logistics)
```bash
POST /vehicle/shipment
{
  "vin": "VIN2024001",
  "location": "Port-of-Oakland",
  "status": "IN_TRANSIT"
}
```
**Response**: Vehicle location and shipment status updated
**Business Actor**: Logistics Provider (can call multiple times)

### 3. Assign Dealer (Dealer Allocation)
```bash
POST /vehicle/dealer
{
  "vin": "VIN2024001",
  "dealerId": "DEALER-SF-LUXURY-001"
}
```
**Response**: Vehicle assigned to dealer
**Business Actor**: OEM or Logistics Partner

### 4. Transfer Ownership (Customer Purchase)
```bash
POST /vehicle/transfer
{
  "vin": "VIN2024001",
  "customerId": "CUSTOMER-JOHN-DOE"
}
```
**Response**: Ownership transferred, status set to SOLD (immutable)
**Business Actor**: Dealer/Salesperson

### 5. Query Vehicle (History & Status)
```bash
GET /vehicle/VIN2024001
```
**Response**: Complete vehicle lifecycle data
**Business Actor**: Any authorized party

---

## 🎬 Quick Demo (5 Minutes)

See a complete vehicle lifecycle in action:

```bash
# Step 1: Create vehicle at factory
curl -X POST http://localhost:3000/vehicle/create \
  -H "Content-Type: application/json" \
  -d '{"vin": "DEMO-2024", "model": "Sedan", "factoryId": "MFG-001"}'

# Step 2: Ship from factory
curl -X POST http://localhost:3000/vehicle/shipment \
  -H "Content-Type: application/json" \
  -d '{"vin": "DEMO-2024", "location": "Factory-Dock", "status": "SHIPPED"}'

# Step 3: Update location (Port)
curl -X POST http://localhost:3000/vehicle/shipment \
  -H "Content-Type: application/json" \
  -d '{"vin": "DEMO-2024", "location": "Port-LA", "status": "AT_PORT"}'

# Step 4: Assign to dealer
curl -X POST http://localhost:3000/vehicle/dealer \
  -H "Content-Type: application/json" \
  -d '{"vin": "DEMO-2024", "dealerId": "DEALER-NYC-001"}'

# Step 5: Sell to customer
curl -X POST http://localhost:3000/vehicle/transfer \
  -H "Content-Type: application/json" \
  -d '{"vin": "DEMO-2024", "customerId": "OWNER-JOHN-DOE"}'

# Step 6: View complete history
curl -X GET http://localhost:3000/vehicle/DEMO-2024
```

---

## 📋 Installation & Setup

### Prerequisites
```
✓ Node.js 16+
✓ npm or yarn
✓ Docker & Docker Compose
✓ Hyperledger Fabric network running
```

### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp.git
cd automotive-blockchain-supplychain-mvp

# 2. Install dependencies
npm install
cd backend && npm install

# 3. Setup wallet identity
npm run setup-wallet

# 4. Start backend server
npm start
```

Server runs on `http://localhost:3000`

---

## 📚 Documentation

- **[VEHICLE_LIFECYCLE_API.md](docs/VEHICLE_LIFECYCLE_API.md)** - Complete API reference with examples
- **[STATE_MACHINE.md](docs/STATE_MACHINE.md)** - State transitions and business rules
- **[TEST_CURL_COMMANDS.sh](docs/TEST_CURL_COMMANDS.sh)** - Automated test suite
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Technical implementation details

---

## 🔐 Security & Production Features

✅ **Immutable Ledger** - Tamper-proof cryptographic records  
✅ **Cryptographic Signing** - All transactions digitally signed  
✅ **Access Control** - Identity-based wallet authorization  
✅ **State Validation** - Chaincode enforces business rules  
✅ **Event Emission** - Real-time state change notifications  
✅ **Audit Trail** - Complete history available for compliance  

---

## 💼 Portfolio Highlights

| Achievement | Impact | Technical Depth |
|-------------|--------|-----------------|
| **Full-Stack Blockchain** | Chaincode + Backend + Network | Hyperledger Fabric expertise |
| **Distributed Consensus** | Multi-party transaction finality | gRPC, orderer, endorsement |
| **Smart Contracts** | Immutable business logic | Node.js contract development |
| **API Design** | RESTful supply chain interface | Express, Fabric Gateway SDK |
| **Production Patterns** | Error handling, logging, validation | Enterprise best practices |
| **Supply Chain Domain** | Real-world automotive use case | Industry context & impact |

---

## 🚀 Deployment

### Docker Compose (Complete Stack)
```bash
cd docker
docker-compose -f docker-compose.yml up -d
```

Includes:
- Hyperledger Fabric network
- Backend Express API service
- Network connectivity and configuration

---

## 🎓 Key Technologies Demonstrated

1. **Hyperledger Fabric 2.5**
   - Permissioned blockchain network
   - Chaincode development and deployment
   - Channel management
   - MSP (Membership Service Provider)

2. **Node.js + Express**
   - RESTful API design
   - Middleware architecture
   - Error handling patterns
   - Async/await concurrency

3. **Fabric Gateway SDK**
   - Wallet identity management
   - Transaction submission
   - Event listening
   - Blockchain connectivity

4. **DevOps & Containers**
   - Docker containerization
   - Docker Compose orchestration
   - Network configuration
   - Environment management

---

## 🎯 Interview Talking Points

**"Walk me through your project..."**

*"I built an automotive supply chain blockchain system using Hyperledger Fabric. The challenge was creating transparency and trust across multiple parties—OEMs, logistics providers, dealers, and customers—without a central authority. I solved this using a permissioned blockchain where each vehicle's lifecycle is recorded immutably."*

**Key Points to Highlight:**
1. **Problem-solving** - Identified real-world supply chain friction
2. **Architecture** - Designed multi-layer system (API → SDK → Blockchain)
3. **Blockchain domain** - Hyperledger Fabric, smart contracts, state machines
4. **Full-stack engineering** - Backend, blockchain, DevOps
5. **Production mindset** - Error handling, validation, logging
6. **Industry knowledge** - Supply chain domain expertise

---

## 📊 Performance Metrics

- **Transaction Latency**: ~1-2 seconds
- **Network Throughput**: Configuration dependent
- **State Database**: Linear growth with transactions
- **Scalability**: Horizontal via peer/orderer replication

---

## 🔮 Future Enhancements

1. **Multi-Organization Network** - Add partners as independent organizations
2. **IoT Integration** - Real-time GPS and sensor telemetry
3. **Mobile Application** - Customer tracking portal
4. **Analytics Dashboard** - Supply chain visibility platform
5. **Automated Compliance** - Regulatory enforcement
6. **Smart Routing** - ML-based optimization

---

## 📄 License

This project is provided as-is for educational and portfolio purposes.

---

**Status**: ✅ Production-Ready MVP

**Repository**: [GitHub](https://github.com/SmaranBasnet9/automotive-blockchain-supplychain-mvp)

