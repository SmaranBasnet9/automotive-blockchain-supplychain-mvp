# Automotive Blockchain Supply Chain MVP

## Overview

This is an enterprise-grade Hyperledger Fabric-based blockchain solution for tracking vehicle lifecycle in the automotive supply chain. The system provides immutable records of vehicle movement from OEM manufacturing through logistics, dealer allocation, and final customer ownership.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EXPRESS BACKEND                          │
│  (Node.js + Fabric Gateway SDK)                             │
│                                                             │
│  /vehicle/create        → createVehicle()                  │
│  /vehicle/shipment      → updateShipment()                 │
│  /vehicle/dealer        → assignDealer()                   │
│  /vehicle/transfer      → transferOwnership()              │
│  /vehicle/:vin          → getVehicle()                     │
└────────────────┬────────────────────────────────────────────┘
                 │ (Fabric Gateway Connection)
                 │
┌────────────────▼────────────────────────────────────────────┐
│        HYPERLEDGER FABRIC BLOCKCHAIN NETWORK               │
│                                                             │
│  Channel: vehicle-channel                                  │
│  Chaincode: vehicle-lifecycle                              │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐       │
│  │  Peer Node  │  │  Orderer    │  │  Chaincode   │       │
│  └─────────────┘  └─────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Smart Contract (Chaincode)
**Location**: `/chaincode/vehicle-lifecycle/vehicleContract.js`

Functions:
- `createVehicle(vin, model, factoryId)` - OEM manufacturing
- `updateShipment(vin, location, status)` - Logistics tracking
- `assignDealer(vin, dealerId)` - Dealer allocation
- `transferOwnership(vin, customerId)` - Ownership transfer
- `getVehicle(vin)` - Query vehicle state

### 2. Backend Service
**Location**: `/backend/`

- **app.js** - Express server setup
- **services/fabricService.js** - Fabric Gateway connectivity
- **routes/vehicleRoutes.js** - REST API endpoints
- **setupWallet.js** - Wallet initialization helper
- **connection.json** - Fabric network configuration

### 3. Documentation
- **VEHICLE_LIFECYCLE_API.md** - Complete API documentation with examples
- **STATE_MACHINE.md** - State transition diagram and constraints
- **TEST_CURL_COMMANDS.sh** - Ready-to-use cURL test commands

## State Machine

```
CREATED → IN_TRANSIT → ASSIGNED_TO_DEALER → SOLD
```

Each state represents a phase in the supply chain:
1. **CREATED** - Vehicle manufactured by OEM
2. **IN_TRANSIT** - Vehicle being shipped (multiple location updates allowed)
3. **ASSIGNED_TO_DEALER** - Vehicle assigned to authorized dealer
4. **SOLD** - Final state: ownership transferred to customer (immutable)

## API Endpoints

### Create Vehicle
```bash
POST /vehicle/create
{
  "vin": "VIN123456789",
  "model": "Sedan-2024",
  "factoryId": "Factory-001"
}
```

### Update Shipment
```bash
POST /vehicle/shipment
{
  "vin": "VIN123456789",
  "location": "Port-of-LA",
  "status": "IN_TRANSIT"
}
```

### Assign Dealer
```bash
POST /vehicle/dealer
{
  "vin": "VIN123456789",
  "dealerId": "Dealer-NYC"
}
```

### Transfer Ownership
```bash
POST /vehicle/transfer
{
  "vin": "VIN123456789",
  "customerId": "Customer-John-Doe"
}
```

### Get Vehicle
```bash
GET /vehicle/VIN123456789
```

## Running the System

### Prerequisites
- Hyperledger Fabric network running (test-network)
- Node.js 16+
- Fabric Gateway SDK installed

### Setup

1. **Install dependencies**
```bash
cd backend
npm install
```

2. **Initialize wallet identity**
```bash
cd backend
npm run setup-wallet
```

3. **Start backend server**
```bash
npm start
# or for development
npm run dev
```

4. **Test the API**
```bash
# Use the provided cURL commands
bash docs/TEST_CURL_COMMANDS.sh
```

## Error Handling

The system includes comprehensive error handling:

| Error | Cause | Solution |
|-------|-------|----------|
| Vehicle already exists | Duplicate VIN creation | Use unique VINs |
| Vehicle not found | Querying non-existent vehicle | Verify VIN exists |
| Invalid state transition | e.g., transfer before dealer assignment | Follow state machine |
| Already sold | Attempting to modify sold vehicle | Vehicle is immutable |
| Missing required fields | Incomplete request body | Include all required fields |
| Connection failed | Fabric network unreachable | Ensure network is running |
| Wallet not found | appUser identity missing | Run socket setup-wallet |

## Security Features

1. **Immutability** - Once recorded, vehicle data cannot be changed
2. **Cryptographic Verification** - All transactions signed by private key
3. **Access Control** - Only authorized identities can submit transactions
4. **Event Logging** - All state changes emit blockchain events
5. **Audit Trail** - Complete history available via ledger queries

## Performance Characteristics

- **Transaction Latency** - ~1-2 seconds per transaction
- **Throughput** - Depends on Fabric network configuration
- **Storage** - LinearGrowth with transaction volume

## Design Decisions

### Composite Keys
Used for efficient VIN-based lookups:
```javascript
const vehicleKey = ctx.stub.createCompositeKey('Vehicle', [vin]);
```

### Single Shipment Object
Only one shipment record per vehicle (overwrites on update):
- Reduces storage footprint
- Captures latest location and status
- Simplifies query logic

### State Machine Enforcement
State transitions validated at chaincode level:
- Prevents invalid sequences
- Ensures data consistency
- Acts as single source of truth

### Event Emission
Each transaction emits Fabric events:
- Enables real-time listeners
- Supports notification systems
- Facilitates auditing

## Future Enhancements

1. **Multi-org support** - Add logistics partners and dealers as separate organizations
2. **Smart routing** - Optimize shipment paths using supply chain data
3. **IoT integration** - Real-time GPS and sensor data from vehicles
4. **Predictive analytics** - Estimate delivery times and identify delays
5. **Customer portal** - Allow customers to track their vehicles
6. **Automated compliance** - Enforce regulatory requirements

## References

- [Hyperledger Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Fabric Gateway SDK](https://hyperledger.github.io/fabric-gateway/latest/)
- [Smart Contract API](https://hyperledger.github.io/fabric-sdk-node/release-1.4/)

## Support

For issues or questions, refer to:
- `/docs/VEHICLE_LIFECYCLE_API.md` - API reference
- `/docs/STATE_MACHINE.md` - State machine details
- `/docs/TEST_CURL_COMMANDS.sh` - Testing examples
