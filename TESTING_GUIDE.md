# Testing Guide - Herb Processing Contract

Complete guide for testing write and read functionality of the HerbProcessing contract on Hyperledger Besu.

## Contract Information

- **Contract Address**: `0x2467636bea0f3c2441227eedbffac59f11d54a80`
- **Network**: Hyperledger Besu (Chain ID: 1337)
- **RPC URL**: `http://localhost:8545`
- **Deployer Address**: `0x627306090abaB3A6e1400e9345bC60c78a8BEf57`

## Prerequisites

1. Besu node running on `http://localhost:8545`
2. Foundry installed
3. Contract deployed
4. Private key with ETH balance

## Setup Test Account

```bash
# Use one of the pre-funded accounts from genesis.json
export PRIVATE_KEY=c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
export CONTRACT_ADDRESS=0x2467636bea0f3c2441227eedbffac59f11d54a80
export PROCESSOR_ADDRESS=0x627306090abaB3A6e1400e9345bC60c78a8BEf57
```

## Step 1: Authorize a Processor

Before recording data, you need to authorize a processor address.

```bash
cast send $CONTRACT_ADDRESS \
  "authorizeProcessor(address)" \
  $PROCESSOR_ADDRESS \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy
```

**Expected Output**: Transaction hash

**Verify Authorization**:
```bash
cast call $CONTRACT_ADDRESS \
  "authorizedProcessors(address)(bool)" \
  $PROCESSOR_ADDRESS \
  --rpc-url http://localhost:8545
```

Should return: `true`

## Step 2: Record Processing Data (Write)

Record processing data for a batch. Convert ISO timestamps to Unix timestamps and kg to grams.

### Example Data:
```json
{
  "batchId": "ASH-RAJ-20251115-007",
  "processType": "Drying",
  "startTime": "2025-11-20T09:00:00Z",  // Convert to Unix: 1732000000
  "endTime": "2025-11-25T17:00:00Z",    // Convert to Unix: 1732464000
  "temperature": 45,
  "outputWeight": 10.8,                 // Convert to grams: 10800
  "ipfsHash": "bafybeiabc123...",
  "remarks": "Shade dried as per AYUSH guidelines"
}
```

### Command:
```bash
cast send $CONTRACT_ADDRESS \
  "recordProcessingData(string,string,uint256,uint256,uint256,uint256,string,string)" \
  "ASH-RAJ-20251115-007" \
  "Drying" \
  1732000000 \
  1732464000 \
  45 \
  10800 \
  "bafybeiabc123photo-video" \
  "Shade dried as per AYUSH guidelines" \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy
```

### More Examples:

**Example 2: Powdering Process**
```bash
cast send $CONTRACT_ADDRESS \
  "recordProcessingData(string,string,uint256,uint256,uint256,uint256,string,string)" \
  "TULSI-2025-001" \
  "Powdering" \
  1732000000 \
  1732464000 \
  40 \
  5000 \
  "bafybeipowder123" \
  "Fine powder as per standards" \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy
```                            

**Example 3: Extraction Process**
```bash
cast send $CONTRACT_ADDRESS \
  "recordProcessingData(string,string,uint256,uint256,uint256,uint256,string,string)" \
  "NEEM-2025-002" \
  "Extraction" \
  1732000000 \
  1732464000 \
  50 \
  8000 \
  "bafybeiextract456" \
  "Cold extraction method" \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy
```

## Step 3: Read Processing Data

### Get Processing Data by Batch ID

```bash
cast call $CONTRACT_ADDRESS \
  "getProcessingData(string)" \
  "ASH-RAJ-20251115-007" \
  --rpc-url http://localhost:8545
```

**Expected Output** (decoded):
```
0: string: batchId = ASH-RAJ-20251115-007
1: string: processType = Drying
2: uint256: startTime = 1732000000
3: uint256: endTime = 1732464000
4: uint256: temperature = 45
5: uint256: outputWeight = 10800
6: string: ipfsHash = bafybeiabc123photo-video
7: string: remarks = Shade dried as per AYUSH guidelines
8: address: processor = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57
9: uint256: recordedAt = [timestamp]
10: bool: exists = true
```

### Check if Record Exists

```bash
cast call $CONTRACT_ADDRESS \
  "isRecordExists(string)(bool)" \
  "ASH-RAJ-20251115-007" \
  --rpc-url http://localhost:8545
```

Should return: `true`

### Get Total Records Count

```bash
cast call $CONTRACT_ADDRESS \
  "getTotalRecords()(uint256)" \
  --rpc-url http://localhost:8545
```

### Get Batch ID at Index

```bash
cast call $CONTRACT_ADDRESS \
  "getBatchIdAtIndex(uint256)(string)" \
  0 \
  --rpc-url http://localhost:8545
```

### Get Total Batch IDs Count

```bash
cast call $CONTRACT_ADDRESS \
  "getBatchIdsCount()(uint256)" \
  --rpc-url http://localhost:8545
```

## Step 4: Update Processing Data

Update existing processing data (only by the processor who created it or owner).

