// Controller layer for vehicle-related API requests.
// It calls the Fabric service and returns JSON responses.

const fabricService = require('../services/fabricService');

async function createVehicle(req, res, next) {
  try {
    const { vin, model, factoryId } = req.body;
    if (!vin || !model || !factoryId) {
      return res.status(400).json({ error: 'vin, model, and factoryId are required' });
    }

    const result = await fabricService.submitTransaction('createVehicle', vin, model, factoryId);
    res.status(201).json({ success: true, data: JSON.parse(result) });
  } catch (error) {
    next(error);
  }
}

async function updateShipment(req, res, next) {
  try {
    const { vin, location, status } = req.body;
    if (!vin || !location || !status) {
      return res.status(400).json({ error: 'vin, location, and status are required' });
    }

    const result = await fabricService.submitTransaction('updateShipment', vin, location, status);
    res.status(200).json({ success: true, data: JSON.parse(result) });
  } catch (error) {
    next(error);
  }
}

async function assignDealer(req, res, next) {
  try {
    const { vin, dealerId } = req.body;
    if (!vin || !dealerId) {
      return res.status(400).json({ error: 'vin and dealerId are required' });
    }

    const result = await fabricService.submitTransaction('assignDealer', vin, dealerId);
    res.status(200).json({ success: true, data: JSON.parse(result) });
  } catch (error) {
    next(error);
  }
}

async function transferOwnership(req, res, next) {
  try {
    const { vin, customerId } = req.body;
    if (!vin || !customerId) {
      return res.status(400).json({ error: 'vin and customerId are required' });
    }

    const result = await fabricService.submitTransaction('transferOwnership', vin, customerId);
    res.status(200).json({ success: true, data: JSON.parse(result) });
  } catch (error) {
    next(error);
  }
}

async function getVehicle(req, res, next) {
  try {
    const { vin } = req.params;
    if (!vin) {
      return res.status(400).json({ error: 'vin parameter is required' });
    }

    const result = await fabricService.evaluateTransaction('getVehicle', vin);
    res.status(200).json({ success: true, data: JSON.parse(result) });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createVehicle,
  updateShipment,
  assignDealer,
  transferOwnership,
  getVehicle,
};
