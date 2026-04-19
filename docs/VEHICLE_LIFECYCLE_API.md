// VEHICLE LIFECYCLE MANAGEMENT SYSTEM - API DOCUMENTATION
// Automotive Supply Chain MVP powered by Hyperledger Fabric

/**
 * STATE TRANSITION DIAGRAM
 * 
 *     CREATED
 *       ↓
 *   IN_TRANSIT (shipment updates)
 *       ↓
 * ASSIGNED_TO_DEALER
 *       ↓
 *     SOLD
 * 
 * IMMUTABILITY RULES:
 * - Vehicle cannot be reassigned to a different dealer
 * - Vehicle cannot be transferred twice
 * - Status transitions are linear and non-reversible
 */

/**
 * ============================================================================
 * API ENDPOINTS
 * ============================================================================
 */

// 1. CREATE VEHICLE
// POST /vehicle/create
// 
// Purpose: OEM manufacturing - creates a new vehicle record
// 
// Request Body:
// {
//   "vin": "VIN123456789",
//   "model": "Model-X-2024",
//   "factoryId": "Factory-Detroit-001"
// }
// 
// Successful Response (201):
// {
//   "success": true,
//   "data": {
//     "vin": "VIN123456789",
//     "model": "Model-X-2024",
//     "factoryId": "Factory-Detroit-001",
//     "owner": "Factory-Detroit-001",
//     "dealerId": null,
//     "shipment": null,
//     "status": "CREATED",
//     "createdAt": "2024-01-15T10:30:00.000Z",
//     "updatedAt": "2024-01-15T10:30:00.000Z"
//   }
// }
// 
// Error Response (400):
// {
//   "success": false,
//   "error": "vin, model, and factoryId are required"
// }
// 
// Error Response (409):
// {
//   "success": false,
//   "error": "Vehicle with VIN VIN123456789 already exists"
// }

// 2. UPDATE SHIPMENT
// POST /vehicle/shipment
// 
// Purpose: Logistics - track shipment movement and status
// 
// Request Body:
// {
//   "vin": "VIN123456789",
//   "location": "Port-of-LA",
//   "status": "IN_TRANSIT"
// }
// 
// Valid Status Values:
// - SHIPPED_FROM_FACTORY
// - IN_TRANSIT
// - ARRIVED_PORT
// - AT_HUB
// - IN_LOCAL_DELIVERY
// - ARRIVED_AT_DEALER
// 
// Successful Response (200):
// {
//   "success": true,
//   "data": {
//     "vin": "VIN123456789",
//     "model": "Model-X-2024",
//     "factoryId": "Factory-Detroit-001",
//     "owner": "Factory-Detroit-001",
//     "dealerId": null,
//     "shipment": {
//       "location": "Port-of-LA",
//       "status": "IN_TRANSIT",
//       "updatedAt": "2024-01-16T14:20:00.000Z"
//     },
//     "status": "IN_TRANSIT",
//     "createdAt": "2024-01-15T10:30:00.000Z",
//     "updatedAt": "2024-01-16T14:20:00.000Z"
//   }
// }
// 
// Error Response (404):
// {
//   "success": false,
//   "error": "Vehicle with VIN VIN123456789 does not exist"
// }
// 
// Error Response (400):
// {
//   "success": false,
//   "error": "vin, location, and status are required"
// }

// 3. ASSIGN DEALER
// POST /vehicle/dealer
// 
// Purpose: Dealer Layer - assign vehicle to authorized dealer
// 
// Request Body:
// {
//   "vin": "VIN123456789",
//   "dealerId": "Dealer-NYC-Central"
// }
// 
// Successful Response (200):
// {
//   "success": true,
//   "data": {
//     "vin": "VIN123456789",
//     "model": "Model-X-2024",
//     "factoryId": "Factory-Detroit-001",
//     "owner": "Factory-Detroit-001",
//     "dealerId": "Dealer-NYC-Central",
//     "shipment": {
//       "location": "Port-of-LA",
//       "status": "IN_TRANSIT",
//       "updatedAt": "2024-01-16T14:20:00.000Z"
//     },
//     "status": "ASSIGNED_TO_DEALER",
//     "createdAt": "2024-01-15T10:30:00.000Z",
//     "updatedAt": "2024-01-17T08:45:00.000Z"
//   }
// }
// 
// Error Response (409):
// {
//   "success": false,
//   "error": "Vehicle VIN123456789 has already been sold and cannot be assigned to a dealer"
// }

