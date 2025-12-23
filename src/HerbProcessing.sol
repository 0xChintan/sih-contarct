// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title HerbProcessing
 * @notice Smart contract for storing and managing ayurvedic herb processing data
 * @dev Stores processing data with uint256 batchId (9 digits)
 */
contract HerbProcessing {
    // Events
    event ProcessingDataRecorded(
        uint256 indexed batchId,
        uint256 indexed farmerBatchId,
        address indexed recordedBy,
        string processType,
        uint256 startTime,
        uint256 endTime,
        uint256 outputWeight
    );

    event BatchIdReserved(
        uint256 indexed batchId,
        address indexed reservedBy,
        uint256 reservedAt
    );

    event ProcessingDataUpdated(
        uint256 indexed batchId,
        uint256 indexed farmerBatchId,
        address indexed updatedBy,
        string processType,
        uint256 startTime,
        uint256 endTime,
        uint256 outputWeight
    );

    // Structs
    struct ProcessingData {
        uint256 batchId;           // 9-digit batch ID (e.g., 123456789)
        uint256 farmerBatchId;          // Farmer batch ID
        string processType;         // e.g., "Drying", "    Powdering", "Extraction"
        uint256 startTime;          // Unix timestamp
        uint256 endTime;            // Unix timestamp
        uint256 temperature;        // Temperature in Celsius
        uint256 outputWeight;       // Output weight in grams
        string ipfsHash;            // IPFS hash for photo/video
        string remarks;             // Additional remarks
        address recordedBy;          // Address that recorded the data
        uint256 recordedAt;         // When record was created
        bool exists;                // Record existence flag
    }

    // State variables
    mapping(uint256 => ProcessingData) public processingRecords; // Map by uint256 batchId
    uint256[] public batchIds; // Array to track all batch IDs
    mapping(uint256 => uint256[]) public farmerProcessingBatches; // farmerId => batchIds[]
    
    address public owner;
    uint256 public totalRecords;

    // Constants
    uint256 private constant MAX_BATCH_ID = 999999999; // 9 digits max
    uint256 private constant MIN_BATCH_ID = 100000000; // 9 digits min

    // Modifiers
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner can call this function");
    }

    modifier recordExists(uint256 _batchId) {
        _recordExists(_batchId);
        _;
    }

    function _recordExists(uint256 _batchId) internal view {
        require(processingRecords[_batchId].exists, "Processing record does not exist");
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        totalRecords = 0;
    }

    /**
     * @notice Record processing data for ayurvedic herbs
     * @param _batchId Batch ID as uint256 (9 digits: 100000000 to 999999999)
     * @param _processType Type of processing (e.g., "Drying", "Powdering")
     * @param _startTime Start time as Unix timestamp
     * @param _endTime End time as Unix timestamp
     * @param _temperature Temperature in Celsius
     * @param _outputWeight Output weight in grams
     * @param _ipfsHash IPFS hash for photo/video storage
     * @param _remarks Additional remarks
     */
    function recordProcessingData(
        uint256 _batchId,
        uint256 _farmerId,
        string memory _processType,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _temperature,
        uint256 _outputWeight,
        string memory _ipfsHash,
        string memory _remarks
    ) external {
        require(
            _batchId >= MIN_BATCH_ID && _batchId <= MAX_BATCH_ID,
            "Batch ID must be 9 digits (100000000 to 999999999)"
        );
        require(_farmerId > 0, "Farmer ID must be greater than 0");
        require(bytes(_processType).length > 0, "Process type cannot be empty");
        require(!processingRecords[_batchId].exists, "Batch ID already exists");
        require(_startTime > 0, "Start time must be valid");
        require(_endTime >= _startTime, "End time must be after start time");
        require(_outputWeight > 0, "Output weight must be greater than 0");

        processingRecords[_batchId] = ProcessingData({
            batchId: _batchId,
            farmerBatchId: _farmerId,
            processType: _processType,
            startTime: _startTime,
            endTime: _endTime,
            temperature: _temperature,
            outputWeight: _outputWeight,
            ipfsHash: _ipfsHash,
            remarks: _remarks,
            recordedBy: msg.sender,
            recordedAt: block.timestamp,
            exists: true
        });

        batchIds.push(_batchId);
        farmerProcessingBatches[_farmerId].push(_batchId);
        totalRecords++;

        emit ProcessingDataRecorded(
            _batchId,
            _farmerId,
            msg.sender,
            _processType,
            _startTime,
            _endTime,
            _outputWeight
        );
    }

    /**
     * @notice Reserve a batch ID with an empty record so that details can be added later
     * @param _batchId Batch ID as uint256 (9 digits: 100000000 to 999999999)
     */
    function reserveBatchId(uint256 _batchId) external {
        require(
            _batchId >= MIN_BATCH_ID && _batchId <= MAX_BATCH_ID,
            "Batch ID must be 9 digits (100000000 to 999999999)"
        );
        require(!processingRecords[_batchId].exists, "Batch ID already exists");

        processingRecords[_batchId] = ProcessingData({
            batchId: _batchId,
            farmerBatchId: 0,
            processType: "",
            startTime: 0,
            endTime: 0,
            temperature: 0,
            outputWeight: 0,
            ipfsHash: "",
            remarks: "",
            recordedBy: msg.sender,
            recordedAt: block.timestamp,
            exists: true
        });

        batchIds.push(_batchId);
        totalRecords++;

        emit BatchIdReserved(_batchId, msg.sender, block.timestamp);
    }

    /**
     * @notice Update processing data for an existing (reserved) batch ID
     * @param _batchId Batch ID as uint256
     * @param _farmerId Farmer identifier
     * @param _processType Type of processing (e.g., "Drying", "Powdering")
     * @param _startTime Start time as Unix timestamp
     * @param _endTime End time as Unix timestamp
     * @param _temperature Temperature in Celsius
     * @param _outputWeight Output weight in grams
     * @param _ipfsHash IPFS hash for photo/video storage
     * @param _remarks Additional remarks
     */
    function updateProcessingData(
        uint256 _batchId,
        uint256 _farmerId,
        string memory _processType,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _temperature,
        uint256 _outputWeight,
        string memory _ipfsHash,
        string memory _remarks
    ) external recordExists(_batchId) {
        require(_farmerId > 0, "Farmer ID must be greater than 0");
        require(bytes(_processType).length > 0, "Process type cannot be empty");
        require(_startTime > 0, "Start time must be valid");
        require(_endTime >= _startTime, "End time must be after start time");
        require(_outputWeight > 0, "Output weight must be greater than 0");

        processingRecords[_batchId].farmerBatchId = _farmerId;
        processingRecords[_batchId].processType = _processType;
        processingRecords[_batchId].startTime = _startTime;
        processingRecords[_batchId].endTime = _endTime;
        processingRecords[_batchId].temperature = _temperature;
        processingRecords[_batchId].outputWeight = _outputWeight;
        processingRecords[_batchId].ipfsHash = _ipfsHash;
        processingRecords[_batchId].remarks = _remarks;
        processingRecords[_batchId].recordedBy = msg.sender;
        processingRecords[_batchId].recordedAt = block.timestamp;

        bool alreadyAdded = false;
        uint256[] storage batches = farmerProcessingBatches[_farmerId];
        for (uint256 i = 0; i < batches.length; i++) {
            if (batches[i] == _batchId) {
                alreadyAdded = true;
                break;
            }
        }
        if (!alreadyAdded) {
            batches.push(_batchId);
        }

        emit ProcessingDataUpdated(
            _batchId,
            _farmerId,
            msg.sender,
            _processType,
            _startTime,
            _endTime,
            _outputWeight
        );
    }

    /**
     * @notice Get processing data by batch ID
     * @param _batchId Batch ID as uint256
     * @return ProcessingData struct with all processing information
     */
    function getProcessingData(
        uint256 _batchId
    ) external view recordExists(_batchId) returns (ProcessingData memory) {
        return processingRecords[_batchId];
    }

    /**
     * @notice Check if a processing record exists
     * @param _batchId Batch ID as uint256
     * @return true if record exists, false otherwise
     */
    function isRecordExists(uint256 _batchId) external view returns (bool) {
        return processingRecords[_batchId].exists;
    }

    /**
     * @notice Get total number of processing records
     * @return Total number of processing records
     */
    function getTotalRecords() external view returns (uint256) {
        return totalRecords;
    }

    /**
     * @notice Get batch ID at index
     * @param _index Index in the batchIds array
     * @return Batch ID as uint256
     */
    function getBatchIdAtIndex(uint256 _index) external view returns (uint256) {
        require(_index < batchIds.length, "Index out of bounds");
        return batchIds[_index];
    }

    /**
     * @notice Get all batch IDs count
     * @return Total number of batch IDs
     */
    function getBatchIdsCount() external view returns (uint256) {
        return batchIds.length;
    }

    /**
     * @notice Get all batch IDs for a farmer
     * @param _farmerId Farmer ID as uint256
     * @return Array of batch IDs
     */
    function getFarmerBatchIds(uint256 _farmerId) external view returns (uint256[] memory) {
        return farmerProcessingBatches[_farmerId];
    }

    /**
     * @notice Get all processing data for a farmer
     * @param _farmerId Farmer ID as uint256
     * @return Array of ProcessingData
     */
    function getFarmerProcessingData(uint256 _farmerId) external view returns (ProcessingData[] memory) {
        uint256[] memory batches = farmerProcessingBatches[_farmerId];
        ProcessingData[] memory data = new ProcessingData[](batches.length);
        for (uint256 i = 0; i < batches.length; i++) {
            data[i] = processingRecords[batches[i]];
        }
        return data;
    }

    /**
     * @notice Get all IPFS hashes/images for a farmer
     * @param _farmerId Farmer ID as uint256
     * @return Array of IPFS hashes (strings)
     */
    function getFarmerImages(uint256 _farmerId) external view returns (string[] memory) {
        uint256[] memory batches = farmerProcessingBatches[_farmerId];
        string[] memory hashes = new string[](batches.length);
        for (uint256 i = 0; i < batches.length; i++) {
            hashes[i] = processingRecords[batches[i]].ipfsHash;
        }
        return hashes;
    }

    /**
     * @notice Transfer ownership of the contract
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
}
