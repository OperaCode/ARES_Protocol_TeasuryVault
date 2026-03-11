// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "../utility/BaseTest.t.sol";

contract GuardianMultisigTest is BaseTest {

    function testNonGuardianCannotApprove() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        // sanity checks
        assertFalse(multisig.isGuardian(user));
        assertTrue(multisig.isGuardian(guardian));
        assertGt(multisig.threshold(), 0);

        vm.prank(user);

        vm.expectRevert("not guardian");

        multisig.approveAction(actionHash);
    }


    function testCannotExecuteWithoutApprovals() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        // sanity checks
        assertTrue(multisig.isGuardian(guardian));
        assertGt(multisig.threshold(), 0);

        vm.prank(guardian);

        vm.expectRevert("insufficient approvals");

        multisig.executeAction(actionHash);
    }
}