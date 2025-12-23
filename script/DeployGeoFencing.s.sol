// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {GeoFencing} from "../src/GeoFencing.sol";

contract DeployGeoFencing is Script {
    function run() external {
        vm.startBroadcast();
        new GeoFencing();
        vm.stopBroadcast();
    }
}
