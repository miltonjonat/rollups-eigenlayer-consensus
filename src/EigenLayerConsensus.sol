// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IEigenLayerConsensusServiceManager} from "./IEigenLayerConsensusServiceManager.sol";
import {AbstractClaimSubmitter} from "rollups-contracts/consensus/AbstractClaimSubmitter.sol";
import {IClaimSubmitter} from "rollups-contracts/consensus/IClaimSubmitter.sol";

contract EigenLayerConsensus is AbstractClaimSubmitter {
    /// @notice EigenLayer AVS instance for Cartesi Rollup Consensus
    IEigenLayerConsensusServiceManager private immutable _serviceManager;
    /// @notice The amount of stake needed to back a claim in order for it to be accepted
    uint256 private immutable _stakeThreshold;

    /// @notice Votes in favor of a particular claim.
    /// @param inFavorStake The amount of stake in favor of the claim
    /// @param inFavorByAddress The set of validators in favor of the claim
    struct Votes {
        uint256 inFavorStake;
        mapping(address => bool) inFavorByAddress;
    }

    /// @notice Votes indexed by application contract address,
    /// last processed block number and outputs Merkle root.
    /// @dev See the `numOfValidatorsInFavorOf` and `isValidatorInFavorOf` functions.
    mapping(address => mapping(uint256 => mapping(bytes32 => Votes))) private _votes;

    /// @param serviceManager EigenLayer AVS instance for Cartesi Rollup Consensus
    /// @param stakeThreshold The amount of stake needed to back a claim in order for it to be accepted
    /// @param epochLength The epoch length
    /// @dev Reverts if the stake threshold or epoch length are zero.
    constructor(IEigenLayerConsensusServiceManager serviceManager, uint256 stakeThreshold, uint256 epochLength)
        AbstractClaimSubmitter(epochLength)
    {
        require(stakeThreshold > 0, "stakeThreshold must not be zero");
        _serviceManager = serviceManager;
        _stakeThreshold = stakeThreshold;
    }

    /// @inheritdoc IClaimSubmitter
    function submitClaim(address appContract, uint256 lastProcessedBlockNumber, bytes32 outputsMerkleRoot)
        external
        override
    {
        // check submitter's stake registered in the AVS (will revert if not registered as operator)
        uint256 stake = _getStake(msg.sender, lastProcessedBlockNumber);

        // emit ClaimSubmission event
        emit ClaimSubmission(msg.sender, appContract, lastProcessedBlockNumber, outputsMerkleRoot);

        // retrieve current votes for the claim
        Votes storage votes = _getVotes(appContract, lastProcessedBlockNumber, outputsMerkleRoot);

        // accrue submitter's stake to the total amount backing the claim (unless submitter already voted)
        if (!votes.inFavorByAddress[msg.sender]) {
            votes.inFavorByAddress[msg.sender] = true;
            votes.inFavorStake += stake;
            if (votes.inFavorStake > _stakeThreshold) {
                _acceptClaim(appContract, lastProcessedBlockNumber, outputsMerkleRoot);
            }
        }
    }

    /// @notice Returns the amount of stake in favor of a claim.
    /// @param appContract The application contract address
    /// @param lastProcessedBlockNumber The last processed block for the claim
    /// @param outputsMerkleRoot The outputs Merkle root representing the claim
    /// @return The stake amount
    function stakeInFavorOf(address appContract, uint256 lastProcessedBlockNumber, bytes32 outputsMerkleRoot)
        external
        view
        returns (uint256)
    {
        return _getVotes(appContract, lastProcessedBlockNumber, outputsMerkleRoot).inFavorStake;
    }

    /// @notice Returns whether a given validator is backing a claim.bytes
    /// @param appContract The application contract address
    /// @param lastProcessedBlockNumber The last processed block for the claim
    /// @param outputsMerkleRoot The outputs Merkle root representing the claim
    /// @param validator The validator's account address
    /// @return True if the validator has voted in favor of the claim, false otherwise
    function isValidatorInFavorOf(
        address appContract,
        uint256 lastProcessedBlockNumber,
        bytes32 outputsMerkleRoot,
        address validator
    ) external view returns (bool) {
        return _getVotes(appContract, lastProcessedBlockNumber, outputsMerkleRoot).inFavorByAddress[validator];
    }

    /// @notice Retrieves a `Votes` structure from storage for a given claim.
    /// @param appContract The application contract address
    /// @param lastProcessedBlockNumber The last processed block for the claim
    /// @param outputsMerkleRoot The outputs Merkle root representing the claim
    /// @return The `Votes` structure related to a given claim
    function _getVotes(address appContract, uint256 lastProcessedBlockNumber, bytes32 outputsMerkleRoot)
        internal
        view
        returns (Votes storage)
    {
        return _votes[appContract][lastProcessedBlockNumber][outputsMerkleRoot];
    }

    /// @notice Retrieves a validator's stake registered in the AVS at a given block.
    /// @param validator The validator's account address
    /// @param blockNumber Reference block for retrieving the stake
    /// @return The stake amount
    /// @dev Will revert if validator is not registered as an operator in the AVS
    function _getStake(address validator, uint256 blockNumber) internal view returns (uint96) {
        require(
            blockNumber <= type(uint32).max,
            "EigenLayer does not support block numbers that exceed the limit for uint32"
        );
        return _serviceManager.getOperatorStake(validator, 0, uint32(blockNumber));
    }
}
