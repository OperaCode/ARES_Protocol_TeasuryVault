// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library OperationHash {

    function hashOperation(
        address target,
        uint256 value,
        bytes memory data,
        uint256 nonce,
        uint256 chainId
    )
        internal
        pure
        returns (bytes32)
    {
        bytes32 dataHash = keccak256(data);
        bytes32 result;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, target)
            mstore(add(ptr, 32), value)
            mstore(add(ptr, 64), dataHash)
            mstore(add(ptr, 96), nonce)
            mstore(add(ptr, 128), chainId)

            result := keccak256(ptr, 160)

            // update free memory pointer
            mstore(0x40, add(ptr, 160))
        }

        return result;
    }
}