// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITimelockExecutor} from "../interfaces/ITimelockExecutor.sol";
import {IVotesToken} from "../interfaces/IVotesToken.sol";
import {IAuthorizationLayer} from "../interfaces/IAuthorizationLayer.sol";
import {OperationHash} from "../libraries/OperationHash.sol";

contract AresGovernor {
    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        bytes32 operationHash;
        bool queued;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    IVotesToken public governanceToken;
    ITimelockExecutor public timelock;
    IAuthorizationLayer public authLayer;

    uint256 public proposalCount;

    uint256 public votingDelay = 1 days;
    uint256 public votingPeriod = 3 days;

    uint256 public quorumPercent = 4;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(uint256 indexed id, address proposer, address target);
    event VoteCast(
        address voter,
        uint256 proposalId,
        bool support,
        uint256 weight
    );
    event ProposalQueued(uint256 proposalId);
    event ProposalExecuted(uint256 proposalId);

    constructor(address _token, address _timelock, address _auth) {
        governanceToken = IVotesToken(_token);
        timelock = ITimelockExecutor(_timelock);
        authLayer = IAuthorizationLayer(_auth);
    }

    function propose(
        address target,
        uint256 value,
        bytes calldata data
    ) external returns (uint256 id) {
        id = ++proposalCount;

        bytes32 opHash = OperationHash.hashOperation(
            target,
            value,
            data,
            id,
            block.chainid
        );

        proposals[id] = Proposal({
            proposer: msg.sender,
            target: target,
            value: value,
            data: data,
            operationHash: opHash,
            queued: false,
            voteStart: block.timestamp + votingDelay,
            voteEnd: block.timestamp + votingDelay + votingPeriod,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });

        emit ProposalCreated(id, msg.sender, target);
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];

        require(block.timestamp >= p.voteStart, "voting not started");
        require(block.timestamp <= p.voteEnd, "voting ended");
        require(!hasVoted[proposalId][msg.sender], "already voted");

        uint256 weight = governanceToken.getPastVotes(msg.sender, p.voteStart);

        require(weight > 0, "no voting power");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            p.forVotes += weight;
        } else {
            p.againstVotes += weight;
        }

        emit VoteCast(msg.sender, proposalId, support, weight);
    }

    function quorum() public view returns (uint256) {
        return (governanceToken.totalSupply() * quorumPercent) / 100;
    }

    function proposalPassed(uint256 id) public view returns (bool) {
        Proposal storage p = proposals[id];

        if (block.timestamp <= p.voteEnd) return false;

        return p.forVotes > p.againstVotes && p.forVotes >= quorum();
    }

    function queue(uint256 id) external {
        require(proposalPassed(id), "proposal failed");

        Proposal storage p = proposals[id];

        bytes memory data = p.data;

        bytes32 operation = OperationHash.hashOperation(
            p.target,
            p.value,
            data,
            id,
            block.chainid
        );

        timelock.queue(operation);
        p.queued = true;

        emit ProposalQueued(id);
    }

    function authorizeAndQueue(
        uint256 proposalId,
        bytes memory signature
    ) external {
        Proposal storage p = proposals[proposalId];

        require(!p.queued, "already queued");

        bool valid = authLayer.verifyAuthorization(p.operationHash, signature);

        require(valid, "authorization failed");

        timelock.queue(p.operationHash);

        p.queued = true;

        emit ProposalQueued(proposalId);
    }

    function execute(uint256 id) external {
        Proposal storage p = proposals[id];

        require(p.queued, "not queued");
        require(!p.executed, "already executed");

        bytes memory data = p.data;

        bytes32 operation = OperationHash.hashOperation(
            p.target,
            p.value,
            data,
            id,
            block.chainid
        );

        timelock.execute(operation, p.target, p.value, data);

        p.executed = true;

        emit ProposalExecuted(id);
    }
}
