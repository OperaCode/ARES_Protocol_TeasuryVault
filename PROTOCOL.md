Treasury Action Lifecycle
## Proposal Creation
A governance participant initiates a treasury action by calling AresGovernor. The proposal MUST specify: a unique operation identifier derived via OperationHash.sol, the target contract address, calldata, value, and the proposer's address.
Upon submission, AresGovernor verifies that the proposer meets minimum participation requirements. The proposal is recorded with status PENDING and its content is immutable after submission.
Actor: governance participant → AresGovernor
State transition: ∅ → PENDING

## Approval
With the proposal in PENDING status, authorized signers submit EIP-712 structured signatures to AuthorizationLayer. Each signature MUST cover: the operation hash (from OperationHash.sol), the proposal content hash, the signer's current nonce, and the chain ID and AuthorizationLayer address.
AuthorizationLayer validates each signature via EIP712Digest.sol and increments the signer's nonce on acceptance. Approvals accumulate until the required threshold is met, at which point the proposal transitions to APPROVED. A proposal that does not reach threshold within the approval window transitions to EXPIRED.
Actor: authorized signers → AuthorizationLayer
State transition: PENDING → APPROVED (threshold met) or PENDING → EXPIRED (timeout)

## Queueing
An APPROVED proposal is submitted to TimelockExecutor for queueing. TimelockExecutor records the operation hash alongside the enqueue timestamp T_enqueue. The proposal transitions to QUEUED.
The mandatory delay Δ begins at T_enqueue. The operation may not be executed before T_enqueue + Δ. The value of Δ is a governance-controlled parameter subject to a protocol minimum. Each operation hash may only be enqueued once — re-enqueuing reverts.
Actor: authorized caller → TimelockExecutor
State transition: APPROVED → QUEUED

## Execution
Once block.timestamp ≥ T_enqueue + Δ, an authorized caller submits the operation for execution. TimelockExecutor confirms the delay has elapsed and delegates to TreasuryVault.
TreasuryVault independently re-validates: (a) the operation has QUEUED status in TimelockExecutor, (b) a valid authorization record exists in AuthorizationLayer, and (c) the delay has been satisfied. If all checks pass, the vault executes the operation atomically and transitions the proposal to EXECUTED.
If execution reverts, the proposal remains QUEUED and may be retried within grace period Ω. A proposal not executed within T_enqueue + Δ + Ω transitions to EXPIRED.
Actor: authorized caller → TimelockExecutor → TreasuryVault
State transition: QUEUED → EXECUTED (success) or QUEUED → EXPIRED (grace period lapsed)

## Cancellation
Any proposal in a non-terminal state (PENDING, APPROVED, or QUEUED) may be cancelled. Cancellation may be triggered by GuardianMultisig for emergency intervention, or by the original proposer via AresGovernor. Cancellation is immediate, removes the operation from TimelockExecutor's queue if present, and transitions the proposal to CANCELLED.
A cancelled proposal may not be re-queued or executed. Terminal states (EXECUTED, EXPIRED) may not be cancelled.
Actor: GuardianMultisig or original proposer → AresGovernor
State transition: PENDING | APPROVED | QUEUED → CANCELLED

## State Transition Summary
                       ┌──────────────────────────────────────┐
                       │              CANCELLED                │
                       └──────────────────────────────────────┘
                          ↑               ↑               ↑
                    [Guardian /      [Guardian /     [Guardian /
                     Proposer]        Proposer]       Proposer]
                          │               │               │
[AresGovernor]            │               │               │
      │ submit             │               │               │
      ▼                    │               │               │
  PENDING ──[AuthLayer]──→ APPROVED ──[Timelock]──→ QUEUED ──[Vault]──→ EXECUTED
      │                                               │
  [Timeout]                                     [Grace period]
      │                                               │
      ▼                                               ▼
   EXPIRED                                         EXPIRED

## Test Coverage Map
test/
├── utils/
│   └── BaseTest.t.sol              — shared fixtures and helpers
│
├── unit/
│   ├── TreasuryVault.t.sol         — vault execution and re-validation logic
│   ├── TimelockExecutor.t.sol      — delay enforcement and queue state
│   ├── AresGovernor.t.sol          — proposal lifecycle and state transitions
│   ├── GuardianMultisig.t.sol      — cancellation authority and threshold logic
│   ├── AuthorizationLayer.t.sol    — signature verification and nonce registry
│   └── MerkleDistributor.t.sol     — proof verification and claim registry
│
├── integration/
│   └── FullFlow.t.sol              — end-to-end pipeline from proposal to execution
│
└── exploit/
    ├── ReentrancyAttack.t.sol      — vault reentrancy guard (§ Attack 6)
    ├── ReplayAttack.t.sol          — nonce and cross-chain replay (§ Attack 1)
    ├── FlashLoanGovernance.t.sol   — timelock defense against flash-loan voting (§ Attack 2)
    ├── DoubleClaim.t.sol           — Merkle claim registry enforcement (§ Attack 5)
    ├── InvalidSignature.t.sol      — malformed and forged signature rejection (§ Attack 1)
    ├── PrematureExecution.t.sol    — delay enforcement before execution (§ Attack 3)
    ├── ProposalReplay.t.sol        — terminal state enforcement (§ Attack 4)
    └── UnauthorizedExecution.t.sol — vault access control (§ Attack 3)

