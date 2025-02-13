// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EigenlayerConsensus} from "../src/EigenlayerConsensus.sol";

contract EigenlayerConsensusTest is Test {
    EigenlayerConsensus public consensus;

    function setUp() public {
        consensus = new EigenlayerConsensus(10, 10);
    }

    function testFuzz_NotInFavor(
        address app,
        uint256 lastProcessedblockNumber,
        bytes32 outputsMerkleRoot,
        address validator
    ) public view {
        assertFalse(consensus.isValidatorInFavorOf(app, lastProcessedblockNumber, outputsMerkleRoot, validator));
    }

    function testFuzz_NoStake(address app, uint256 lastProcessedblockNumber, bytes32 outputsMerkleRoot) public view {
        assertEq(0, consensus.stakeInFavorOf(app, lastProcessedblockNumber, outputsMerkleRoot));
    }
}
