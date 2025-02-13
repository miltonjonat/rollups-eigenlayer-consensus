// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Interface for an EigenLayer AVS ServiceManager that supports Cartesi Rollup Consensus.
interface IEigenLayerConsensusServiceManager {
    /// @notice Retrieves an operator's stake registered in the AVS.
    /// @param operator The operator's account address
    /// @param quorumNumber The quorum number to get the stake for
    /// @param blockNumber Block number to make sure the stake is from
    /// @return The stake amount
    /// @dev Will revert if validator is not registered as an operator in the AVS
    function getOperatorStake(address operator, uint8 quorumNumber, uint32 blockNumber)
        external
        view
        returns (uint96);
}
