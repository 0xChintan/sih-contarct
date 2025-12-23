// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title FarmerData
 * @notice Smart contract for storing and managing farmer data
 * @dev Stores farmer information with uint256 farmerId (9 digits)
 */
contract FarmerData {
    // Events
    event FarmerDataRecorded(
        uint256 indexed farmerId,
        address indexed recordedBy,
        string farmerName,
        string location,
        uint256 registeredAt
    );

    // Structs
    struct FarmerInfo {
        uint256 farmerId;           // 9-digit farmer ID (e.g., 123456789)
        string farmerName;          // Name of the farmer
        string location;            // Location/Address
        string contactNumber;       // Contact number
        string farmArea;            // Farm area details
        string cropsGrown;          // Crops grown by farmer
        string certification;       // Certifications (if any)
        string ipfsHash;            // IPFS hash for documents/photos
        string remarks;             // Additional remarks
        address recordedBy;         // Address that recorded the data
        uint256 registeredAt;       // Registration timestamp
        bool exists;                // Record existence flag
    }

    // State variables
    mapping(uint256 => FarmerInfo) public farmerRecords; // Map by uint256 farmerId
    uint256[] public farmerIds; // Array to track all farmer IDs
    
    address public owner;
    uint256 public totalFarmers;

    // Constants
    uint256 private constant MAX_FARMER_ID = 999999999; // 9 digits max
    uint256 private constant MIN_FARMER_ID = 100000000; // 9 digits min

    // Modifiers
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner can call this function");
    }

    modifier farmerExists(uint256 _farmerId) {
        _farmerExists(_farmerId);
        _;
    }

    function _farmerExists(uint256 _farmerId) internal view {
        require(farmerRecords[_farmerId].exists, "Farmer record does not exist");
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        totalFarmers = 0;
    }

    /**
     * @notice Record farmer data
     * @param _farmerId Farmer ID as uint256 (9 digits: 100000000 to 999999999)
     * @param _farmerName Name of the farmer
     * @param _location Location/Address of the farmer
     * @param _contactNumber Contact number
     * @param _farmArea Farm area details
     * @param _cropsGrown Crops grown by farmer
     * @param _certification Certifications (if any)
     * @param _ipfsHash IPFS hash for documents/photos
     * @param _remarks Additional remarks
     */
    function recordFarmerData(
        uint256 _farmerId,
        string memory _farmerName,
        string memory _location,
        string memory _contactNumber,
        string memory _farmArea,
        string memory _cropsGrown,
        string memory _certification,
        string memory _ipfsHash,
        string memory _remarks
    ) external {
        require(
            _farmerId >= MIN_FARMER_ID && _farmerId <= MAX_FARMER_ID,
            "Farmer ID must be 9 digits (100000000 to 999999999)"
        );
        require(bytes(_farmerName).length > 0, "Farmer name cannot be empty");
        require(!farmerRecords[_farmerId].exists, "Farmer ID already exists");

        farmerRecords[_farmerId] = FarmerInfo({
            farmerId: _farmerId,
            farmerName: _farmerName,
            location: _location,
            contactNumber: _contactNumber,
            farmArea: _farmArea,
            cropsGrown: _cropsGrown,
            certification: _certification,
            ipfsHash: _ipfsHash,
            remarks: _remarks,
            recordedBy: msg.sender,
            registeredAt: block.timestamp,
            exists: true
        });

        farmerIds.push(_farmerId);
        totalFarmers++;

        emit FarmerDataRecorded(
            _farmerId,
            msg.sender,
            _farmerName,
            _location,
            block.timestamp
        );
    }

    /**
     * @notice Get farmer data by farmer ID
     * @param _farmerId Farmer ID as uint256
     * @return FarmerInfo struct with all farmer information
     */
    function getFarmerData(
        uint256 _farmerId
    ) external view farmerExists(_farmerId) returns (FarmerInfo memory) {
        return farmerRecords[_farmerId];
    }

    /**
     * @notice Check if a farmer record exists
     * @param _farmerId Farmer ID as uint256
     * @return true if record exists, false otherwise
     */
    function isFarmerExists(uint256 _farmerId) external view returns (bool) {
        return farmerRecords[_farmerId].exists;
    }

    /**
     * @notice Get total number of farmer records
     * @return Total number of farmers
     */
    function getTotalFarmers() external view returns (uint256) {
        return totalFarmers;
    }

    /**
     * @notice Get farmer ID at index
     * @param _index Index in the farmerIds array
     * @return Farmer ID as uint256
     */
    function getFarmerIdAtIndex(uint256 _index) external view returns (uint256) {
        require(_index < farmerIds.length, "Index out of bounds");
        return farmerIds[_index];
    }

    /**
     * @notice Get all farmer IDs count
     * @return Total number of farmer IDs
     */
    function getFarmerIdsCount() external view returns (uint256) {
        return farmerIds.length;
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