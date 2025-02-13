// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ECDSAServiceManagerBase} from
    "@eigenlayer-middleware/src/unaudited/ECDSAServiceManagerBase.sol";
import {ECDSAStakeRegistry} from "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {IServiceManager} from "@eigenlayer-middleware/src/interfaces/IServiceManager.sol";
import {ECDSAUpgradeable} from
    "@openzeppelin-upgrades/contracts/utils/cryptography/ECDSAUpgradeable.sol";
import {IERC1271Upgradeable} from "@openzeppelin-upgrades/contracts/interfaces/IERC1271Upgradeable.sol";
import {IHelloWorldServiceManager} from "./IHelloWorldServiceManager.sol";
import {AbstractClaimSubmitter} from "./AbstractClaimSubmitter.sol";
import {IClaimSubmitter} from "./IClaimSubmitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@eigenlayer/contracts/interfaces/IRewardsCoordinator.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title Primary entrypoint for procuring services from HelloWorld.
 * @author Eigen Labs, Inc.
 */
contract HelloWorldServiceManager is AbstractClaimSubmitter, ECDSAServiceManagerBase, IHelloWorldServiceManager {
    using ECDSAUpgradeable for bytes32;

    uint32 public latestTaskNum;

    // mapping of task indices to all tasks hashes
    // when a task is created, task hash is stored here,
    // and responses need to pass the actual task,
    // which is hashed onchain and checked against this mapping
    mapping(uint32 => bytes32) public allTaskHashes;

    // mapping of task indices to hash of abi.encode(taskResponse, taskResponseMetadata)
    mapping(address => mapping(uint32 => bytes)) public allTaskResponses;

    modifier onlyOperator() {
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(msg.sender),
            "Operator must be the caller"
        );
        _;
    }

    constructor(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager,
        uint256 _epochLength
    )
        AbstractClaimSubmitter(_epochLength)
        ECDSAServiceManagerBase(
            _avsDirectory,
            _stakeRegistry,
            _rewardsCoordinator,
            _delegationManager
        )
    {}

    function initialize(
        address initialOwner,
        address _rewardsInitiator
    ) external initializer {
        __ServiceManagerBase_init(initialOwner, _rewardsInitiator);
    }

    /* FUNCTIONS */
    // NOTE: this function creates new task, assigns it a taskId
    function createNewTask(
        string memory name
    ) external returns (Task memory) {
        // create a new task struct
        Task memory newTask;
        newTask.name = name;
        newTask.taskCreatedBlock = uint32(block.number);

        // store hash of task onchain, emit event, and increase taskNum
        allTaskHashes[latestTaskNum] = keccak256(abi.encode(newTask));
        emit NewTaskCreated(latestTaskNum, newTask);
        latestTaskNum = latestTaskNum + 1;

        return newTask;
    }

    function respondToTask(
        Task calldata task,
        uint32 referenceTaskIndex,
        bytes memory signature
    ) external {
        // check that the task is valid, hasn't been responsed yet, and is being responded in time
        require(
            keccak256(abi.encode(task)) == allTaskHashes[referenceTaskIndex],
            "supplied task does not match the one recorded in the contract"
        );
        require(
            allTaskResponses[msg.sender][referenceTaskIndex].length == 0,
            "Operator has already responded to the task"
        );

        // The message that was signed
        bytes32 messageHash = keccak256(abi.encodePacked("Hello, ", task.name));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        bytes4 magicValue = IERC1271Upgradeable.isValidSignature.selector;
        if (!(magicValue == ECDSAStakeRegistry(stakeRegistry).isValidSignature(ethSignedMessageHash,signature))){
            revert();
        }

        // updating the storage with task responses
        allTaskResponses[msg.sender][referenceTaskIndex] = signature;

        // emitting event
        emit TaskResponded(referenceTaskIndex, task, msg.sender);
    }
        /// @inheritdoc IClaimSubmitter
    function submitClaim(address appContract, uint256 lastProcessedBlockNumber, bytes32 outputsMerkleRoot)
        external
        override
    {

        _acceptClaim(appContract, lastProcessedBlockNumber, outputsMerkleRoot);
//        // check submitter's stake registered in the AVS (will revert if not registered as operator)
//        uint256 stake = _getStake(msg.sender, lastProcessedBlockNumber);
//
//        // emit ClaimSubmission event
//        emit ClaimSubmission(msg.sender, appContract, lastProcessedBlockNumber, outputsMerkleRoot);
//
//        // retrieve current votes for the claim
//        Votes storage votes = _getVotes(appContract, lastProcessedBlockNumber, outputsMerkleRoot);
//
//        // accrue submitter's stake to the total amount backing the claim (unless submitter already voted)
//        if (!votes.inFavorByAddress[msg.sender]) {
//            votes.inFavorByAddress[msg.sender] = true;
//            votes.inFavorStake += stake;
//            if (votes.inFavorStake > _stakeThreshold) {
//                _acceptClaim(appContract, lastProcessedBlockNumber, outputsMerkleRoot);
//            }
//        }
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
        return 0;
        //return _serviceManager.getOperatorStake(validator, 0, uint32(blockNumber));
    }

}