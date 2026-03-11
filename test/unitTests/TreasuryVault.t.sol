// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../utility/BaseTest.t.sol";

contract TreasuryVaultTest is BaseTest {

    function testOnlyExecutorCanTransfer() public {

        // sanity check
        assertEq(vault.executor(), executor);

        vm.prank(user);

        vm.expectRevert("Vault: unauthorized");

        vault.transferETH(user, 1 ether);
    }


    function testCannotTransferMoreThanVaultBalance() public {

        vm.deal(address(vault), 1 ether);

        // sanity check
        assertEq(address(vault).balance, 1 ether);

        vm.prank(executor);

        vm.expectRevert("insufficient balance");

        vault.transferETH(user, 5 ether);

        // ensure vault balance unchanged
        assertEq(address(vault).balance, 1 ether);
    }
}