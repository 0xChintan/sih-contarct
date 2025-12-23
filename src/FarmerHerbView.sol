// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FarmerData} from "./FarmerData.sol";
import {HerbProcessing} from "./HerbProcessing.sol";

/**
 * @title FarmerHerbView
 * @notice Read-only aggregator to fetch farmer info plus all linked processing data in a single call
 */
contract FarmerHerbView {
    FarmerData public immutable FARMER_DATA;
    HerbProcessing public immutable HERB_PROCESSING;

    constructor(address _farmerData, address _herbProcessing) {
        FARMER_DATA = FarmerData(_farmerData);
        HERB_PROCESSING = HerbProcessing(_herbProcessing);
    }

    /**
     * @notice Get full farmer profile: farmer info + all processing records + all IPFS hashes
     * @param farmerId 9-digit farmer ID
     * @return farmer FarmerInfo
     * @return processing Array of ProcessingData
     * @return images Array of IPFS hashes (from processing records)
     */
    function getFarmerFullData(
        uint256 farmerId
    )
        external
        view
        returns (
            FarmerData.FarmerInfo memory farmer,
            HerbProcessing.ProcessingData[] memory processing,
            string[] memory images
        )
    {
        farmer = FARMER_DATA.getFarmerData(farmerId);

        uint256[] memory batches = HERB_PROCESSING.getFarmerBatchIds(farmerId);
        processing = new HerbProcessing.ProcessingData[](batches.length);
        images = new string[](batches.length);

        for (uint256 i = 0; i < batches.length; i++) {
            HerbProcessing.ProcessingData memory p = HERB_PROCESSING.getProcessingData(batches[i]);
            processing[i] = p;
            images[i] = p.ipfsHash;
        }
    }
}

