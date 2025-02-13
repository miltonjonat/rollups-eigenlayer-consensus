// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EigenLayerConsensus} from "../src/EigenLayerConsensus.sol";

contract EigenLayerConsensusScript is Script {
    EigenLayerConsensus public consensus;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        consensus = new EigenLayerConsensus(10, 10);

        vm.stopBroadcast();
    }
}
