# Ayurvedic Herb Processing Smart Contract

A blockchain-based system for storing and managing ayurvedic herb processing data on Hyperledger Besu.

## Features

- **Record Processing Data** - Store processing information with 9-digit numeric batchId and farmerId
- **Query by Batch ID** - Retrieve processing data using uint256 batchId
- **Farmer Views** - List batchIds, processing records, and IPFS hashes per farmer
- **Ownership Transfer** - Owner can transfer contract ownership

## Data Structure

The contract stores processing data keyed by a numeric 9-digit batchId:

```json
{
  "batchId": 123456789,
  "farmerId": 42,
  "processType": "Drying",
  "startTime": 1732000000,
  "endTime": 1732464000,
  "temperature": 45,
  "outputWeight": 10800,
  "ipfsHash": "bafybei...photo-video",
  "remarks": "Shade dried as per AYUSH guidelines",
  "recordedBy": "0x...",
  "recordedAt": 1732000100
}
```

## Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Docker and Docker Compose (for Besu)

### Installation

1. Install Foundry dependencies:
```bash
forge install foundry-rs/forge-std
```

2. Build the project:
```bash
forge build
```

3. Run tests:
```bash
forge test
```

## Deployment to Hyperledger Besu

1. Start Besu:
```bash
docker-compose up -d
```

2. Set your private key:
```bash
export PRIVATE_KEY=your_private_key_here
```

3. Deploy:
```bash
forge script script/DeployProcessing.s.sol:DeployProcessing \
  --rpc-url http://localhost:8545 \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

Or use the deployment script:
```bash
./deploy-processing.sh
```

## Usage

### 1. Record Processing Data

Batch IDs must be 9-digit uint256 values (100000000–999999999). Convert ISO timestamps to Unix timestamps in your frontend, then:

```solidity
herbProcessing.recordProcessingData(
    123456789,              // batchId
    42,                     // farmerId
    "Drying",               // processType
    1732000000,             // startTime (Unix timestamp)
    1732464000,             // endTime (Unix timestamp)
    45,                     // temperature (Celsius)
    10800,                  // outputWeight (grams)
    "bafybei...photo-video",// ipfsHash
    "Shade dried as per AYUSH guidelines" // remarks
);
```

### 2. Get Processing Data by Batch ID

```solidity
HerbProcessing.ProcessingData memory data = herbProcessing.getProcessingData(123456789);
```

### 3. Farmer views
- `getFarmerBatchIds(farmerId)` -> uint256[] batch IDs
- `getFarmerProcessingData(farmerId)` -> ProcessingData[]
- `getFarmerImages(farmerId)` -> string[] ipfs hashes

## Frontend Integration Example

### JavaScript/TypeScript

```javascript
// Convert ISO timestamp to Unix timestamp
function isoToUnix(isoString) {
  return Math.floor(new Date(isoString).getTime() / 1000);
}

// Convert kg to grams
function kgToGrams(kg) {
  return Math.floor(kg * 1000);
}

// Record processing data
async function recordProcessing(data) {
  const tx = await contract.recordProcessingData(
    data.batchId,
    data.processType,
    isoToUnix(data.startTime),  // "2025-11-20T09:00:00Z" -> 1732000000
    isoToUnix(data.endTime),    // "2025-11-25T17:00:00Z" -> 1732464000
    data.temperature,
    kgToGrams(data.outputWeight), // 10.8 -> 10800
    data.ipfsHash,
    data.remarks
  );
  return tx;
}

// Get processing data
async function getProcessingData(batchId) {
  const data = await contract.getProcessingData(batchId);
  
  // Convert back to frontend format
  return {
    batchId: data.batchId,
    processType: data.processType,
    startTime: new Date(data.startTime * 1000).toISOString(),
    endTime: new Date(data.endTime * 1000).toISOString(),
    temperature: data.temperature,
    outputWeight: data.outputWeight / 1000, // grams to kg
    ipfsHash: data.ipfsHash,
    remarks: data.remarks
  };
}
```

## Contract Functions

### Main Functions

- `recordProcessingData(batchId, farmerId, processType, startTime, endTime, temperature, outputWeight, ipfsHash, remarks)` - Record new processing data
- `getProcessingData(batchId)` - Get processing data by uint256 batchId
- `isRecordExists(batchId)` - Check if a record exists
- `getTotalRecords()` - Get total number of records
- `getBatchIdsCount()` - Get count of all batch IDs
- `getBatchIdAtIndex(index)` - Get batch ID at specific index
- `getFarmerBatchIds(farmerId)` - Get batch IDs for a farmer
- `getFarmerProcessingData(farmerId)` - Get processing records for a farmer
- `getFarmerImages(farmerId)` - Get IPFS hashes for a farmer

### Admin Functions

- `transferOwnership(address)` - Transfer contract ownership

## Events

- `ProcessingDataRecorded` - Emitted when new processing data is recorded
- `ProcessingDataUpdated` - Emitted when processing data is updated

## Notes

- **Batch IDs**: Use 9-digit uint256 (100000000–999999999)
- **Farmer IDs**: Must be greater than 0
- **Timestamps**: Store as Unix timestamps (seconds since epoch)
- **Weight**: Store in grams (multiply kg by 1000 if converting from kg)
- **IPFS Hash**: Store the full IPFS hash string
- **Duplicate Prevention**: Each batchId can only be recorded once

## License

MIT
# sih-contarct
