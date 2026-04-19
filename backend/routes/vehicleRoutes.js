// Express router for vehicle-related APIs.
// Handles vehicle lifecycle endpoints: create, shipment, dealer, ownership transfer, and query.

const express = require('express');
const router = express.Router();
const fabricService = require('../services/fabricService');

/**
 * POST /vehicle/create
 * Creates a new vehicle in the ledger.
 */
router.post('/create', async (req, res, next) => {
  try {
    const { vin, model, factoryId } = req.body;
    if (!vin || !model || !factoryId) {
      return res.status(400).json({ success: false, error: 'vin, model, and factoryId are required' });
    }

    const transactionResult = await fabricService.submitTransaction('createVehicle', vin, model, factoryId);
    const responsePayload = transactionResult ? JSON.parse(transactionResult) : null;

    res.status(201).json({ success: true, data: responsePayload });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /vehicle/shipment
 * Updates shipment status and location for a vehicle in transit.
 */
router.post('/shipment', async (req, res, next) => {
  try {
    const { vin, location, status } = req.body;
    if (!vin || !location || !status) {
      return res.status(400).json({ success: false, error: 'vin, location, and status are required' });
    }

    const transactionResult = await fabricService.submitTransaction('updateShipment', vin, location, status);
    const responsePayload = transactionResult ? JSON.parse(transactionResult) : null;

    res.status(200).json({ success: true, data: responsePayload });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /vehicle/dealer
 * Assigns a vehicle to a dealer in the supply chain.
 */
router.post('/dealer', async (req, res, next) => {
  try {
    const { vin, dealerId } = req.body;
    if (!vin || !dealerId) {
      return res.status(400).json({ success: false, error: 'vin and dealerId are required' });
    }

    const transactionResult = await fabricService.submitTransaction('assignDealer', vin, dealerId);
    const responsePayload = transactionResult ? JSON.parse(transactionResult) : null;

    res.status(200).json({ success: true, data: responsePayload });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /vehicle/transfer
 * Transfers vehicle ownership from dealer to customer.
 */
router.post('/transfer', async (req, res, next) => {
  try {
    const { vin, customerId } = req.body;
    if (!vin || !customerId) {
      return res.status(400).json({ success: false, error: 'vin and customerId are required' });
    }

    const transactionResult = await fabricService.submitTransaction('transferOwnership', vin, customerId);
    const responsePayload = transactionResult ? JSON.parse(transactionResult) : null;

    res.status(200).json({ success: true, data: responsePayload });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /vehicle/:vin
 * Retrieves the complete lifecycle history of a vehicle.
 */
router.get('/:vin', async (req, res, next) => {
  try {
    const { vin } = req.params;
    if (!vin) {
      return res.status(400).json({ success: false, error: 'vin parameter is required' });
    }

    const transactionResult = await fabricService.evaluateTransaction('getVehicle', vin);
    const responsePayload = transactionResult ? JSON.parse(transactionResult) : null;

    res.status(200).json({ success: true, data: responsePayload });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
