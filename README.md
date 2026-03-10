contracts/
 ## TreasuryVault.sol

    



 ├ MultisigGovernor.sol
 ## TimelockController.sol

 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimelockController {

    struct Operation {
        address target;
        uint256 value;
        bytes data;
        uint256 eta;
        bool executed;
    }

    uint256 public constant MIN_DELAY = 1 hours;

    address public governor;
    address public executor;

    mapping(bytes32 => Operation) public operations;

    event Queued(bytes32 txHash, uint256 eta);
    event Executed(bytes32 txHash);

    modifier onlyGovernor() {
        require(msg.sender == governor, "not governor");
        _;
    }

    constructor(address _governor, address _executor) {
        governor = _governor;
        executor = _executor;
    }

    function queue(
        address target,
        uint256 value,
        bytes calldata data
    )
        external
        onlyGovernor
        returns(bytes32 txHash)
    {
        txHash = keccak256(
            abi.encode(target, value, data, block.timestamp)
        );

        operations[txHash] = Operation({
            target: target,
            value: value,
            data: data,
            eta: block.timestamp + MIN_DELAY,
            executed: false
        });

        emit Queued(txHash, block.timestamp + MIN_DELAY);
    }

    function execute(bytes32 txHash) external {

        Operation storage op = operations[txHash];

        require(!op.executed, "already executed");
        require(block.timestamp >= op.eta, "timelock active");

        op.executed = true;

        (bool success,) =
            executor.call(
                abi.encodeWithSignature(
                    "execute(address,uint256,bytes)",
                    op.target,
                    op.value,
                    op.data
                )
            );

        require(success, "executor failed");

        emit Executed(txHash);
    }
}

 ## Executor.sol

    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Executor is ReentrancyGuard {

    address public timelock;

    event Executed(address target, uint256 value);

    modifier onlyTimelock() {
        require(msg.sender == timelock, "Executor: not timelock");
        _;
    }

    constructor(address _timelock) {
        require(_timelock != address(0), "invalid timelock");
        timelock = _timelock;
    }

    function execute(
        address target,
        uint256 value,
        bytes calldata data
    )
        external
        onlyTimelock
        nonReentrant
        returns (bytes memory)
    {
        (bool success, bytes memory result) =
            target.call{value:value}(data);

        require(success, "execution failed");

        emit Executed(target, value);

        return result;
    }
}

 └ MerkleDistributor.sol  

 

 | Contract           | Role           | Security Goal               |
| ------------------ | -------------- | --------------------------- |
| TreasuryVault      | Stores funds   | No governance logic         |
| Executor           | Executes calls | Controlled execution        |
| TimelockController | Enforces delay | Prevent governance takeover |
| MultisigGovernor   | Approvals      | Distributed authority       |
| MerkleDistributor  | Rewards        | Gas-efficient distribution  |



src/
├── TreasuryVault.sol
├── TimelockExecutor.sol
├── AresGovernor.sol
├── GuardianMultisig.sol
├── MerkleDistributor.sol
└── libraries/
    └── EIP712Nonce.sol