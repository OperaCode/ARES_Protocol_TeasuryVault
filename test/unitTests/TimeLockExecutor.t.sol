// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "../utility/BaseTest.t.sol";

contract TimeLockExecutorTest is BaseTest {

    function testCannotExecuteBeforeDelay() public {

        bytes32 opHash = keccak256("operation");

        vm.prank(governor);
        timelock.queue(opHash);

        // sanity checks
        (uint256 executeAfter, bool executed) = timelock.operations(opHash);

        assertGt(executeAfter, 0);
        assertFalse(executed);

        vm.prank(executor);

        vm.expectRevert("timelock active");

        timelock.execute(
            opHash,
            address(vault),
            0,
            ""
        );

        // ensure state unchanged
        (, executed) = timelock.operations(opHash);
        assertFalse(executed);
    }


    function testOperationCannotExecuteTwice() public {

        bytes32 opHash = keccak256("operation");

        vm.prank(governor);
        timelock.queue(opHash);

        // sanity check queue
        (uint256 executeAfter, bool executed) = timelock.operations(opHash);

        assertGt(executeAfter, block.timestamp);
        assertFalse(executed);

        vm.warp(block.timestamp + 1 hours);

        vm.prank(executor);
        timelock.execute(opHash, address(vault), 0, "");

        // sanity after execution
        (, executed) = timelock.operations(opHash);
        assertTrue(executed);

        vm.expectRevert("already executed");

        vm.prank(executor);
        timelock.execute(opHash, address(vault), 0, "");
    }
}