// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMerkleDistributor {

    function claim(
        uint256 amount,
        bytes32[] calldata proof
    ) external;

}