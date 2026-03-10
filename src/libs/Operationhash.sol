// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library OperationHash {

    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 nonce,
        uint256 chainId
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                target,
                value,
                keccak256(data),
                nonce,
                chainId
            )
        );
    }
}