// 4. TRANSFER OWNERSHIP
// POST /vehicle/transfer
// 
// Purpose: Customer Layer - transfer vehicle ownership to end customer
// 
// Requirements:
// - Vehicle must be assigned to a dealer first
// - Vehicle cannot be sold twice
// 
// Request Body:
// {
//   "vin": "VIN123456789",
//   "customerId": "CUST_12345_John_Doe"
// }
// 
// Successful Response (200):
// {
//   "success": true,
//   "data": {
//     "vin": "VIN123456789",
//     "model": "Model-X-2024",
//     "factoryId": "Factory-Detroit-001",
//     "owner": "CUST_12345_John_Doe",
//     "dealerId": "Dealer-NYC-Central",
//     "shipment": {
//       "location": "Port-of-LA",
//       "status": "IN_TRANSIT",
//       "updatedAt": "2024-01-16T14:20:00.000Z"
//     },
//     "status": "SOLD",
//     "createdAt": "2024-01-15T10:30:00.000Z",
//     "updatedAt": "2024-01-18T15:10:00.000Z"
//   }
// }
// 
// Error Response (409):
// {
//   "success": false,
//   "error": "Vehicle VIN123456789 must be assigned to a dealer before transferring ownership"
// }
// 
// Error Response (409):
// {
//   "success": false,
//   "error": "Vehicle VIN123456789 has already been sold"
// }

// 5. GET VEHICLE (Query)
// GET /vehicle/:vin
// 
// Purpose: Query vehicle history and current status
// 
// Example Request:
// GET /vehicle/VIN123456789
// 
// Successful Response (200):
// {
//   "success": true,
//   "data": {
//     "vin": "VIN123456789",
//     "model": "Model-X-2024",
//     "factoryId": "Factory-Detroit-001",
//     "owner": "CUST_12345_John_Doe",
//     "dealerId": "Dealer-NYC-Central",
//     "shipment": {
//       "location": "Port-of-LA",
//       "status": "IN_TRANSIT",
//       "updatedAt": "2024-01-16T14:20:00.000Z"
//     },
//     "status": "SOLD",
//     "createdAt": "2024-01-15T10:30:00.000Z",
//     "updatedAt": "2024-01-18T15:10:00.000Z"
//   }
// }
// 
// Error Response (404):
// {
//   "success": false,
//   "error": "Vehicle with VIN VIN123456789 does not exist"
// }

/**
 * ============================================================================
 * COMPLETE WORKFLOW EXAMPLE (Happy Path)
 * ============================================================================
 */

// Step 1: OEM creates vehicle
// curl -X POST http://localhost:3000/vehicle/create \
//   -H "Content-Type: application/json" \
//   -d '{
//     "vin": "VIN-AUTO-001",
//     "model": "Sedan-Premium-2024",
//     "factoryId": "MFG-Detroit"
//   }'

// Step 2: Logistics updates shipment
// curl -X POST http://localhost:3000/vehicle/shipment \
//   -H "Content-Type: application/json" \
//   -d '{
//     "vin": "VIN-AUTO-001",
//     "location": "Port-of-Long-Beach",
//     "status": "IN_TRANSIT"
//   }'

// Step 3: Update shipment again (multiple updates allowed)
// curl -X POST http://localhost:3000/vehicle/shipment \
//   -H "Content-Type: application/json" \
//   -d '{
//     "vin": "VIN-AUTO-001",
//     "location": "Distribution-Center-LA",
//     "status": "AT_HUB"
//   }'

// Step 4: Dealer assignment
// curl -X POST http://localhost:3000/vehicle/dealer \
//   -H "Content-Type: application/json" \
//   -d '{
//     "vin": "VIN-AUTO-001",
//     "dealerId": "DEALER-Beverly-Hills-Luxury"
//   }'

// Step 5: Transfer to customer
// curl -X POST http://localhost:3000/vehicle/transfer \
//   -H "Content-Type: application/json" \
//   -d '{
//     "vin": "VIN-AUTO-001",
//     "customerId": "OWNER-Sarah-Smith-LA"
//   }'

// Step 6: Query final state
// curl http://localhost:3000/vehicle/VIN-AUTO-001

/**
 * ============================================================================
 * ERROR HANDLING LOGIC
 * ============================================================================
 */

// ERROR CASE 1: Duplicate Vehicle Creation
// If you try to create a vehicle with a VIN that already exists:
// 
// Request:
// POST /vehicle/create
// { "vin": "VIN-AUTO-001", ... }
// 
// Response (HTTP 500 with error message):
// {
//   "success": false,
//   "error": "Fabric submitTransaction error: Vehicle with VIN VIN-AUTO-001 already exists"
// }

