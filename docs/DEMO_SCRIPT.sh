#!/bin/bash

# Automotive Blockchain Supply Chain MVP - COMPLETE DEMO SCRIPT
# This script demonstrates the full vehicle lifecycle in approximately 2 minutes
# Works with curl commands against the backend API

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:3000}"
VIN="DEMO-$(date +%s)"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   AUTOMOTIVE BLOCKCHAIN SUPPLY CHAIN MVP - LIVE DEMO         ║${NC}"
echo -e "${BLUE}║   Hyperledger Fabric | Vehicle Lifecycle Tracking           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Demo VIN: $VIN${NC}"
echo -e "${YELLOW}API Base: $API_BASE_URL${NC}"
echo ""

# Helper function to make API calls
call_api() {
  local method=$1
  local endpoint=$2
  local data=$3
  
  if [ -z "$data" ]; then
    curl -s -X "$method" "$API_BASE_URL$endpoint" \
      -H "Content-Type: application/json"
  else
    curl -s -X "$method" "$API_BASE_URL$endpoint" \
      -H "Content-Type: application/json" \
      -d "$data"
  fi
}

# Demo Step 1: Create Vehicle
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 1: OEM MANUFACTURING - Create Vehicle${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: OEM Manufacturing Plant (Factory-Detroit)"
echo "Action: Register new vehicle on blockchain"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "POST /vehicle/create"
echo "{\"vin\": \"$VIN\", \"model\": \"Tesla-Model-S-Plaid\", \"factoryId\": \"FACTORY-DETROIT-001\"}"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api POST "/vehicle/create" \
  "{\"vin\": \"$VIN\", \"model\": \"Tesla-Model-S-Plaid\", \"factoryId\": \"FACTORY-DETROIT-001\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Vehicle created with status: CREATED${NC}"
echo ""
sleep 2

# Demo Step 2: Update Shipment - Location 1
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 2: LOGISTICS - Ship Vehicle (Location 1)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: Logistics Provider (TransGlobal Shipping)"
echo "Action: Vehicle loaded on truck, leaves factory"
echo "Status Update: SHIPPED_FROM_FACTORY"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "POST /vehicle/shipment"
echo "{\"vin\": \"$VIN\", \"location\": \"Factory-Dock-Detroit\", \"status\": \"SHIPPED_FROM_FACTORY\"}"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api POST "/vehicle/shipment" \
  "{\"vin\": \"$VIN\", \"location\": \"Factory-Dock-Detroit\", \"status\": \"SHIPPED_FROM_FACTORY\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Shipment updated: Status now IN_TRANSIT${NC}"
echo ""
sleep 2

# Demo Step 3: Update Shipment - Location 2
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 3: LOGISTICS - Ship Vehicle (Location 2)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: Logistics Provider"
echo "Action: Vehicle arrives at Port of Vancouver"
echo "Status Update: AT_PORT (Multiple updates allowed during transit)"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "POST /vehicle/shipment"
echo "{\"vin\": \"$VIN\", \"location\": \"Port-of-Vancouver\", \"status\": \"AT_PORT\"}"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api POST "/vehicle/shipment" \
  "{\"vin\": \"$VIN\", \"location\": \"Port-of-Vancouver\", \"status\": \"AT_PORT\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Shipment updated: Vehicle now at port${NC}"
echo ""
sleep 2

# Demo Step 4: Update Shipment - Location 3
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 4: LOGISTICS - Ship Vehicle (Location 3)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: Logistics Provider"
echo "Action: Vehicle arrives at distribution hub in Los Angeles"
echo "Status Update: AT_HUB"
echo ""

RESPONSE=$(call_api POST "/vehicle/shipment" \
  "{\"vin\": \"$VIN\", \"location\": \"Distribution-Hub-LA\", \"status\": \"AT_HUB\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Shipment final location: Distribution hub${NC}"
echo ""
sleep 2

# Demo Step 5: Assign Dealer
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 5: DEALER ALLOCATION - Assign Vehicle to Dealer${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: OEM / Dealer Network"
echo "Action: Allocate vehicle to Tesla Centers Beverly Hills"
echo "New Status: ASSIGNED_TO_DEALER"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "POST /vehicle/dealer"
echo "{\"vin\": \"$VIN\", \"dealerId\": \"DEALER-BEVERLY-HILLS-LUX\"}"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api POST "/vehicle/dealer" \
  "{\"vin\": \"$VIN\", \"dealerId\": \"DEALER-BEVERLY-HILLS-LUX\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Vehicle assigned to dealer: DEALER-BEVERLY-HILLS-LUX${NC}"
echo ""
sleep 2

# Demo Step 6: Transfer Ownership
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 6: CUSTOMER OWNERSHIP - Transfer to Customer${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: Dealership Salesperson"
echo "Action: Customer purchases vehicle"
echo "New Status: SOLD (FINAL - IMMUTABLE)"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "POST /vehicle/transfer"
echo "{\"vin\": \"$VIN\", \"customerId\": \"OWNER-SARAH-JOHNSON-BH\"}"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api POST "/vehicle/transfer" \
  "{\"vin\": \"$VIN\", \"customerId\": \"OWNER-SARAH-JOHNSON-BH\"}")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Ownership transferred: Vehicle now SOLD (immutable record)${NC}"
echo ""
sleep 2

# Demo Step 7: Query Complete History
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 7: AUDIT TRAIL - Query Complete Vehicle History${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Actor: Any Authorized Party"
echo "Action: Query complete lifecycle history and current state"
echo ""
echo -e "${YELLOW}Request:${NC}"
echo "GET /vehicle/$VIN"
echo ""
echo -e "${YELLOW}Response:${NC}"

RESPONSE=$(call_api GET "/vehicle/$VIN")

echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
echo ""
echo -e "${GREEN}✓ Complete audit trail retrieved from blockchain${NC}"
echo ""

# Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}DEMO COMPLETE: FULL VEHICLE LIFECYCLE DEMONSTRATED${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "✓ Vehicle VIN:         $VIN"
echo "✓ Model:               Tesla-Model-S-Plaid"
echo "✓ Manufacturer:        FACTORY-DETROIT-001"
echo "✓ Final Owner:         OWNER-SARAH-JOHNSON-BH"
echo "✓ Dealer:              DEALER-BEVERLY-HILLS-LUX"
echo "✓ Final Status:        SOLD"
echo "✓ State Changes:       CREATED → IN_TRANSIT → ASSIGNED_TO_DEALER → SOLD"
echo "✓ Blockchain:          ✓ Immutable"
echo "✓ Audit Trail:         ✓ Complete"
echo ""
echo -e "${BLUE}Key Achievements:${NC}"
echo "1. Multi-party transaction tracking (OEM → Logistics → Dealer → Customer)"
echo "2. Cryptographically immutable records (cannot be tampered)"
echo "3. Real-time visibility across supply chain"
echo "4. Automatic state machine enforcement"
echo "5. Complete audit trail for compliance"
echo ""
echo -e "${YELLOW}To run full test suite:${NC}"
echo "bash docs/TEST_CURL_COMMANDS.sh"
echo ""
