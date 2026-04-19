#!/bin/bash
# Automotive Blockchain Supply Chain MVP - API Testing Quickstart
# This script contains ready-to-use cURL commands for testing the full lifecycle

# ============================================================================
# SETUP VARIABLES (Modify as needed)
# ============================================================================

API_BASE_URL="http://localhost:3000"
VIN="VIN-TEST-$(date +%s)"
MODEL="Tesla-Model-S-Plaid-2024"
FACTORY_ID="Factory-Fremont-001"
DEALER_ID="Dealer-San-Francisco-Premium"
CUSTOMER_ID="Customer-John-Doe-SF"

echo "Testing Vehicle Lifecycle with VIN: $VIN"
echo "================================================"
echo ""

# ============================================================================
# 1. CREATE VEHICLE (OEM Manufacturing)
# ============================================================================
echo "STEP 1: Creating vehicle..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/create" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "model": "'$MODEL'",
    "factoryId": "'$FACTORY_ID'"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 2. UPDATE SHIPMENT - Location 1 (Logistics)
# ============================================================================
echo "STEP 2: Updating shipment - Location 1..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/shipment" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "location": "Factory-Dock-Fremont",
    "status": "SHIPPED_FROM_FACTORY"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 3. UPDATE SHIPMENT - Location 2
# ============================================================================
echo "STEP 3: Updating shipment - Location 2..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/shipment" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "location": "Port-of-Oakland",
    "status": "AT_PORT"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 4. UPDATE SHIPMENT - Location 3
# ============================================================================
echo "STEP 4: Updating shipment - Location 3..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/shipment" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "location": "Distribution-Hub-Denver",
    "status": "AT_HUB"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 5. ASSIGN DEALER
# ============================================================================
echo "STEP 5: Assigning to dealer..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/dealer" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "dealerId": "'$DEALER_ID'"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 6. TRANSFER OWNERSHIP (to Customer)
# ============================================================================
echo "STEP 6: Transferring ownership to customer..."
RESPONSE=$(curl -X POST "$API_BASE_URL/vehicle/transfer" \
  -H "Content-Type: application/json" \
  -d '{
    "vin": "'$VIN'",
    "customerId": "'$CUSTOMER_ID'"
  }')

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

# ============================================================================
# 7. QUERY FINAL STATE
# ============================================================================
echo "STEP 7: Querying final vehicle state..."
RESPONSE=$(curl -X GET "$API_BASE_URL/vehicle/$VIN" \
  -H "Content-Type: application/json")

echo "Response:"
echo "$RESPONSE" | jq .
echo ""

echo "================================================"
echo "✅ Full lifecycle test completed!"
echo "VIN: $VIN"
echo "Final Status: SOLD"
echo "Owner: $CUSTOMER_ID"
echo "Dealer: $DEALER_ID"
echo ""

# ============================================================================
# ERROR TEST CASES (Uncomment to test error scenarios)
# ============================================================================

# Test: Try to create duplicate vehicle
# echo "ERROR TEST 1: Creating duplicate vehicle..."
# curl -X POST "$API_BASE_URL/vehicle/create" \
#   -H "Content-Type: application/json" \
#   -d '{"vin": "'$VIN'", "model": "'$MODEL'", "factoryId": "'$FACTORY_ID'"}'
# echo ""

# Test: Try to transfer ownership without dealer assignment
# echo "ERROR TEST 2: Transfer without dealer assignment..."
# VIN_TEST="VIN-NO-DEALER"
# curl -X POST "$API_BASE_URL/vehicle/create" \
#   -H "Content-Type: application/json" \
#   -d '{"vin": "'$VIN_TEST'", "model": "'$MODEL'", "factoryId": "'$FACTORY_ID'"}'
# curl -X POST "$API_BASE_URL/vehicle/transfer" \
#   -H "Content-Type: application/json" \
#   -d '{"vin": "'$VIN_TEST'", "customerId": "CUST-TEST"}'
# echo ""

# Test: Try to transfer ownership twice
# echo "ERROR TEST 3: Double transfer..."
# curl -X POST "$API_BASE_URL/vehicle/transfer" \
#   -H "Content-Type: application/json" \
#   -d '{"vin": "'$VIN'", "customerId": "CUST-ANOTHER"}'
# echo ""
