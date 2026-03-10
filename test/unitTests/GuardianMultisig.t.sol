// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "../utility/BaseTest.t.sol";

contract GuardianMultisigTest is BaseTest {

    function testGuardianCanApproveAction() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        vm.prank(guardian);

        multisig.approveAction(actionHash);

        (uint256 approvals, ) = multisig.approvals(actionHash);

        assertEq(approvals, 1);
    }

    function testExecuteActionAfterThreshold() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        vm.startPrank(guardian);

        multisig.approveAction(actionHash);

        multisig.executeAction(actionHash);

        vm.stopPrank();

        (, bool executed) = multisig.approvals(actionHash);

        assertTrue(executed);
    }

    function testNonGuardianCannotApprove() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        vm.expectRevert("not guardian");

        vm.prank(user);

        multisig.approveAction(actionHash);
    }

    function testCannotExecuteWithoutApprovals() public {

        bytes32 actionHash = keccak256("upgrade protocol");

        vm.expectRevert();

        vm.prank(guardian);

        multisig.executeAction(actionHash);
    }

}