// ERROR CASE 2: Invalid State Transition - Shipment Before Creation
// If you try to update shipment for non-existent vehicle:
// 
// Request:
// POST /vehicle/shipment
// { "vin": "NONEXISTENT-VIN", ... }
// 
// Response (HTTP 500):
// {
//   "success": false,
//   "error": "Fabric submitTransaction error: Vehicle with VIN NONEXISTENT-VIN does not exist"
// }

// ERROR CASE 3: Dealer Assignment Before Shipment
// (Actually allowed - OEM can directly assign without shipment)
// But attempting to transfer ownership without dealer assignment:
// 
// Request:
// POST /vehicle/transfer (without prior assignDealer call)
// { "vin": "VIN-AUTO-001", "customerId": "CUST-001" }
// 
// Response (HTTP 500):
// {
//   "success": false,
//   "error": "Fabric submitTransaction error: Vehicle VIN-AUTO-001 must be assigned to a dealer before transferring ownership"
// }

// ERROR CASE 4: Double Ownership Transfer
// Once a vehicle is sold, it cannot be sold again:
// 
// Request (second transfer attempt):
// POST /vehicle/transfer
// { "vin": "VIN-AUTO-001", "customerId": "CUST-002" }
// 
// Response (HTTP 500):
// {
//   "success": false,
//   "error": "Fabric submitTransaction error: Vehicle VIN-AUTO-001 has already been sold"
// }

// ERROR CASE 5: Missing Required Fields
// Request:
// POST /vehicle/create
// { "vin": "VIN-AUTO-001" }  // missing model and factoryId
// 
// Response (HTTP 400):
// {
//   "success": false,
//   "error": "vin, model, and factoryId are required"
// }

/**
 * ============================================================================
 * BLOCKCHAIN DATA IMMUTABILITY
 * ============================================================================
 */

// All transactions are immutable once written to ledger.
// The vehicle JSON structure grows with each transaction:
// 
// After createVehicle:
// {
//   "vin": "...",
//   "model": "...",
//   "factoryId": "...",
//   "owner": "Factory-001",
//   "dealerId": null,
//   "shipment": null,
//   "status": "CREATED",
//   "createdAt": "...",
//   "updatedAt": "..."
// }
// 
// After updateShipment (adds shipment object):
// {
//   "vin": "...",
//   "model": "...",
//   "factoryId": "...",
//   "owner": "Factory-001",
//   "dealerId": null,
//   "shipment": {
//     "location": "Port-LA",
//     "status": "IN_TRANSIT",
//     "updatedAt": "..."
//   },
//   "status": "IN_TRANSIT",
//   "createdAt": "...",
//   "updatedAt": "..."
// }
// 
// After assignDealer (updates dealerId and status):
// {
//   "vin": "...",
//   "model": "...",
//   "factoryId": "...",
//   "owner": "Factory-001",
//   "dealerId": "Dealer-NYC",
//   "shipment": { ... },
//   "status": "ASSIGNED_TO_DEALER",
//   "createdAt": "...",
//   "updatedAt": "..."
// }
// 
// After transferOwnership (updates owner and final status):
// {
//   "vin": "...",
//   "model": "...",
//   "factoryId": "...",
//   "owner": "CUSTOMER-John",
//   "dealerId": "Dealer-NYC",
//   "shipment": { ... },
//   "status": "SOLD",
//   "createdAt": "...",
//   "updatedAt": "..."
// }

/**
 * ============================================================================
 * KEY DESIGN DECISIONS
 * ============================================================================
 */

// 1. COMPOSITE KEYS
//    - Used: ctx.stub.createCompositeKey('Vehicle', [vin])
//    - Allows efficient querying by VIN
//    - Ensures uniqueness

// 2. STATUS MACHINE
//    - CREATED → IN_TRANSIT → ASSIGNED_TO_DEALER → SOLD
//    - States are sequential and immutable
//    - Each state represents a phase in supply chain

// 3. SHIPMENT HISTORY
//    - Only ONE shipment object per vehicle (overwrites)
//    - Multiple updates allowed (location and status can change)
//    - But cannot update after vehicle is delivered/sold

// 4. EVENT EMISSION
//    - Each transaction emits a Fabric event
//    - Enables listeners to track state changes
//    - Useful for notifications and auditing

// 5. VALIDATION AT CHAINCODE LEVEL
//    - All business logic validated on ledger
//    - Prevents invalid state transitions at source
//    - Smart contracts are the source of truth
