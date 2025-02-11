// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EigenlayerConsensus} from "../src/EigenlayerConsensus.sol";

contract EigenlayerConsensusTest is Test {
    EigenlayerConsensus public consensus;

    function setUp() public {
        consensus = new EigenlayerConsensus();
        consensus.setNumber(0);
    }

    function test_Increment() public {
        consensus.increment();
        assertEq(consensus.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        consensus.setNumber(x);
        assertEq(consensus.number(), x);
    }
}
