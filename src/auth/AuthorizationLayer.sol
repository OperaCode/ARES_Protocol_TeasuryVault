// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712Digest} from "../libraries/EIP712Digest.sol";
import {IAuthorizationLayer} from "../interfaces/IAuthorizationLayer.sol";

contract AuthorizationLayer is IAuthorizationLayer {
    using ECDSA for bytes32;

    mapping(address => uint256) public nonces;

    bytes32 public domainSeparator;

    bytes32 public constant AUTH_TYPEHASH =
        keccak256("Authorize(bytes32 operationHash,uint256 nonce)");

    constructor() {
        EIP712Digest.Domain memory domain = EIP712Digest.Domain({
            name: "ARES",
            version: "1",
            chainId: block.chainid,
            verifyingContract: address(this)
        });

        domainSeparator = EIP712Digest.domainSeparator(domain);
    }

    function verifyAuthorization(
        bytes32 operationHash,
        bytes calldata signature
    ) external override returns (bool) {
        // uint256 nonce = nonces[msg.sender];
        // bytes32 structHash;

        // assembly {
        //     let ptr := mload(0x40)

        //     mstore(ptr, AUTH_TYPEHASH)
        //     mstore(add(ptr, 32), operationHash)
        //     mstore(add(ptr, 64), nonce)

        //     structHash := keccak256(ptr, 96)

        //     mstore(0x40, add(ptr, 96))
        // }

        uint256 nonce = nonces[msg.sender];
        bytes32 typeHash = AUTH_TYPEHASH;
        bytes32 structHash;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, typeHash)
            mstore(add(ptr, 32), operationHash)
            mstore(add(ptr, 64), nonce)

            structHash := keccak256(ptr, 96)
        }

        bytes32 digest = EIP712Digest.digest(domainSeparator, structHash);

        address recovered = digest.recover(signature);

        require(recovered == msg.sender, "invalid signature");

        unchecked {
            nonces[msg.sender]++;
        }

        return true;
    }
}
