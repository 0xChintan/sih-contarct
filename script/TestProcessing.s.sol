// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HerbProcessing} from "../src/HerbProcessing.sol";

/**
 * @title TestProcessing
 * @notice Test script for write and read operations on HerbProcessing contract
 */
contract TestProcessing is Script {
    // Latest deployed contract address
    address constant CONTRACT_ADDRESS = 0x2467636BEa0F3c2441227eeDBfFaC59f11D54a80;
    uint256 constant FARMER_ID = 123456789;

    function run() public {
        HerbProcessing processing = HerbProcessing(CONTRACT_ADDRESS);
        
        vm.startBroadcast();

        console.log("========================================");
        console.log("Testing HerbProcessing Contract");
        console.log("========================================");
        console.log("Contract Address:", CONTRACT_ADDRESS);
        console.log("");

        // Step 1: Record processing data (no authorization needed)
        console.log("Step 1: Recording processing data...");
        uint256 batchId1 = 123456789; // 9-digit batch ID
        processing.recordProcessingData(
            batchId1,
            FARMER_ID,
            "Drying",
            1732000000,  // 2025-11-20T09:00:00Z
            1732464000,  // 2025-11-25T17:00:00Z
            45,          // temperature
            10800,       // outputWeight in grams (10.8 kg)
            "bafybeiabc123photo-video",
            "Shade dried as per AYUSH guidelines"
        );
        console.log("Recorded batch:", batchId1);
        console.log("");

        // Step 2: Record another batch
        console.log("Step 2: Recording second batch...");
        uint256 batchId2 = 234567890; // 9-digit batch ID
        processing.recordProcessingData(
            batchId2,
            FARMER_ID,
            "Powdering",
            1732000000,
            1732464000,
            40,
            5000,
            "bafybeipowder123",
            "Fine powder as per standards"
        );
        console.log("Recorded batch:", batchId2);
        console.log("");

        // Step 3: Read processing data
        console.log("Step 3: Reading processing data...");
        HerbProcessing.ProcessingData memory data1 = processing.getProcessingData(batchId1);
        console.log("Batch ID:", data1.batchId);
        console.log("Process Type:", data1.processType);
        console.log("Start Time:", data1.startTime);
        console.log("End Time:", data1.endTime);
        console.log("Temperature:", data1.temperature);
        console.log("Output Weight (grams):", data1.outputWeight);
        console.log("IPFS Hash:", data1.ipfsHash);
        console.log("Remarks:", data1.remarks);
        console.log("Recorded By:", data1.recordedBy);
        console.log("");

        // Step 4: Check total records
        console.log("Step 4: Checking total records...");
        uint256 total = processing.getTotalRecords();
        console.log("Total Records:", total);
        console.log("");

        // Step 5: Check if record exists
        console.log("Step 5: Checking if record exists...");
        bool exists = processing.isRecordExists(batchId1);
        console.log("Record exists:", exists);
        console.log("");

        // Step 6: Get batch IDs count
        console.log("Step 6: Getting batch IDs count...");
        uint256 count = processing.getBatchIdsCount();
        console.log("Batch IDs Count:", count);
        console.log("");

        // Step 7: Get batch ID at index
        console.log("Step 7: Getting batch ID at index 0...");
        uint256 batchIdAtIndex = processing.getBatchIdAtIndex(0);
        console.log("Batch ID at index 0:", batchIdAtIndex);
        console.log("");

        console.log("========================================");
        console.log("All tests completed successfully!");
        console.log("========================================");

        vm.stopBroadcast();
    }
}
