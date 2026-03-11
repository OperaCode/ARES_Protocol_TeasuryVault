// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {IMerkleDistributor} from "../interfaces/IMerkleDistributor.sol";

contract MerkleDistributor is IMerkleDistributor {
    bytes32 public merkleRoot;

    address public executor;

    mapping(address => bool) public claimed;

    event RootUpdated(bytes32 newRoot);
    event Claimed(address indexed user, uint256 amount);

    modifier onlyExecutor() {
        _onlyExecutor();
        _;
    }

    function _onlyExecutor() internal view {
        require(msg.sender == executor, "not executor");
    }

    constructor(address _executor) {
        require(_executor != address(0), "invalid executor");
        executor = _executor;
    }

    receive() external payable {}

    //   update distribution root- only callable via protocol execution pipeline

    function updateRoot(bytes32 newRoot) external onlyExecutor {
        merkleRoot = newRoot;

        emit RootUpdated(newRoot);
    }

    // claim contributor reward

    function claim(uint256 amount, bytes32[] calldata proof) external override {
        require(!claimed[msg.sender], "already claimed");

        bytes32 leaf = keccak256(abi.encode(msg.sender, amount));

        require(MerkleProof.verify(proof, merkleRoot, leaf), "invalid proof");

        claimed[msg.sender] = true;

        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "transfer failed");

        emit Claimed(msg.sender, amount);
    }
}
