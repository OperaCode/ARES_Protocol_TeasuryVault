// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasuryVault {

    function transferETH(
        address to,
        uint256 amount
    ) external;

}