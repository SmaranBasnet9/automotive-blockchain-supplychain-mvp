# PowerShell scaffold script for starting the Fabric network.
# This script shows the commands needed to generate crypto material and channel artifacts.

Write-Host "This script provides example commands for bootstrapping the Fabric network."

Write-Host "1) Generate certificates with cryptogen:"
Write-Host "   cryptogen generate --config=./crypto-config.yaml --output=./crypto-config"

Write-Host "2) Create genesis block with configtxgen:"
Write-Host "   configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block"

Write-Host "3) Create channel transaction file:"
Write-Host "   configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel"

Write-Host "4) Start the network:"
Write-Host "   docker-compose -f docker-compose.yaml up -d"

Write-Host "After that, use the CLI container to create the channel and install chaincode."
