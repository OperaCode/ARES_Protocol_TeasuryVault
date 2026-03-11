# ARES Protocol Treasury Architecture

## Overview

The treasury execution system implements a layered, sequential pipeline for handling on‑chain assets. No action is finalized until it has passed through authentication, governance and a delay-enforced executor.

This division of responsibility removes single points of failure and makes each step transparent and auditable.

## Contracts and Responsibilities

| Contract            | Role                                       | Notes                                 |
|---------------------|--------------------------------------------|---------------------------------------|
| `TreasuryVault`     | Stores funds and executes approved calls   | No governance logic                   |
| `TimeLockExecutor`  | Queues operations, enforces delay, executes | Delay is enforced in‑contract         |
| `AresGovernor`      | Proposal lifecycle (submit, vote, queue)   | Prevents governance takeover          |
| `GuardianMultisig`  | Emergency approval/cancellation            | Distributed; cancel‑only              |
| `AuthorizationLayer`| Verifies EIP‑712 signatures and nonces     | Replay‑protected gatekeeper           |
| `MerkleDistributor` | Distributes rewards via Merkle proofs      | Independent of governance path        |


## Directory Layout

```
src/
├── core/
│   ├── TreasuryVault.sol
│   └── TimeLockExecutor.sol
├── governance/
│   ├── AresGovernor.sol
│   └── GuardianMultiSig.sol
├── modules/
│   └── MerkleDistributor.sol
├── auth/
│   └── AuthorizationLayer.sol
├── interfaces/
│   ├── ITreasuryVault.sol
│   ├── ITimelockExecutor.sol
│   ├── IAuthorizationLayer.sol
│   └── IMerkleDistributor.sol
└── libraries/
    ├── EIP712Digest.sol
    └── Operationhash.sol
```

Each top‑level folder corresponds with one functional layer of the system.

### Layer summaries

- **Core** — `TreasuryVault` (asset storage/executor) and `TimeLockExecutor` (delay logic).
- **Governance** — proposal creation, voting and emergency cancellation.
- **Auth** — signature verification and nonce tracking; sole gate before the timelock.
- **Modules** — add‑on components such as `MerkleDistributor` that operate outside the core pipeline.
- **Supporting** — shared interfaces and libraries.

## Module Separation

Every contract has a narrow and well‑defined purpose. For example:

- Vault cannot create or authorize proposals.
- Governor cannot move funds or bypass the timelock.
- Authorization layer never queues operations or touches treasury state.
- Timelock only queues/executions; it neither verifies signatures nor holds assets.
- Guardian multisig can cancel proposals but cannot execute them.

This strict separation means that breaking a single component is not enough to drain the treasury — an attacker would need to compromise multiple independent layers in sequence.

## Security Boundaries

- **TreasuryVault** sits at the innermost boundary. It treats every caller as untrusted and re‑validates that any action was approved by both the authorization layer and the timelock.
- **GuardianMultisig** is purposely asymmetric: it can cancel but not initiate treasury actions, limiting damage from a guardian compromise.
- **MerkleDistributor** is isolated from core governance. A failure there cannot affect treasury assets, and vice‑versa.

## Trust Assumptions

- Signer keys managed via GuardianMultisig/AuthorizationLayer must remain secure. If they are compromised, the timelock delay provides a window to detect and cancel malicious proposals.
- The Merkle root used by `MerkleDistributor` must be computed correctly off‑chain. A bad root affects only reward claims, not treasury security.
- We assume the EVM is correct; contracts include standard reentrancy guards and overflow checks.
