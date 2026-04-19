# VEHICLE LIFECYCLE STATE MACHINE

## State Transition Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  OEM MANUFACTURING PHASE                                        │
│                                                                 │
│  POST /vehicle/create                                           │
│  Input: { vin, model, factoryId }                              │
│  ────────────────────────────────────────────────────────────  │
│              ⬇                                                  │
│        [CREATED]                                                │
│      Status: CREATED                                            │
│      owner: factoryId                                           │
│      dealerId: null                                             │
│      shipment: null                                             │
│              │                                                  │
└──────────────┼──────────────────────────────────────────────────┘
               │
┌──────────────┼──────────────────────────────────────────────────┐
│              │                                                  │
│  LOGISTICS PHASE                                                │
│                                                                 │
│  POST /vehicle/shipment (ONE OR MORE TIMES)                    │
│  Input: { vin, location, status }                              │
│  ────────────────────────────────────────────────────────────  │
│              ⬇                                                  │
│        [IN_TRANSIT]                                             │
│      Status: IN_TRANSIT                                         │
│      shipment: { location, status, updatedAt }                 │
│              │                                                  │
│              │ (can update multiple times)                      │
│              ⬇                                                  │
│        [IN_TRANSIT]  (updated shipment data)                    │
│              │                                                  │
└──────────────┼──────────────────────────────────────────────────┘
               │
┌──────────────┼──────────────────────────────────────────────────┐
│              │                                                  │
│  DEALER ALLOCATION PHASE                                        │
│                                                                 │
│  POST /vehicle/dealer                                           │
│  Input: { vin, dealerId }                                       │
│  ────────────────────────────────────────────────────────────  │
│              ⬇                                                  │
│   [ASSIGNED_TO_DEALER]                                          │
│      Status: ASSIGNED_TO_DEALER                                 │
│      dealerId: <assigned dealer>                                │
│      owner: factoryId (unchanged)                               │
│              │                                                  │
└──────────────┼──────────────────────────────────────────────────┘
               │
┌──────────────┼──────────────────────────────────────────────────┐
│              │                                                  │
│  CUSTOMER OWNERSHIP TRANSFER PHASE                              │
│                                                                 │
│  POST /vehicle/transfer                                         │
│  Input: { vin, customerId }                                     │
│  ────────────────────────────────────────────────────────────  │
│  PRECONDITIONS:                                                 │
│    - dealerId must be set (can transfer without shipment)       │
│    - Cannot be SOLD already                                     │
│              ⬇                                                  │
│          [SOLD]  ◄─── FINAL STATE (IMMUTABLE)                   │
│      Status: SOLD                                               │
│      owner: <customerId>                                        │
│      dealerId: <cannot change>                                  │
│      Cannot accept further updates                              │
│              │                                                  │
│ ✗ NO MORE UPDATES ALLOWED AFTER THIS STATE ✗                   │
│              │                                                  │
└──────────────┴──────────────────────────────────────────────────┘
```

## Transition Table

| From State | To State | Trigger | Preconditions | Postconditions |
|---|---|---|---|---|
| CREATED | IN_TRANSIT | updateShipment() | - | shipment object created, status updated |
| IN_TRANSIT | IN_TRANSIT | updateShipment() | - | shipment object updated |
| CREATED | ASSIGNED_TO_DEALER | assignDealer() | - | dealerId set |
| IN_TRANSIT | ASSIGNED_TO_DEALER | assignDealer() | - | dealerId set |
| ASSIGNED_TO_DEALER | ASSIGNED_TO_DEALER | updateShipment() | - | shipment updated, status stays ASSIGNED (if already assigned) |
| ASSIGNED_TO_DEALER | SOLD | transferOwnership() | dealerId must be set | owner changed to customerId, FINAL |
| CREATED | SOLD | transferOwnership() | ✗ FAILS | dealerId must be set first |
| SOLD | * | any | ✗ BLOCKED | Cannot accept further updates |

## Invalid Transitions (Will Fail)

```
❌ CREATED → SOLD (without assignDealer)
   Error: "Vehicle must be assigned to a dealer before transferring ownership"

❌ SOLD → ASSIGNED_TO_DEALER
   Error: "Vehicle has already been sold"

❌ SOLD → IN_TRANSIT
   Error: "Shipment cannot be updated after delivery"

❌ SOLD → SOLD
   Error: "Vehicle has already been sold"
```

## Key Constraints

1. **VIN Uniqueness**: Each VIN can only be created once
2. **No Reassignment**: Once assigned to a dealer, cannot reassign to another
3. **Sequential States**: Must follow the state machine order
4. **Immutability**: Once SOLD, no further updates allowed
5. **Dealer Prerequisite**: Must assign dealer before transferring ownership

## Query Operation

```
GET /vehicle/:vin
────────────────────────────────────────────────
Retrieves complete lifecycle state at any point
No state change (read-only)
```

## Data Structure at Each Stage

### After createVehicle
```json
{
  "vin": "VIN-AUTO-001",
  "model": "Sedan-2024",
  "factoryId": "MFG-001",
  "owner": "MFG-001",
  "dealerId": null,
  "shipment": null,
  "status": "CREATED",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### After updateShipment
```json
{
  "vin": "VIN-AUTO-001",
  "model": "Sedan-2024",
  "factoryId": "MFG-001",
  "owner": "MFG-001",
  "dealerId": null,
  "shipment": {
    "location": "Port-LA",
    "status": "IN_TRANSIT",
    "updatedAt": "2024-01-16T14:00:00Z"
  },
  "status": "IN_TRANSIT",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-16T14:00:00Z"
}
```

### After assignDealer
```json
{
  "vin": "VIN-AUTO-001",
  "model": "Sedan-2024",
  "factoryId": "MFG-001",
  "owner": "MFG-001",
  "dealerId": "DEALER-NYC",
  "shipment": { ... },
  "status": "ASSIGNED_TO_DEALER",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-17T09:00:00Z"
}
```

### After transferOwnership (FINAL)
```json
{
  "vin": "VIN-AUTO-001",
  "model": "Sedan-2024",
  "factoryId": "MFG-001",
  "owner": "CUST-John-Doe",
  "dealerId": "DEALER-NYC",
  "shipment": { ... },
  "status": "SOLD",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-18T15:30:00Z"
}
```
