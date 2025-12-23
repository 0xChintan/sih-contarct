// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {HerbProcessing} from "../src/HerbProcessing.sol";

contract HerbProcessingTest is Test {
    HerbProcessing public herbProcessing;
    
    address public owner;
    address public user;
    uint256 public farmerId;
    
    function setUp() public {
        owner = address(this);
        user = address(0x1);
        farmerId = 123456789; // 9-digit farmer ID
        
        // Set a base timestamp
        vm.warp(1732000000); // Nov 20, 2024
        
        herbProcessing = new HerbProcessing();
    }
    
    function testRecordProcessingData() public {
        uint256 batchId = 223456789; // 9-digit batch ID
        uint256 startTime = 1732000000; // Nov 20, 2024 09:00:00
        uint256 endTime = 1732464000;   // Nov 25, 2024 17:00:00
        
        herbProcessing.recordProcessingData(
            batchId,
            farmerId,
            "Drying",
            startTime,
            endTime,
            45,      // temperature
            10800,   // outputWeight in grams (10.8 kg * 1000)
            "bafybei...photo-video",
            "Shade dried as per AYUSH guidelines"
        );
        
        assertEq(herbProcessing.totalRecords(), 1);
        assertTrue(herbProcessing.isRecordExists(batchId));
        
        HerbProcessing.ProcessingData memory data = herbProcessing.getProcessingData(batchId);
        assertEq(data.batchId, batchId);
        assertEq(data.farmerBatchId, farmerId);
        assertEq(data.processType, "Drying");
        assertEq(data.startTime, startTime);
        assertEq(data.endTime, endTime);
        assertEq(data.temperature, 45);
        assertEq(data.outputWeight, 10800);
        assertEq(data.recordedBy, address(this));
    }
    
    
    function testAnyUserCanRecord() public {
        uint256 batchId = 345678901; // 9-digit batch ID
        
        vm.prank(user);
        herbProcessing.recordProcessingData(
            batchId,
            farmerId,
            "Extraction",
            1732000000,
            1732464000,
            50,
            8000,
            "ipfs-hash",
            "Test"
        );
        
        assertTrue(herbProcessing.isRecordExists(batchId));
        HerbProcessing.ProcessingData memory data = herbProcessing.getProcessingData(batchId);
        assertEq(data.recordedBy, user);
        assertEq(data.farmerBatchId, farmerId);
    }
    
    function testMultipleRecords() public {
        herbProcessing.recordProcessingData(
            456789012,
            farmerId,
            "Powdering",
            1732000000,
            1732464000,
            35,
            15000,
            "ipfs-hash-1",
            "First batch"
        );
        
        herbProcessing.recordProcessingData(
            567890123,
            farmerId,
            "Grinding",
            1732000000,
            1732464000,
            38,
            12000,
            "ipfs-hash-2",
            "Second batch"
        );
        
        assertEq(herbProcessing.totalRecords(), 2);
        assertEq(herbProcessing.getBatchIdsCount(), 2);

        uint256[] memory batches = herbProcessing.getFarmerBatchIds(farmerId);
        assertEq(batches.length, 2);
    }
    
    function testGetBatchIdAtIndex() public {
        uint256 batchId1 = 678901234;
        uint256 batchId2 = 789012345;
        
        herbProcessing.recordProcessingData(
            batchId1,
            farmerId,
            "Drying",
            1732000000,
            1732464000,
            45,
            10000,
            "hash1",
            "First"
        );
        
        herbProcessing.recordProcessingData(
            batchId2,
            farmerId,
            "Powdering",
            1732000000,
            1732464000,
            40,
            12000,
            "hash2",
            "Second"
        );
        
        assertEq(herbProcessing.getBatchIdAtIndex(0), batchId1);
        assertEq(herbProcessing.getBatchIdAtIndex(1), batchId2);

        uint256[] memory batches = herbProcessing.getFarmerBatchIds(farmerId);
        assertEq(batches.length, 2);
        assertEq(batches[0], batchId1);
        assertEq(batches[1], batchId2);
    }
    
    function testDuplicateBatchId() public {
        uint256 batchId = 890123456;
        
        herbProcessing.recordProcessingData(
            batchId,
            farmerId,
            "Drying",
            1732000000,
            1732464000,
            45,
            10000,
            "hash1",
            "First"
        );
        
        vm.expectRevert("Batch ID already exists");
        herbProcessing.recordProcessingData(
            batchId,
            farmerId,
            "Powdering",
            1732000000,
            1732464000,
            40,
            12000,
            "hash2",
            "Second"
        );
    }
    
    function testInvalidBatchId() public {
        // Test batch ID less than 9 digits
        vm.expectRevert("Batch ID must be 9 digits (100000000 to 999999999)");
        herbProcessing.recordProcessingData(
            12345678, // 8 digits
            farmerId,
            "Drying",
            1732000000,
            1732464000,
            45,
            10000,
            "hash1",
            "Test"
        );
        
        // Test batch ID more than 9 digits
        vm.expectRevert("Batch ID must be 9 digits (100000000 to 999999999)");
        herbProcessing.recordProcessingData(
            1234567890, // 10 digits
            farmerId,
            "Drying",
            1732000000,
            1732464000,
            45,
            10000,
            "hash1",
            "Test"
        );
    }
}
