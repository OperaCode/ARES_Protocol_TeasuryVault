// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../utility/BaseTest.t.sol";

contract TreasuryVaultTest is BaseTest {


    function testOnlyExecutorCanTransfer() public {
        vm.expectRevert();

        vm.prank(user);

        vault.transferETH(user, 1 ether);
    }


    function testCannotTransferMoreThanVaultBalance() public {
        vm.deal(address(vault), 1 ether);

        vm.expectRevert();

        vm.prank(executor);

        vault.transferETH(user, 5 ether);
    }
}
