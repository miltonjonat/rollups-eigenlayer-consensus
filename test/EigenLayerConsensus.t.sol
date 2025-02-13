// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EigenLayerConsensus} from "../src/EigenLayerConsensus.sol";
import {IEigenLayerConsensusServiceManager} from "../src/IEigenLayerConsensusServiceManager.sol";

contract EigenLayerConsensusTest is Test {
    EigenLayerConsensus public consensus;

    function setUp() public {
        consensus = new EigenLayerConsensus(IEigenLayerConsensusServiceManager(address(0)), 10, 10);
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