```bash
cast send $CONTRACT_ADDRESS \
  "updateProcessingData(string,string,uint256,uint256,uint256,uint256,string,string)" \
  "ASH-RAJ-20251115-007" \
  "Drying and Grinding" \
  1732000000 \
  1732464000 \
  42 \
  10500 \
  "bafybeiupdated123" \
  "Updated after quality check" \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy
```

## Step 5: Read Public Mappings

### Read Processing Record (Public Mapping)

```bash
cast call $CONTRACT_ADDRESS \
  "processingRecords(string)(string,string,uint256,uint256,uint256,uint256,string,string,address,uint256,bool)" \
  "ASH-RAJ-20251115-007" \
  --rpc-url http://localhost:8545
```

### Read Owner

```bash
cast call $CONTRACT_ADDRESS \
  "owner()(address)" \
  --rpc-url http://localhost:8545
```

## Complete Test Workflow

```bash
#!/bin/bash

# Setup
export PRIVATE_KEY=c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3
export CONTRACT_ADDRESS=0x2467636bea0f3c2441227eedbffac59f11d54a80
export PROCESSOR_ADDRESS=0x627306090abaB3A6e1400e9345bC60c78a8BEf57

# 1. Authorize processor
echo "Step 1: Authorizing processor..."
cast send $CONTRACT_ADDRESS \
  "authorizeProcessor(address)" \
  $PROCESSOR_ADDRESS \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy

# 2. Record processing data
echo "Step 2: Recording processing data..."
cast send $CONTRACT_ADDRESS \
  "recordProcessingData(string,string,uint256,uint256,uint256,uint256,string,string)" \
  "ASH-RAJ-20251115-007" \
  "Drying" \
  1732000000 \
  1732464000 \
  45 \
  10800 \
  "bafybeiabc123" \
  "Shade dried as per AYUSH guidelines" \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --legacy

# 3. Read processing data
echo "Step 3: Reading processing data..."
cast call $CONTRACT_ADDRESS \
  "getProcessingData(string)" \
  "ASH-RAJ-20251115-007" \
  --rpc-url http://localhost:8545

# 4. Check total records
echo "Step 4: Checking total records..."
cast call $CONTRACT_ADDRESS \
  "getTotalRecords()(uint256)" \
  --rpc-url http://localhost:8545

echo "Test complete!"
```

## Helper Functions

### Convert ISO to Unix Timestamp

**JavaScript:**
```javascript
function isoToUnix(isoString) {
  return Math.floor(new Date(isoString).getTime() / 1000);
}

// Example
isoToUnix("2025-11-20T09:00:00Z") // Returns: 1732000000
```

**Python:**
```python
from datetime import datetime

def iso_to_unix(iso_string):
    dt = datetime.fromisoformat(iso_string.replace('Z', '+00:00'))
    return int(dt.timestamp())

# Example
iso_to_unix("2025-11-20T09:00:00Z")  # Returns: 1732000000
```

### Convert kg to grams

```bash
# kg * 1000 = grams
# 10.8 kg = 10800 grams
```

## Testing with Foundry Script

Create a test script `script/TestProcessing.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HerbProcessing} from "../src/HerbProcessing.sol";

contract TestProcessing is Script {
    function run() public {
        HerbProcessing processing = HerbProcessing(0x2467636bea0f3c2441227eedbffac59f11d54a80);
        
        vm.startBroadcast();
        
        // Authorize processor
        processing.authorizeProcessor(0x627306090abaB3A6e1400e9345bC60c78a8BEf57);
        
        // Record data
        processing.recordProcessingData(
            "TEST-001",
            "Drying",
            1732000000,
            1732464000,
            45,
            10800,
            "ipfs-hash-123",
            "Test batch"
        );
        
        // Read data
        HerbProcessing.ProcessingData memory data = processing.getProcessingData("TEST-001");
        console.log("Batch ID:", data.batchId);
        console.log("Process Type:", data.processType);
        console.log("Output Weight:", data.outputWeight);
        
        vm.stopBroadcast();
    }
}
```

Run the script:
```bash
forge script script/TestProcessing.s.sol:TestProcessing \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

## Troubleshooting

### Error: "Not authorized processor"
- Make sure you authorized the processor address first
- Check that you're using the correct private key

### Error: "Batch ID already exists"
- Each batchId can only be recorded once
- Use a different batchId or update the existing record

### Error: "Transaction Failure"
- Check if Besu is running
- Verify account has enough balance
- Check gas limits

### Reading Returns Empty
- Make sure the transaction was successful
- Wait for block confirmation
- Verify the batchId is correct (case-sensitive)

## Quick Reference

| Operation | Command Type | Function |
|-----------|-------------|----------|
| Authorize Processor | Write | `authorizeProcessor(address)` |
| Record Data | Write | `recordProcessingData(...)` |
| Update Data | Write | `updateProcessingData(...)` |
| Get Data | Read | `getProcessingData(string)` |
| Check Exists | Read | `isRecordExists(string)` |
| Total Records | Read | `getTotalRecords()` |
| Get Batch ID | Read | `getBatchIdAtIndex(uint256)` |

## Notes

- All timestamps must be Unix timestamps (seconds since epoch)
- Weight is stored in grams (multiply kg by 1000)
- Batch IDs are case-sensitive strings
- Only authorized processors can record/update data
- Owner can authorize/revoke processors

