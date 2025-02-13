// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IEigenLayerConsensusServiceManager} from "./IEigenLayerConsensusServiceManager.sol";
import {ServiceManagerBase} from "eigenlayer-middleware/src/ServiceManagerBase.sol";
import {IRegistryCoordinator} from "eigenlayer-middleware/src/interfaces/IRegistryCoordinator.sol";
import {IStakeRegistry} from "eigenlayer-middleware/src/interfaces/IStakeRegistry.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import {IRewardsCoordinator} from "eigenlayer-contracts/src/contracts/interfaces/IRewardsCoordinator.sol";

/// @notice EigenLayer AVS ServiceManager that supports Cartesi Rollup Consensus.
contract EigenLayerConsensusServiceManager is IEigenLayerConsensusServiceManager, ServiceManagerBase {
    IRegistryCoordinator private registryCoordinator;
    IStakeRegistry private stakeRegistry;

    constructor(IAVSDirectory _avsDirectory, IRegistryCoordinator _registryCoordinator, IStakeRegistry _stakeRegistry)
        ServiceManagerBase(
            _avsDirectory,
            IRewardsCoordinator(address(0)), // not dealing with rewards now
            _registryCoordinator,
            _stakeRegistry
        )
    {
        registryCoordinator = _registryCoordinator;
        stakeRegistry = _stakeRegistry;
    }

    /// @inheritdoc IEigenLayerConsensusServiceManager
    function getOperatorStake(address operator, uint8 quorumNumber, uint32 blockNumber)
        external
        view
        returns (uint96)
    {
        require(
            registryCoordinator.getOperatorStatus(operator) == IRegistryCoordinator.OperatorStatus.REGISTERED,
            "Operator not registered"
        );
        bytes32 operatorId = registryCoordinator.getOperatorId(operator);
        return stakeRegistry.getStakeAtBlockNumber(operatorId, quorumNumber, blockNumber);
    }
}
