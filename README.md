# ARES Protocol Treasury System

This is a secure, modular treasury system built from the ground up for the ARES Protocol. It handles large amounts of assets at about $500 million — while protecting against common DeFi pitfalls like governance hijacks, signature replays, flash loan tricks, and timelock skips. We use layered defenses and separate modules to keep the project safe, flexible and clean.

## What's the Problem?

Old-school treasury setups are often full of holes. We've seen too many exploits in governance, approvals, delays, and payouts. ARES needed something custom that locks down the whole process: proposing actions, getting crypto approvals, waiting out delays, handling claims, and blocking attacks.

## The Project Approach

We broke it down into five key parts:

1. **Proposal System**: Lets anyone suggest treasury moves (like sending funds or calling contracts), but holds them back from instant action.
2. **Crypto Authorization**: Relies on EIP-712 signatures with built-in counters to stop replays, tied to the specific chain and contract.
3. **Delayed Execution**: A queue system with required waits to fight off quick attacks and reentrancy.
4. **Reward Payouts**: Uses Merkle trees for efficient claims to thousands of people, with checks to prevent double-dipping.
5. **Governance Protections**: Timelocks and multisig stops for flash loans, big drains, and trolling.

## How it is Built

The code is organized cleanly:

```
src/
├── core/
│   ├── TreasuryVault.sol      # Holds funds and runs actions
│   └── TimeLockExecutor.sol   # Manages delays and queues
├── governance/
│   ├── AresGovernor.sol       # Handles proposals
│   └── GuardianMultiSig.sol  # Emergency overrides
├── auth/
│   └── AuthorizationLayer.sol # Checks signatures
├── modules/
│   └── MerkleDistributor.sol  # Processes claims
├── interfaces/                # Contract definitions
├── libraries/                 # Helpers like EIP712 and hashing
```

Each piece stands alone but still retains parts of the general archetecture: core for execution, governance for ideas, auth for checks, modules for extras.

See [ARCHITECTURE.md](ARCHITECTURE.md) for the deep dive .

## Main Features

- **Full Lifecycle**: Propose → Approve → Queue → Wait → Execute
- **No Replays**: Signatures with nonces block reuse anywhere
- **Safe Delays**: At least 1 hour to stop flash attacks
- **Merkle Claims**: Gas-friendly payouts for big groups
- **Multisig Backup**: Team can cancel bad moves
- **Thorough Testing**: Covers normal flows plus 8+ attack scenarios

## Quick Start

### What You Need

- Foundry (for Solidity ^0.8.20)
- Git

### Setup

```bash
git clone https://github.com/OperaCode/ARES_Protocol_TeasuryVault.git
cd ARES_Protocol_TeasuryVault
forge install
```

### Build and Test

```bash
forge build
forge test  # to run all tests: basic tests, exploits.
```


## How to Use

1. **Propose**: Hit `AresGovernor.createProposal(target, value, data)` to suggest something.
2. **Approve**: Sign off-chain with EIP-712, then call `authorizeAndQueue(proposalId, signature)`.
3. **Queue It**: Goes into the timelock with a delay.
4. **Execute**: Wait out the time, then `TimeLockExecutor.execute()` does the work.
5. **Claim Rewards**: Prove your spot in the Merkle tree and call `MerkleDistributor.claim()`.

For the step-by-step rules, see [PROTOCOL.md](PROTOCOL.md).

## Security First

The project guards against reentrancy, replays, double claims, bad executions, delay cheats, and griefing. Dive into [SECURITY.md](SECURITY.md) for the full breakdown, including fixes and what risks remain.

## Testing

- **Unit Testing(functional tests)**: Proposing, approving, queuing, executing, claiming.
- **Exploit Attacks Tests**: Tests for reentrancy, replays, early runs, double claims, and more (8+ bad cases).
- Run `forge test --match-contract Exploit` to see the defenses in action.


## License

MIT. This is our own build, not copied from others.
