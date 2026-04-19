// Hyperledger Fabric chaincode for automotive vehicle lifecycle management.
// Defines vehicle asset transactions and emits events for each state change.

const { Contract } = require('fabric-contract-api');

class VehicleContract extends Contract {
  /**
   * Create a new vehicle asset on the ledger.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   * @param {string} model - Vehicle model name
   * @param {string} factoryId - Factory identifier that created the vehicle
   */
  async createVehicle(ctx, vin, model, factoryId) {
    if (!vin || !model || !factoryId) {
      throw new Error('createVehicle requires vin, model, and factoryId');
    }

    const vehicleKey = ctx.stub.createCompositeKey('Vehicle', [vin]);
    const existing = await ctx.stub.getState(vehicleKey);
    if (existing && existing.length > 0) {
      throw new Error(`Vehicle with VIN ${vin} already exists`);
    }

    const vehicle = {
      vin,
      model,
      factoryId,
      owner: factoryId,
      dealerId: null,
      shipment: null,
      status: 'CREATED',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    await ctx.stub.putState(vehicleKey, Buffer.from(JSON.stringify(vehicle)));
    await ctx.stub.setEvent('VehicleCreated', Buffer.from(JSON.stringify(vehicle)));

    return JSON.stringify(vehicle);
  }

  /**
   * Update shipment details for an existing vehicle asset.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   * @param {string} location - Current shipment location
   * @param {string} status - Shipment status description
   */
  async updateShipment(ctx, vin, location, status) {
    if (!vin || !location || !status) {
      throw new Error('updateShipment requires vin, location, and status');
    }

    const vehicle = await this._getVehicle(ctx, vin);
    if (vehicle.status === 'DELIVERED') {
      throw new Error(`Vehicle ${vin} shipment cannot be updated after delivery`);
    }

    vehicle.shipment = {
      location,
      status,
      updatedAt: new Date().toISOString(),
    };
    vehicle.status = 'IN_TRANSIT';
    vehicle.updatedAt = new Date().toISOString();

    await ctx.stub.putState(ctx.stub.createCompositeKey('Vehicle', [vin]), Buffer.from(JSON.stringify(vehicle)));
    await ctx.stub.setEvent('ShipmentUpdated', Buffer.from(JSON.stringify({ vin, location, status })));

    return JSON.stringify(vehicle);
  }

  /**
   * Assign a dealer to the vehicle asset.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   * @param {string} dealerId - Dealer identifier
   */
  async assignDealer(ctx, vin, dealerId) {
    if (!vin || !dealerId) {
      throw new Error('assignDealer requires vin and dealerId');
    }

    const vehicle = await this._getVehicle(ctx, vin);
    if (vehicle.status === 'SOLD') {
      throw new Error(`Vehicle ${vin} has already been sold and cannot be assigned to a dealer`);
    }

    vehicle.dealerId = dealerId;
    vehicle.status = 'ASSIGNED_TO_DEALER';
    vehicle.updatedAt = new Date().toISOString();

    await ctx.stub.putState(ctx.stub.createCompositeKey('Vehicle', [vin]), Buffer.from(JSON.stringify(vehicle)));
    await ctx.stub.setEvent('DealerAssigned', Buffer.from(JSON.stringify({ vin, dealerId })));

    return JSON.stringify(vehicle);
  }

  /**
   * Transfer ownership of the vehicle to a customer.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   * @param {string} customerId - Customer identifier
   */
  async transferOwnership(ctx, vin, customerId) {
    if (!vin || !customerId) {
      throw new Error('transferOwnership requires vin and customerId');
    }

    const vehicle = await this._getVehicle(ctx, vin);
    if (vehicle.status === 'SOLD') {
      throw new Error(`Vehicle ${vin} has already been sold`);
    }

    if (!vehicle.dealerId) {
      throw new Error(`Vehicle ${vin} must be assigned to a dealer before transferring ownership`);
    }

    vehicle.owner = customerId;
    vehicle.status = 'SOLD';
    vehicle.updatedAt = new Date().toISOString();

    await ctx.stub.putState(ctx.stub.createCompositeKey('Vehicle', [vin]), Buffer.from(JSON.stringify(vehicle)));
    await ctx.stub.setEvent('OwnershipTransferred', Buffer.from(JSON.stringify({ vin, customerId })));

    return JSON.stringify(vehicle);
  }

  /**
   * Retrieve a vehicle asset from the ledger by VIN.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   */
  async getVehicle(ctx, vin) {
    if (!vin) {
      throw new Error('getVehicle requires vin');
    }

    const vehicle = await this._getVehicle(ctx, vin);
    return JSON.stringify(vehicle);
  }

  /**
   * Internal helper to fetch a vehicle and validate existence.
   * @param {Context} ctx - Fabric transaction context
   * @param {string} vin - Vehicle Identification Number
   * @returns {Object} vehicle
   */
  async _getVehicle(ctx, vin) {
    const vehicleKey = ctx.stub.createCompositeKey('Vehicle', [vin]);
    const vehicleBytes = await ctx.stub.getState(vehicleKey);
    if (!vehicleBytes || vehicleBytes.length === 0) {
      throw new Error(`Vehicle with VIN ${vin} does not exist`);
    }

    return JSON.parse(vehicleBytes.toString());
  }
}

module.exports = VehicleContract;
