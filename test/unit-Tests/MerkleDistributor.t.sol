// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../utils/BaseTest.t.sol";

contract MerkleDistributorTest is BaseTest {

    bytes32[] proof;

    function testValidMerkleClaim() public {

        bytes32 leaf =
            keccak256(
                abi.encode(user, 1 ether)
            );

        distributor.updateRoot(leaf);

        vm.prank(user);

        distributor.claim(1 ether, proof);

        assertTrue(distributor.claimed(user));
    }

    function testClaimUpdatesState() public {

        bytes32 leaf =
            keccak256(
                abi.encode(user, 1 ether)
            );

        distributor.updateRoot(leaf);

        vm.prank(user);

        distributor.claim(1 ether, proof);

        assertTrue(distributor.claimed(user));
    }

    function testDoubleClaimFails() public {

        bytes32 leaf =
            keccak256(
                abi.encode(user, 1 ether)
            );

        distributor.updateRoot(leaf);

        vm.prank(user);
        distributor.claim(1 ether, proof);

        vm.expectRevert();

        vm.prank(user);
        distributor.claim(1 ether, proof);
    }
}