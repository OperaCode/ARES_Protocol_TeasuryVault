// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IVotesToken {
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}