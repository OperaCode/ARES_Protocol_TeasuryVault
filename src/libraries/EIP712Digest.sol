// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library EIP712Digest {
    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    // compile-time constant (avoids runtime keccak warning)
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    // function domainSeparator(
    //     Domain memory domain
    // ) internal pure returns (bytes32) {

    //     bytes32 nameHash = keccak256(bytes(domain.name));
    //     bytes32 versionHash = keccak256(bytes(domain.version));

    //     bytes32 result;

    //     assembly {
    //         let ptr := mload(0x40)

    //         mstore(ptr, DOMAIN_TYPEHASH)
    //         mstore(add(ptr, 32), nameHash)
    //         mstore(add(ptr, 64), versionHash)

    //         // load chainId and verifyingContract from struct
    //         mstore(add(ptr, 96), mload(add(domain, 64)))
    //         mstore(add(ptr, 128), mload(add(domain, 96)))

    //         result := keccak256(ptr, 160)

    //         // update free memory pointer
    //         mstore(0x40, add(ptr, 160))
    //     }

    //     return result;
    // }

    function domainSeparator(
        Domain memory domain
    ) internal pure returns (bytes32) {
        bytes32 typeHash = DOMAIN_TYPEHASH; // move constant to stack variable
        bytes32 nameHash = keccak256(bytes(domain.name));
        bytes32 versionHash = keccak256(bytes(domain.version));

        bytes32 result;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, typeHash)
            mstore(add(ptr, 32), nameHash)
            mstore(add(ptr, 64), versionHash)

            // load struct fields
            mstore(add(ptr, 96), mload(add(domain, 64)))
            mstore(add(ptr, 128), mload(add(domain, 96)))

            result := keccak256(ptr, 160)

            mstore(0x40, add(ptr, 160))
        }

        return result;
    }

    function digest(
        bytes32 domainSeparator_,
        bytes32 structHash
    ) internal pure returns (bytes32 result) {
        assembly {
            let ptr := mload(0x40)

            // write prefix 0x1901
            mstore(ptr, 0x1901)

            // store domain separator and struct hash
            mstore(add(ptr, 2), domainSeparator_)
            mstore(add(ptr, 34), structHash)

            result := keccak256(ptr, 66)

            mstore(0x40, add(ptr, 66))
        }
    }
}
