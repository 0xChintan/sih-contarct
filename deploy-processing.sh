#!/bin/bash

# Herb Processing - Besu Deployment Script
# Simplified contract focused only on processing functionality

set -e

echo "=========================================="
echo "Herb Processing - Besu Deployment"
echo "=========================================="
echo ""

# Check if Besu is running
echo "Checking if Besu is running..."
if ! curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  -H "Content-Type: application/json" http://localhost:8545 > /dev/null 2>&1; then
    echo "❌ Besu is not running on http://localhost:8545"
    echo ""
    echo "Please start Besu first:"
    echo "  docker-compose up -d"
    echo ""
    exit 1
fi

echo "✅ Besu is running"
echo ""

# Check for private key
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY environment variable not set"
    echo ""
    echo "Please set your private key:"
    echo "  export PRIVATE_KEY=your_private_key_here"
    echo ""
    echo "Or run:"
    echo "  PRIVATE_KEY=your_key ./deploy-processing.sh"
    echo ""
    exit 1
fi

# Get account address from private key
ACCOUNT_ADDRESS=$(cast wallet address $PRIVATE_KEY 2>/dev/null || echo "unknown")
echo "Deployer address: $ACCOUNT_ADDRESS"
echo ""

# Check balance
echo "Checking account balance..."
BALANCE=$(cast balance $ACCOUNT_ADDRESS --rpc-url http://localhost:8545 2>/dev/null || echo "0")
echo "Balance: $BALANCE wei"
echo ""

# Deploy contract
echo "=========================================="
echo "Deploying HerbProcessing contract..."
echo "=========================================="
echo ""

forge script script/DeployProcessing.s.sol:DeployProcessing \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Authorize processors: authorizeProcessor(address)"
echo "2. Record processing data: recordProcessingData(...)"
echo "3. Query processing data: getProcessingData(batchId)"
echo ""

