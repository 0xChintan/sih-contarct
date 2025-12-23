// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HerbProcessing} from "../src/HerbProcessing.sol";

/**
 * @title DeployProcessing
 * @notice Deployment script for HerbProcessing contract
 */
contract DeployProcessing is Script {
    function setUp() public {}

    function run() public returns (HerbProcessing) {
        // Start broadcast - will use private key from --private-key flag
        vm.startBroadcast();

        console.log("Deploying HerbProcessing contract...");
        console.log("Deployer address:", msg.sender);
        
        HerbProcessing herbProcessing = new HerbProcessing();

        console.log("========================================");
        console.log("Deployment Successful!");
        console.log("========================================");
        console.log("Contract Address:", address(herbProcessing));
        console.log("Owner:", herbProcessing.owner());
        console.log("Network: Hyperledger Besu");
        console.log("========================================");

        vm.stopBroadcast();

        return herbProcessing;
    }
}

