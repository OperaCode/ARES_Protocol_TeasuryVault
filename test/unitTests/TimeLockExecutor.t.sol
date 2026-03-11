// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "../utility/BaseTest.t.sol";
import {BaseTest} from "../utility/BaseTest.t.sol";

contract TimeLockExecutorTest is BaseTest {

   
    function testCannotExecuteBeforeDelay() public {

        bytes32 opHash = keccak256("operation");

        vm.prank(governor);
        timelock.queue(opHash);

        vm.expectRevert();

        vm.prank(executor);

        timelock.execute(
            opHash,
            address(vault),
            0,
            ""
        );
    }

    function testOperationCannotExecuteTwice() public {

        bytes32 opHash = keccak256("operation");

        vm.prank(governor);
        timelock.queue(opHash);

        vm.warp(block.timestamp + 1 hours);

        vm.prank(executor);
        timelock.execute(opHash, address(vault), 0, "");

        vm.expectRevert();

        vm.prank(executor);
        timelock.execute(opHash, address(vault), 0, "");
    }
}