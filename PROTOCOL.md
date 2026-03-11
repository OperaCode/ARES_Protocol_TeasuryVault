# Protocol Specification

## Overview

The ARES Protocol defines a secure, sequential process for managing treasury operations on-chain. This specification outlines the lifecycle from proposal initiation to final execution, incorporating cryptographic authorization, time delays, and modular validations to ensure only legitimate actions proceed.

## Proposal Creation

Treasury operations begin with proposal creation in the AresGovernor contract. Any address can submit a proposal by calling `createProposal(address target, uint256 value, bytes data)`, which:

- Generates a unique proposal ID using an incremental counter.
- Computes an operation hash via `OperationHash.hashOperation(target, value, data, proposalId, block.chainid)`.
- Stores the proposal with proposer address, target details, operation hash, and flags for queued and executed states (initially false).
- Emits a `ProposalCreated` event for transparency.

No eligibility checks occur here; the focus is on recording the intent. The proposal is now ready for authorization.

## Authorization

Authorization uses off-chain EIP-712 signatures verified on-chain in the AuthorizationLayer. To authorize, a signer calls `verifyAuthorization(bytes32 operationHash, bytes signature)`, which:

- Builds an EIP-712 digest incorporating the operation hash, signer's nonce, and domain separator tied to the contract and chain.
- Recovers the signer from the signature and confirms it matches the caller.
- Increments the nonce to prevent signature reuse.
- Returns success if valid.

A single valid signature enables queueing; no threshold is enforced on-chain.

## Queueing

Authorized proposals are queued through `AresGovernor.authorizeAndQueue(uint256 proposalId, bytes signature)`:

- Fetches the proposal and ensures it's not already queued.
- Verifies the signature via AuthorizationLayer.
- Calls `TimeLockExecutor.queue(operationHash)` to schedule execution.
- Marks the proposal as queued and emits `ProposalQueued`.

In TimeLockExecutor, `queue` sets `executeAfter = block.timestamp + DELAY` (1 hour constant), ensuring a delay before execution.

## Execution

Execution occurs after the delay via `TimeLockExecutor.execute(bytes32 operationHash, address target, uint256 value, bytes data)`:

- Confirms the operation is queued and not executed.
- Verifies the timestamp has passed `executeAfter`.
- Executes the call to the target with value and data.
- Marks as executed and emits `OperationExecuted` on success.

TreasuryVault restricts calls to the executor (timelock), enforcing access control.

## Cancellation

Cancellation is not supported on-chain in the current design. Queued operations cannot be cancelled directly.

- GuardianMultiSig allows emergency approvals but lacks integration for cancellations.
- Cancellations require governance upgrades or off-chain coordination.

This limitation may be addressed in future updates to enhance flexibility.
