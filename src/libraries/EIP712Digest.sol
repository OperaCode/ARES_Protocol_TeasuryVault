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
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(domain.name)),
                    keccak256(bytes(domain.version)),
                    domain.chainId,
                    domain.verifyingContract
                )
            );
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
