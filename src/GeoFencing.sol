// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract GeoFencing {
    // Struct to represent a geographic zone
    struct GeoZone {
        string name;
        int256 minLatitude; // Latitude * 1e6 (to handle decimals)
        int256 maxLatitude;
        int256 minLongitude; // Longitude * 1e6
        int256 maxLongitude;
        bool isActive;
    }

    // Struct to store herb details
    struct HerbRecord {
        uint256 recordId;
        string herbName;
        string scientificName;
        int256 latitude;
        int256 longitude;
        uint256 quantity; // in grams or kg
        uint256 timestamp;
        address submittedBy;
        string imageHash; // IPFS hash or additional metadata
    }

    // State variables
    address private governmentAuthority;
    uint256 public recordCounter;

    // Mapping to store registered geo zones
    mapping(uint256 => GeoZone) private registeredZones;
    uint256 public zoneCounter;

    // Mapping to store herb records
    mapping(uint256 => HerbRecord) private herbRecords;

    // Events
    event ZoneRegistered(
        uint256 indexed zoneId,
        int256 minLat,
        int256 maxLat,
        int256 minLon,
        int256 maxLon
    );
    event ZoneUpdated(uint256 indexed zoneId, bool isActive);
    event HerbRecordAdded(
        uint256 indexed recordId,
        string herbName,
        int256 latitude,
        int256 longitude,
        address submittedBy
    );
    event AuthorityTransferred(
        address indexed oldAuthority,
        address indexed newAuthority
    );

    // Errors
    error UnauthorizedAccess();
    error InvalidCoordinates();
    error LocationOutOfBounds();
    error InvalidZoneId();
    error EmptyHerbName();

    // Modifiers
    modifier onlyGovernmentAuthority() {
        _onlyGovernmentAuthority();
        _;
    }

    function _onlyGovernmentAuthority() internal view {
        if (msg.sender != governmentAuthority) revert UnauthorizedAccess();
    }

    function getGovernmentAuthority() external view returns (address) {
        return governmentAuthority;
    }

    /**
     * @dev Constructor sets the government authority
     */
    constructor() {
        governmentAuthority = msg.sender;
        recordCounter = 0;
        zoneCounter = 0;
    }

    /**
     * @dev Register a new geographic zone (Private - Only Government Authority)
     * @param _minLatitude Minimum latitude * 1e6
     * @param _maxLatitude Maximum latitude * 1e6
     * @param _minLongitude Minimum longitude * 1e6
     * @param _maxLongitude Maximum longitude * 1e6
     */
    function registerNewGeoZone(
        string memory _name,
        int256 _minLatitude,
        int256 _maxLatitude,
        int256 _minLongitude,
        int256 _maxLongitude
    ) external onlyGovernmentAuthority returns (uint256) {
        if (_minLatitude >= _maxLatitude || _minLongitude >= _maxLongitude) {
            revert InvalidCoordinates();
        }

        zoneCounter++;
        registeredZones[zoneCounter] = GeoZone({
            name: _name,
            minLatitude: _minLatitude,
            maxLatitude: _maxLatitude,
            minLongitude: _minLongitude,
            maxLongitude: _maxLongitude,
            isActive: true
        });

        emit ZoneRegistered(
            zoneCounter,
            _minLatitude,
            _maxLatitude,
            _minLongitude,
            _maxLongitude
        );
        return zoneCounter;
    }

    /**
     * @dev Update an existing zone's status (Private - Only Government Authority)
     * @param _zoneId Zone ID to update
     * @param _isActive New active status
     */
    function updateGeoZone(uint256 _zoneId, bool _isActive) external onlyGovernmentAuthority {
        if (_zoneId == 0 || _zoneId > zoneCounter) revert InvalidZoneId();

        registeredZones[_zoneId].isActive = _isActive;
        emit ZoneUpdated(_zoneId, _isActive);
    }

    /**
     * @dev Update zone coordinates (Private - Only Government Authority)
     * @param _zoneId Zone ID to update
     * @param _minLatitude New minimum latitude
     * @param _maxLatitude New maximum latitude
     * @param _minLongitude New minimum longitude
     * @param _maxLongitude New maximum longitude
     */
    function updateZoneCoordinates(
        uint256 _zoneId,
        int256 _minLatitude,
        int256 _maxLatitude,
        int256 _minLongitude,
        int256 _maxLongitude
    ) external onlyGovernmentAuthority {
        if (_zoneId == 0 || _zoneId > zoneCounter) revert InvalidZoneId();
        if (_minLatitude >= _maxLatitude || _minLongitude >= _maxLongitude) {
            revert InvalidCoordinates();
        }

        GeoZone storage zone = registeredZones[_zoneId];
        zone.minLatitude = _minLatitude;
        zone.maxLatitude = _maxLatitude;
        zone.minLongitude = _minLongitude;
        zone.maxLongitude = _maxLongitude;

        emit ZoneRegistered(
            _zoneId,
            _minLatitude,
            _maxLatitude,
            _minLongitude,
            _maxLongitude
        );
    }

    /**
     * @dev Check if coordinates are within any registered zone
     * @param _latitude Latitude * 1e6
     * @param _longitude Longitude * 1e6
     * @return isValid True if coordinates are in a registered zone
     * @return zoneId The zone ID where coordinates are found
     */
    function validateLocation(
        int256 _latitude,
        int256 _longitude
    ) public view returns (bool isValid, uint256 zoneId) {
        for (uint256 i = 1; i <= zoneCounter; i++) {
            GeoZone memory zone = registeredZones[i];

            if (!zone.isActive) continue;

            if (
                _latitude >= zone.minLatitude &&
                _latitude <= zone.maxLatitude &&
                _longitude >= zone.minLongitude &&
                _longitude <= zone.maxLongitude
            ) {
                return (true, i);
            }
        }

        return (false, 0);
    }

    /**
     * @dev Submit herb record with location validation
     * @param _latitude Latitude * 1e6
     * @param _longitude Longitude * 1e6
     * @param _herbName Name of the herb
     * @param _scientificName Scientific name
     * @param _quantity Quantity in grams
     * @param _imageHash Additional metadata or IPFS hash
     * @return recordId The ID of the created record
     */
    function submitHerbRecord(
        int256 _latitude,
        int256 _longitude,
        string memory _herbName,
        string memory _scientificName,
        uint256 _quantity,
        string memory _imageHash
    ) external returns (uint256) {
        if (bytes(_herbName).length == 0) revert EmptyHerbName();

        // Validate location
        (bool isValid, ) = validateLocation(_latitude, _longitude);
        if (!isValid) revert LocationOutOfBounds();

        // Create new record
        recordCounter++;
        herbRecords[recordCounter] = HerbRecord({
            recordId: recordCounter,
            herbName: _herbName,
            scientificName: _scientificName,
            latitude: _latitude,
            longitude: _longitude,
            quantity: _quantity,
            timestamp: block.timestamp,
            submittedBy: msg.sender,
            imageHash: _imageHash
        });

        emit HerbRecordAdded(
            recordCounter,
            _herbName,
            _latitude,
            _longitude,
            msg.sender
        );
        return recordCounter;
    }

    /**
     * @dev Get herb record details
     * @param _recordId Record ID to retrieve
     */
    function getHerbRecord(uint256 _recordId) external view returns (HerbRecord memory) {
        return herbRecords[_recordId];
    }

    /**
     * @dev Get zone details
     * @param _zoneId Zone ID to retrieve
     */
    function getGeoZone(uint256 _zoneId) external view returns (GeoZone memory) {
        return registeredZones[_zoneId];
    }

    /**
     * @dev Transfer government authority (Private - Only Government Authority)
     * @param _newAuthority Address of new authority
     */
    function transferAuthority(address _newAuthority) external onlyGovernmentAuthority {
        require(_newAuthority != address(0), "Invalid address");
        address oldAuthority = governmentAuthority;
        governmentAuthority = _newAuthority;
        emit AuthorityTransferred(oldAuthority, _newAuthority);
    }

    /**
     * @dev Get total number of zones
     */
    function getTotalZones() external view returns (uint256) {
        return zoneCounter;
    }

    /**
     * @dev Get total number of herb records
     */
    function getTotalRecords() external view returns (uint256) {
        return recordCounter;
    }
}
