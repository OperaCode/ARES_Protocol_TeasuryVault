// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../utility/BaseTest.t.sol";

contract TreasuryVaultTest is BaseTest {
    
    function testVaultReceivesETH() public {
        vm.prank(user);

        (bool success, ) = payable(address(vault)).call{value: 1 ether}("");
        require(success);

        assertEq(address(vault).balance, 1 ether);
    }

    function testOnlyExecutorCanTransfer() public {
        vm.expectRevert();

        vm.prank(user);

        vault.transferETH(user, 1 ether);
    }

    function testExecutorCanTransferETH() public {
        vm.deal(address(vault), 5 ether);

        vm.prank(executor);

        vault.transferETH(user, 1 ether);

        assertEq(user.balance, 11 ether);
    }

    function testCannotTransferMoreThanVaultBalance() public {
        vm.deal(address(vault), 1 ether);

        vm.expectRevert();

        vm.prank(executor);

        vault.transferETH(user, 5 ether);
    }
}
