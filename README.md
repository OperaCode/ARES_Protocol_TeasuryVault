
 

 | Contract           | Role           | Security Goal               |
| ------------------ | -------------- | --------------------------- |
| TreasuryVault      | Stores funds   | No governance logic         |
| Executor           | Executes calls | Controlled execution        |
| TimelockController | Enforces delay | Prevent governance takeover |
| MultisigGovernor   | Approvals      | Distributed authority       |
| MerkleDistributor  | Rewards        | Gas-efficient distribution  |



src/
 ├ core/
 │   TreasuryVault.sol
 │   TimelockExecutor.sol
 │
 ├ governance/
 │   AresGovernor.sol
 │   GuardianMultisig.sol
 │
 ├ modules/
 │   MerkleDistributor.sol
 │
 ├ auth/
 │   AuthorizationLayer.sol
 │
 ├ interfaces/
 └ libraries/

 interfaces/
 ├ ITreasuryVault.sol
 ├ ITimelockExecutor.sol
 ├ IAuthorizationLayer.sol
 └ IMerkleDistributor.sol