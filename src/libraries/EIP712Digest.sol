// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library EIP712Digest {
    struct Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    function domainSeparator(
        Domain memory domain
    ) internal pure returns (bytes32) {
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

        bytes32 nameHash = keccak256(bytes(domain.name));
        bytes32 versionHash = keccak256(bytes(domain.version));

        bytes32 result;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, typeHash)
            mstore(add(ptr, 32), nameHash)
            mstore(add(ptr, 64), versionHash)
            mstore(add(ptr, 96), mload(add(domain, 64)))
            mstore(add(ptr, 128), mload(add(domain, 96)))

            result := keccak256(ptr, 160)
        }

        return result;
    }

    function digest(
        bytes32 domainSeparator_,
        bytes32 structHash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator_, structHash)
            );
    }
}
