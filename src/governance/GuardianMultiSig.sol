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
        require(_threshold > 0);
        require(_threshold <= _guardians.length);

        for(uint i=0;i<_guardians.length;i++){

            address g = _guardians[i];

            require(!isGuardian[g]);
            require(g != address(0));

            guardians.push(g);
            isGuardian[g] = true;
        }

        threshold = _threshold;
    }

    // modifier onlyGuardian(){
    //     require(isGuardian[msg.sender], "not guardian");
    //     _;
    // }

     modifier onlyGuardian() {
        require(isGuardian[msg.sender], "not guardian");
        _;
    }
    function approveAction(bytes32 actionHash)
        external
        onlyGuardian
    {
        Approval storage a = approvals[actionHash];

        require(!a.approved[msg.sender]);

        a.approved[msg.sender] = true;
        a.approvals++;

        emit Approved(msg.sender, actionHash);
    }

    function executeAction(bytes32 actionHash)
        external
        onlyGuardian
    {
        Approval storage a = approvals[actionHash];

        require(!a.executed);
        require(a.approvals >= threshold);

        a.executed = true;

        emit Executed(actionHash);
    }
}