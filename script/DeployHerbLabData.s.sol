// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HerbLabData} from "../src/HerbLabData.sol";

contract DeployHerbLabData is Script {
    function run() public returns (HerbLabData) {
        vm.startBroadcast();

        console.log("Deploying HerbLabData contract...");
        console.log("Deployer address:", msg.sender);

        HerbLabData lab = new HerbLabData();

        console.log("========================================");
        console.log("Deployment Successful!");
        console.log("Contract Address:", address(lab));
        console.log("Owner (deployer):", msg.sender);
        console.log("========================================");

        vm.stopBroadcast();
        return lab;
    }
}





