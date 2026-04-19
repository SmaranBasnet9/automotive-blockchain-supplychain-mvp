// Chaincode entry point for the Vehicle lifecycle contract.
// This file exports the contract class for Hyperledger Fabric to instantiate.

const VehicleContract = require('./vehicleContract');

module.exports = VehicleContract;
