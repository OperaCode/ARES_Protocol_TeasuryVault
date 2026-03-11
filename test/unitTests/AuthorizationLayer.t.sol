// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {BaseTest} from "../utility/BaseTest.t.sol";

contract AuthorizationLayerTest is BaseTest {

    uint256 private userPrivateKey = 0xA11CE;

    function setUp() public override {
        super.setUp();
        user = vm.addr(userPrivateKey);
    }

    function testAuthorizationSuccessIncrementsNonce() public {

        bytes32 operationHash = keccak256("operation");

        uint256 nonceBefore = auth.nonces(user);

        bytes32 structHash =
            keccak256(
                abi.encode(
                    auth.AUTH_TYPEHASH(),
                    operationHash,
                    nonceBefore
                )
            );

        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    auth.domainSeparator(),
                    structHash
                )
            );

        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(userPrivateKey, digest);

        bytes memory signature =
            abi.encodePacked(r, s, v);

        vm.prank(user);

        bool success =
            auth.verifyAuthorization(
                operationHash,
                signature
            );

        assertTrue(success);

        uint256 nonceAfter = auth.nonces(user);

        assertEq(nonceAfter, nonceBefore + 1);
    }
}