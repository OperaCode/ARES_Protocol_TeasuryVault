// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "../utility/BaseTest.t.sol";

contract GovernanceFlowTest is BaseTest {

    function testFullGovernanceFlowExecutesTreasuryTransfer() public {

        // Arrange 

        vm.deal(address(vault), 5 ether);

        // sanity: vault funded
        assertEq(address(vault).balance, 5 ether);

        // allow timelock to control vault
        vm.prank(executor);
        vault.setExecutor(address(timelock));

        // sanity: executor updated
        assertEq(vault.executor(), address(timelock));

        uint256 userBalanceBefore = user.balance;

        bytes memory data =
            abi.encodeCall(
                vault.transferETH,
                (user, 1 ether)
            );

        bytes32 opHash =
            keccak256(
                abi.encode(
                    address(vault),
                    0,
                    data,
                    timelock.nonce()
                )
            );

        // Queue operation

        vm.prank(governor);
        timelock.queue(opHash);

        // sanity: operation stored
        (uint256 executeAfter, bool executed) =
            timelock.operations(opHash);

        assertGt(executeAfter, block.timestamp);
        assertFalse(executed);

   

        vm.warp(block.timestamp + 1 hours);

     

        timelock.execute(
            opHash,
            address(vault),
            0,
            data
        );

        // sanity: operation marked executed
        (, executed) = timelock.operations(opHash);
        assertTrue(executed);

        //  Verify effects

        assertEq(user.balance, userBalanceBefore + 1 ether);
        assertEq(address(vault).balance, 4 ether);
    }
}