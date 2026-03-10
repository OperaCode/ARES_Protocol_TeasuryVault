// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../auth/AuthorizationLayer.sol";
import "../libraries/OperationHash.sol";
import "../interfaces/ITimelockExecutor.sol";

contract AresGovernor {

    using OperationHash for address;

    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        bytes32 operationHash;
        bool queued;
        bool executed;
    }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;

    AuthorizationLayer public authLayer;
    ITimelockExecutor public timelock;

    event ProposalCreated(uint256 id, bytes32 operationHash);
    event ProposalQueued(uint256 id);

    constructor(
        address _authLayer,
        address _timelock
    ) {
        authLayer = AuthorizationLayer(_authLayer);
        timelock = ITimelockExecutor(_timelock);
    }

    function createProposal(
        address target,
        uint256 value,
        bytes calldata data
    )
        external
        returns (uint256 id)
    {
        id = ++proposalCount;

        bytes32 opHash =
            OperationHash.hashOperation(
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
            executed: false
        });

        emit ProposalCreated(id, opHash);
    }

    function authorizeAndQueue(
        uint256 proposalId,
        bytes calldata signature
    )
        external
    {
        Proposal storage p = proposals[proposalId];

        require(!p.queued, "already queued");

        bool valid =
            authLayer.verifyAuthorization(
                p.operationHash,
                signature
            );

        require(valid, "authorization failed");

        timelock.queue(p.operationHash);

        p.queued = true;

        emit ProposalQueued(proposalId);
    }
}