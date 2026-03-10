// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITimelockExecutor {

    function queue(
        bytes32 operationHash
    ) external;

    function execute(
        bytes32 operationHash,
        address target,
        uint256 value,
        bytes calldata data
    ) external;

}