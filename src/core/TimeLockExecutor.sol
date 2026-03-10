// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/OperationHash.sol";
import "../interfaces/ITimelockExecutor.sol";

contract TimelockExecutor is
    ITimelockExecutor,
    ReentrancyGuard
{

    struct Operation {
        uint256 executeAfter;
        bool executed;
    }

    uint256 public constant DELAY = 1 hours;

    mapping(bytes32 => Operation) public operations;

    address public governor;
    uint256 public nonce;

    event OperationQueued(bytes32 opHash, uint256 executeAfter);
    event OperationExecuted(bytes32 opHash);

    modifier onlyGovernor() {
        require(msg.sender == governor, "not governor");
        _;
    }

    constructor(address _governor) {
        governor = _governor;
    }

    function queue(
        bytes32 operationHash
    )
        external
        override
        onlyGovernor
    {
        require(
            operations[operationHash].executeAfter == 0,
            "already queued"
        );

        uint256 executeAfter =
            block.timestamp + DELAY;

        operations[operationHash] =
            Operation({
                executeAfter: executeAfter,
                executed: false
            });

        emit OperationQueued(
            operationHash,
            executeAfter
        );
    }

    function execute(
        bytes32 operationHash,
        address target,
        uint256 value,
        bytes calldata data
    )
        external
        override
        nonReentrant
    {
        Operation storage op =
            operations[operationHash];

        require(op.executeAfter != 0, "not queued");
        require(!op.executed, "already executed");

        require(
            block.timestamp >= op.executeAfter,
            "timelock active"
        );

        op.executed = true;

        (bool success,) =
            target.call{value:value}(data);

        require(success, "execution failed");

        emit OperationExecuted(operationHash);
    }
}