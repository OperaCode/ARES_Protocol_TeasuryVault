# ARES Protocol Treasury Architecture

## Overview

The ARES Protocol treasury system is a modular framework for secure on-chain asset management. It enforces strict separation of concerns across five independent modules that covers: proposal management, cryptographic authorization, time-delayed execution, fund storage, and reward distribution. This prevents single points of failure and ensures layered validations for treasury actions.

Managing $500M+ in assets, it distributes capital to contributors, LPs, and governance participants. Defenses include protections against governance takeovers, replay attacks, flash-loan manipulations, Merkle exploits, timelock bypasses, and multisig griefing. Sequential approvals through distinct contracts eliminate monolithic risks.

The core innovation is the mandatory pipeline: proposals are created, authorized cryptographically, queued with delays, and executed after validations. This prevents immediate actions and detects malicious intents. Unlike existing protocols, all components are built from scratch, avoiding inherited vulnerabilities.

## System Architecture

The ARES Protocol follows a professional, hierarchical directory structure that ensures scalability, maintainability, and clear separation of responsibilities:

```
src/
├── core/
│   ├── TreasuryVault.sol
│   └── TimeLockExecutor.sol
├── governance/
│   ├── AresGovernor.sol
│   └── GuardianMultiSig.sol
├── auth/
│   └── AuthorizationLayer.sol
├── modules/
│   └── MerkleDistributor.sol
├── interfaces/
│   ├── ITreasuryVault.sol
│   ├── ITimelockExecutor.sol
│   ├── IAuthorizationLayer.sol
│   └── IMerkleDistributor.sol
└── libraries/
    ├── EIP712Digest.sol
    └── Operationhash.sol
```

Each layer serves a specialized purpose and communicates through well-defined interfaces:

- **Core Layer**: Handles asset storage and execution logic with reentrancy guards, overflow protections, and access controls.
- **Governance Layer**: Manages proposal lifecycle and emergency controls using distributed multisig authority.
- **Auth Layer**: Provides cryptographic verification and replay protection with EIP-712 structured signatures.
- **Modules Layer**: Extends functionality for distributions, enabling independent upgrades.
- **Interfaces Layer**: Defines contract boundaries for modularity and testing.
- **Libraries Layer**: Offers shared utilities for hashing and signature operations.

The system uses more than five Solidity files, deliberately avoiding monolithic contract designs that could introduce complex interdependencies. All inter-contract communication is mediated through interfaces, ensuring modularity, upgradability, and simplified auditing.

## Module Separation

The architecture enforces rigorous separation of concerns to minimize attack surfaces and ensure each component has a single responsibility:

- **TreasuryVault**: Acts as a secure fund repository and execution engine, accepting calls only from authorized sources with balance checks and reentrancy protection.
- **TimeLockExecutor**: Serves as a temporal enforcer, queuing operations with delays to prevent flash attacks and premature executions.
- **AresGovernor**: Oversees proposal creation and coordination with authorization, without direct fund execution or timelock alteration.
- **AuthorizationLayer**: Functions as a cryptographic gatekeeper, verifying signatures and tracking nonces to stop replay attacks.
- **GuardianMultiSig**: Offers asymmetric emergency authority for cancellations, limiting initiation to reduce abuse.
- **MerkleDistributor**: Manages claims in isolation using proof verification for gas-efficient distributions.

This design ensures compromising one module does not lead to fund loss. For example, a governor exploit cannot bypass timelock, and Merkle flaws remain contained.

## Security Boundaries

Security is enforced through multiple concentric boundaries at the contract level, creating defense in depth:

- **TreasuryVault as Innermost Boundary**: Treats callers as adversarial, re-validating authorizations and balances before execution.
- **TimeLockExecutor as Temporal Barrier**: Requires queued state and elapsed time to block premature actions.
- **AuthorizationLayer as Cryptographic Filter**: Uses nonces and EIP-712 to prevent replays, forgeries, and cross-chain attacks.
- **GuardianMultiSig as Emergency Brake**: Enables threshold-based overrides for malicious proposals.
- **MerkleDistributor in Isolation**: Protects reward mechanisms from treasury exploits with atomic operations.

Interfaces like ITreasuryVault enforce validations, ensuring only validated operations proceed.

## Trust Assumptions

The system's security model relies on several key assumptions, each with mitigations:

- **Key Security**: Signer keys for AuthorizationLayer and GuardianMultiSig must be secured with hardware wallets or multisig. Compromise allows malicious proposals, but timelock provides detection windows for cancellation.
- **EVM Integrity**: Assumes correct Ethereum Virtual Machine operation; contracts include reentrancy guards, overflow checks, and safe math as secondary defenses.
- **Off-Chain Accuracy**: Merkle roots are computed securely off-chain with audited scripts. Incorrect roots affect claims but not treasury funds, and roots can be updated.
- **Signature Schemes**: Relies on ECDSA security; EIP-712 provides domain-bound signatures to prevent malleability and collisions.
- **Network Reliability**: Assumes uninterrupted block production without manipulation, allowing delays to function properly.

Residual risks, such as social engineering, key loss, or quantum threats, are mitigated through multisig distributions, regular audits, and upgradable contracts.
