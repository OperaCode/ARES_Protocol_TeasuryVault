// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "../utility/BaseTest.t.sol";

contract GuardianMultisigTest is BaseTest {


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