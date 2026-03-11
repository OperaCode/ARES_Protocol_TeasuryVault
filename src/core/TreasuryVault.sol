// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITreasuryVault} from "../interfaces/ITreasuryVault.sol";

contract TreasuryVault is ITreasuryVault {
    address public executor;

    event ExecutorUpdated(address newExecutor);
    event TransferExecuted(address indexed to, uint256 amount);

    modifier onlyExecutor() {
        _onlyExecutor();
        _;
    }

    function _onlyExecutor() internal view {
        require(msg.sender == executor, "Vault: unauthorized");
    }

    constructor(address _executor) {
        require(_executor != address(0), "invalid executor");
        executor = _executor;
    }

    receive() external payable {}

    function setExecutor(address newExecutor) external onlyExecutor {
        require(newExecutor != address(0), "invalid");
        executor = newExecutor;

        emit ExecutorUpdated(newExecutor);
    }

    function transferEth(
        address to,
        uint256 amount
    ) external override onlyExecutor {
        require(address(this).balance >= amount, "insufficient balance");

        (bool success, ) = payable(to).call{value: amount}("");

        require(success, "transfer failed");

        emit TransferExecuted(to, amount);
    }
}
