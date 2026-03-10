// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationLayer {

    function verifyAuthorization(
        bytes32 operationHash,
        bytes calldata signature
    ) external returns (bool);

}