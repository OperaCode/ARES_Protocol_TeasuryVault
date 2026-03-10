// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

contract TreasuryVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Immutable — set once, never changed
    // Rotation requires deploying a new vault via timelock
    address public immutable executor;

    event ETHTransferred(address indexed to, uint256 amount);
    event ERC20Transferred(address indexed token, address indexed to, uint256 amount);

    modifier onlyExecutor() {
        require(msg.sender == executor, "Vault: not executor");
        _;
    }

    constructor(address _executor) {
        require(_executor != address(0), "Vault: zero address");
        executor = _executor;
    }

    // Accept ETH deposits
    receive() external payable {}

    // ETH transfers — nonReentrant + onlyExecutor
    function transferETH(address to, uint256 amount)
        external
        onlyExecutor
        nonReentrant
    {
        require(to != address(0),              "Vault: zero address");
        require(address(this).balance >= amount, "Vault: insufficient ETH");

        // CEI: emit before external call
        emit ETHTransferred(to, amount);

        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Vault: ETH transfer failed");
    }

    // ERC20 transfers — SafeERC20 handles non-standard tokens
    function transferERC20(address token, address to, uint256 amount)
        external
        onlyExecutor
        nonReentrant
    {
        require(to != address(0),    "Vault: zero address");
        require(token != address(0), "Vault: zero token");

        emit ERC20Transferred(token, to, amount);

        IERC20(token).safeTransfer(to, amount);
    }

    // View helpers
    function ethBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function tokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}