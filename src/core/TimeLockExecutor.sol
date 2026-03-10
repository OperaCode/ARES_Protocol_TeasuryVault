// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

contract TimelockExecutor is ReentrancyGuard {
    uint256 public constant MIN_DELAY = 48 hours;
    uint256 public constant GRACE_PERIOD = 14 days;

    address public immutable vault;
    address public immutable governor;
    address public immutable guardian;

    uint256 public nonce;

    mapping(address => bool) public approvedTargets;

    struct Operation {
        address target;
        uint256 value;
        bytes data;
        uint256 eta;
        uint256 nonce; // for traceability
        bool executed;
        bool cancelled;
    }

    mapping(bytes32 => Operation) public operations;

    event Queued(
        bytes32 indexed opHash,
        address indexed target,
        uint256 eta,
        uint256 nonce
    );
    event Executed(bytes32 indexed opHash);
    event Cancelled(bytes32 indexed opHash);
    event TargetApproved(address indexed target);
    event TargetRevoked(address indexed target);

    error NotGovernor();
    error NotGuardian();
    error ZeroAddress();
    error TargetNotApproved(address target);
    error AlreadyQueued(bytes32 opHash);
    error NotQueued(bytes32 opHash);
    error AlreadyExecuted(bytes32 opHash);
    error AlreadyCancelled(bytes32 opHash);
    error TooEarly(uint256 eta, uint256 current);
    error Expired(bytes32 opHash);
    error ExecutionFailed();

    modifier onlyGovernor() {
        if (msg.sender != governor) revert NotGovernor();
        _;
    }

    modifier onlyGuardian() {
        if (msg.sender != guardian) revert NotGuardian();
        _;
    }

    constructor(address _vault, address _governor, address _guardian) {
        if (_vault == address(0)) revert ZeroAddress();
        if (_governor == address(0)) revert ZeroAddress();
        if (_guardian == address(0)) revert ZeroAddress();

        vault = _vault;
        governor = _governor;
        guardian = _guardian;

        // Vault is approved by default — it is the only fund-moving target
        approvedTargets[_vault] = true;
        emit TargetApproved(_vault);
    }

    function approveTarget(address target) external {
        if (msg.sender != address(this)) revert NotGovernor();
        if (target == address(0)) revert ZeroAddress();
        approvedTargets[target] = true;
        emit TargetApproved(target);
    }

    function revokeTarget(address target) external {
        if (msg.sender != address(this)) revert NotGovernor();
        approvedTargets[target] = false;
        emit TargetRevoked(target);
    }

    function queue(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlyGovernor returns (bytes32 opHash) {
        if (target == address(0)) revert ZeroAddress();
        if (!approvedTargets[target]) revert TargetNotApproved(target);

        uint256 currentNonce = nonce++;
        opHash = keccak256(abi.encode(target, value, data, currentNonce));

        // Should never collide given nonce, but guard anyway
        if (operations[opHash].eta != 0) revert AlreadyQueued(opHash);

        uint256 eta = block.timestamp + MIN_DELAY;

        operations[opHash] = Operation({
            target: target,
            value: value,
            data: data,
            eta: eta,
            nonce: currentNonce,
            executed: false,
            cancelled: false
        });

        emit Queued(opHash, target, eta, currentNonce);
    }

    // -------------------------------------------------------------------------
    // Cancel
    // -------------------------------------------------------------------------

    /// @notice Guardian vetoes a queued operation.
    /// @dev    Guardian can ONLY cancel — cannot queue or execute.
    ///         Non-participation has zero effect. Griefing attack closed.
    function cancel(bytes32 opHash) external onlyGuardian {
        Operation storage op = operations[opHash];

        if (op.eta == 0) revert NotQueued(opHash);
        if (op.executed) revert AlreadyExecuted(opHash);
        if (op.cancelled) revert AlreadyCancelled(opHash);

        op.cancelled = true;
        emit Cancelled(opHash);
    }

    // -------------------------------------------------------------------------
    // Execute
    // -------------------------------------------------------------------------

    /// @notice Executes a queued operation after the delay has elapsed.
    /// @dev    CEI pattern: state marked executed BEFORE external call.
    ///         nonReentrant as second line of defense.
    ///         Target must be in approvedTargets — arbitrary calls blocked.
    function execute(bytes32 opHash) external nonReentrant {
        Operation storage op = operations[opHash];

        // --- CHECKS ---
        if (op.eta == 0) revert NotQueued(opHash);
        if (op.executed) revert AlreadyExecuted(opHash);
        if (op.cancelled) revert AlreadyCancelled(opHash);
        if (block.timestamp < op.eta) revert TooEarly(op.eta, block.timestamp);
        if (block.timestamp > op.eta + GRACE_PERIOD) revert Expired(opHash);

        // Double-check target is still approved at execution time
        // A target could be revoked between queue and execute
        if (!approvedTargets[op.target]) revert TargetNotApproved(op.target);

        // --- EFFECTS ---
        // State update BEFORE external call.
        // Reentrant call finds op.executed == true and reverts immediately.
        op.executed = true;
        emit Executed(opHash);

        // --- INTERACTIONS ---
        (bool success, ) = op.target.call{value: op.value}(op.data);
        if (!success) {
            // Rollback so the operation can be retried after diagnosing failure
            op.executed = false;
            revert ExecutionFailed();
        }
    }

    // -------------------------------------------------------------------------
    // Views
    // -------------------------------------------------------------------------

    function getOperation(
        bytes32 opHash
    ) external view returns (Operation memory) {
        return operations[opHash];
    }

    /// @notice Returns the current human-readable state of an operation.
    function getState(bytes32 opHash) external view returns (string memory) {
        Operation storage op = operations[opHash];
        if (op.eta == 0) return "Nonexistent";
        if (op.cancelled) return "Cancelled";
        if (op.executed) return "Executed";
        if (block.timestamp > op.eta + GRACE_PERIOD) return "Expired";
        if (block.timestamp >= op.eta) return "Ready";
        return "Queued";
    }

    function hashOp(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 _nonce
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(target, value, data, _nonce));
    }
}
