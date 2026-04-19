// Fabric gateway service for the Automotive Supply Chain backend.
// It loads the connection profile and wallet identity before returning contract and gateway objects.

const fs = require('fs');
const path = require('path');
const { Gateway, Wallets } = require('@hyperledger/fabric-gateway');

const connectionProfilePath = path.resolve(__dirname, '..', 'connection.json');
const walletPath = path.resolve(__dirname, '..', 'wallet');
const identityLabel = process.env.FABRIC_USER || 'appUser';
const channelName = process.env.FABRIC_CHANNEL || 'vehicle-channel';
const chaincodeName = process.env.FABRIC_CHAINCODE || 'vehicle-lifecycle';

let gateway;
let contract;

async function loadConnectionProfile() {
  if (!fs.existsSync(connectionProfilePath)) {
    throw new Error(`Connection profile not found at ${connectionProfilePath}`);
  }

  const content = fs.readFileSync(connectionProfilePath, 'utf8');
  return JSON.parse(content);
}

async function getGatewayContract() {
  if (gateway && contract) {
    return { gateway, contract };
  }

  const connectionProfile = await loadConnectionProfile();
  const wallet = await Wallets.newFileSystemWallet(walletPath);
  const identity = await wallet.get(identityLabel);

  if (!identity) {
    throw new Error(`Identity ${identityLabel} not found in wallet at ${walletPath}`);
  }

  gateway = new Gateway();
  await gateway.connect(connectionProfile, {
    wallet,
    identity: identityLabel,
    discovery: {
      enabled: true,
      asLocalhost: true,
    },
  });

  const network = await gateway.getNetwork(channelName);
  contract = network.getContract(chaincodeName);
  return { gateway, contract };
}

async function submitTransaction(fnName, ...args) {
  try {
    const { contract } = await getGatewayContract();
    const result = await contract.submitTransaction(fnName, ...args);
    return result.toString();
  } catch (error) {
    throw new Error(`Fabric submitTransaction error: ${error.message}`);
  }
}

async function evaluateTransaction(fnName, ...args) {
  try {
    const { contract } = await getGatewayContract();
    const result = await contract.evaluateTransaction(fnName, ...args);
    return result.toString();
  } catch (error) {
    throw new Error(`Fabric evaluateTransaction error: ${error.message}`);
  }
}

function disconnect() {
  if (gateway) {
    gateway.disconnect();
    gateway = null;
    contract = null;
  }
}

module.exports = {
  getGatewayContract,
  submitTransaction,
  evaluateTransaction,
  disconnect,
};
