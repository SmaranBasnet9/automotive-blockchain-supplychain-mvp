// Wallet setup helper for loading Fabric user identity into the wallet.
// This script initializes the wallet with an appUser identity from crypto material.

const fs = require('fs');
const path = require('path');
const { Wallets } = require('@hyperledger/fabric-gateway');

const walletPath = path.resolve(__dirname, 'wallet');
const cryptoPath = path.resolve(__dirname, '..', 'blockchain-network', 'crypto-config');
const mspId = process.env.FABRIC_MSP_ID || 'Org1MSP';
const orgName = process.env.FABRIC_ORG || 'org1.example.com';
const userId = process.env.FABRIC_USER || 'appUser';

async function setupWallet() {
  try {
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const identity = await wallet.get(userId);

    if (identity) {
      console.log(`Identity ${userId} already exists in wallet`);
      return;
    }

    const certPath = path.join(
      cryptoPath,
      'peerOrganizations',
      orgName,
      'users',
      `${userId}@${orgName}`,
      'msp',
      'signcerts',
      `${userId}@${orgName}-cert.pem`
    );

    const keyDir = path.join(
      cryptoPath,
      'peerOrganizations',
      orgName,
      'users',
      `${userId}@${orgName}`,
      'msp',
      'keystore'
    );

    if (!fs.existsSync(certPath)) {
      throw new Error(`Certificate not found at ${certPath}`);
    }

    if (!fs.existsSync(keyDir)) {
      throw new Error(`Key directory not found at ${keyDir}`);
    }

    const certificate = fs.readFileSync(certPath, 'utf8');
    const keyFiles = fs.readdirSync(keyDir);

    if (keyFiles.length === 0) {
      throw new Error(`No private key files found in ${keyDir}`);
    }

    const privateKey = fs.readFileSync(path.join(keyDir, keyFiles[0]), 'utf8');

    const newIdentity = {
      credentials: {
        certificate,
        privateKey,
      },
      mspId,
      type: 'X.509',
    };

    await wallet.put(userId, newIdentity);
    console.log(`Successfully added identity ${userId} to wallet at ${walletPath}`);
  } catch (error) {
    console.error('Error setting up wallet:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  setupWallet();
}

module.exports = { setupWallet };
