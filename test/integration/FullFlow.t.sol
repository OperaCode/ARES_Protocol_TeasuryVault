// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "../utility/BaseTest.t.sol";

import {BaseTest} from "../utility/BaseTest.t.sol";

contract GovernanceFlowTest is BaseTest {

    function testFullGovernanceFlowExecutesTreasuryTransfer() public {

        // Arrange
        vm.deal(address(vault), 5 ether);

        // allow timelock to control vault
        vm.prank(executor);
        vault.setExecutor(address(timelock));

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

        // Act — queue operation via governor
        vm.prank(address(governor));
        timelock.queue(opHash);

        // wait for timelock delay
        vm.warp(block.timestamp + 1 hours);

        timelock.execute(
            opHash,
            address(vault),
            0,
            data
        );

        // Assert
        assertEq(user.balance, 11 ether);
    }
}