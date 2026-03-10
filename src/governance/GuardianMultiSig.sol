// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GuardianMultisig {

    address[] public guardians;

    mapping(address => bool) public isGuardian;

    uint256 public threshold;

    struct Approval {
        uint256 approvals;
        mapping(address => bool) approved;
        bool executed;
    }

    mapping(bytes32 => Approval) public approvals;

    event Approved(address guardian, bytes32 action);
    event Executed(bytes32 action);

    constructor(
        address[] memory _guardians,
        uint256 _threshold
    ) {
        require(_threshold > 0, "invalid threshold");
        require(_threshold <= _guardians.length, "threshold too high");

        for (uint256 i = 0; i < _guardians.length; i++) {

            address g = _guardians[i];

            require(g != address(0), "invalid guardian");
            require(!isGuardian[g], "duplicate guardian");

            guardians.push(g);
            isGuardian[g] = true;
        }

        threshold = _threshold;
    }

    modifier onlyGuardian() {
        require(isGuardian[msg.sender], "not guardian");
        _;
    }

    function approveAction(bytes32 actionHash)
        external
        onlyGuardian
    {
        Approval storage a = approvals[actionHash];

        require(!a.approved[msg.sender], "already approved");

        a.approved[msg.sender] = true;
        a.approvals++;

        emit Approved(msg.sender, actionHash);
    }

    function executeAction(bytes32 actionHash)
        external
        onlyGuardian
    {
        Approval storage a = approvals[actionHash];

        require(!a.executed, "already executed");
        require(a.approvals >= threshold, "insufficient approvals");

        a.executed = true;

        emit Executed(actionHash);
    }
}