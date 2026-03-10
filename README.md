| Contract           | Role           | Security Goal               |
| ------------------ | -------------- | --------------------------- |
| TreasuryVault      | Stores funds   | No governance logic         |
| Executor           | Executes calls | Controlled execution        |
| TimelockController | Enforces delay | Prevent governance takeover |
| MultisigGovernor   | Approvals      | Distributed authority       |
| MerkleDistributor  | Rewards        | Gas-efficient distribution  |







src/
├ **core/**
│  TreasuryVault.sol
│  TimelockExecutor.sol
│
├ **governance/**
│  AresGovernor.sol
│  GuardianMultisig.sol
│
├ **modules/**
│  MerkleDistributor.sol
│
├ **auth/**
│  AuthorizationLayer.sol
│
├ **interfaces/**
|  ITreasuryVault.sol
|  ITimelockExecutor.sol
|  IAuthorizationLayer.sol
|  IMerkleDistributor.sol
|
└ **libraries/**
|   EIP721Digest.sol
|   OperationHash.sol
test/
|
|


test/
│
├── utils/
│   └── BaseTest.t.sol
│
├── unit/
│   ├── TreasuryVault.t.sol
│   ├── TimelockExecutor.t.sol
│   ├── AresGovernor.t.sol
│   ├── GuardianMultisig.t.sol
│   ├── AuthorizationLayer.t.sol
│   └── MerkleDistributor.t.sol
│
├── integration/
│   └── FullFlow.t.sol
│
└── exploit/
    ├── ReentrancyAttack.t.sol
    ├── ReplayAttack.t.sol
    ├── FlashLoanGovernance.t.sol
    ├── DoubleClaim.t.sol
    ├── InvalidSignature.t.sol
    ├── PrematureExecution.t.sol
    ├── ProposalReplay.t.sol
    └── UnauthorizedExecution.t.sol
