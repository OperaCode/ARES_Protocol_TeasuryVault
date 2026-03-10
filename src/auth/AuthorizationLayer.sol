// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712Digest} from "../libraries/EIP712Digest.sol";
import {OperationHash} from "../libraries/OperationHash.sol";
import {IAuthorizationLayer} from "../interfaces/IAuthorizationLayer.sol";

contract AuthorizationLayer is IAuthorizationLayer {

    using ECDSA for bytes32;

    mapping(address => uint256) public nonces;

    bytes32 public DOMAIN_SEPARATOR;

    bytes32 public constant AUTH_TYPEHASH =
        keccak256(
            "Authorize(bytes32 operationHash,uint256 nonce)"
        );

    constructor() {

        EIP712Digest.Domain memory domain =
            EIP712Digest.Domain({
                name: "ARES",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(this)
            });

        DOMAIN_SEPARATOR =
            EIP712Digest.domainSeparator(domain);
    }

    function verifyAuthorization(
        bytes32 operationHash,
        bytes calldata signature
    )
        external
        override
        returns (bool)
    {

        bytes32 structHash =
            keccak256(
                abi.encode(
                    AUTH_TYPEHASH,
                    operationHash,
                    nonces[msg.sender]
                )
            );

        bytes32 digest =
            EIP712Digest.digest(
                DOMAIN_SEPARATOR,
                structHash
            );

        address recovered =
            digest.recover(signature);

        require(
            recovered == msg.sender,
            "invalid signature"
        );

        nonces[msg.sender]++;

        return true;
    }
}