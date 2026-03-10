// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TreasuryVault {

    address public executor;

    event ExecutorUpdated(address indexed newExecutor);
    event ETHTransferred(address indexed to, uint256 amount);

    modifier onlyExecutor() {
        require(msg.sender == executor, "Vault: not executor");
        _;
    }

    constructor(address _executor) {
        require(_executor != address(0), "invalid executor");
        executor = _executor;
    }

    receive() external payable {}

    function updateExecutor(address newExecutor) external onlyExecutor {
        require(newExecutor != address(0), "invalid address");
        executor = newExecutor;
        emit ExecutorUpdated(newExecutor);
    }

    function transferETH(address to, uint256 amount)
        external
        onlyExecutor
    {
        require(address(this).balance >= amount, "insufficient balance");

        (bool success,) = payable(to).call{value: amount}("");
        require(success, "transfer failed");

        emit ETHTransferred(to, amount);
    }
}