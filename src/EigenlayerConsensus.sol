// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AbstractClaimSubmitter} from "rollups-contracts/consensus/AbstractClaimSubmitter.sol";

contract EigenlayerConsensus is AbstractClaimSubmitter {
    uint256 public number;

    constructor(uint256 epochLength) AbstractClaimSubmitter(epochLength) {}

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function submitClaim(address appContract, uint256 lastProcessedBlockNumber, bytes32 outputsMerkleRoot)
        external
        override
    {}
}
