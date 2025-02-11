// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EigenlayerConsensus} from "../src/EigenlayerConsensus.sol";

contract EigenlayerConsensusScript is Script {
    EigenlayerConsensus public consensus;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        consensus = new EigenlayerConsensus();

        vm.stopBroadcast();
    }
}
