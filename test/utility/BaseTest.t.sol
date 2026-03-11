// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {TreasuryVault} from "../../src/core/TreasuryVault.sol";
import {TimelockExecutor} from "../../src/core/TimeLockExecutor.sol";
import {MerkleDistributor} from "../../src/modules/MerkleDistributor.sol";
import {AuthorizationLayer} from "../../src/auth/AuthorizationLayer.sol";
import {GuardianMultisig} from "../../src/governance/GuardianMultiSig.sol";

contract BaseTest is Test {

    TreasuryVault vault;
    TimelockExecutor timelock;
    MerkleDistributor distributor;
    AuthorizationLayer auth;
    GuardianMultisig multisig;
    address governor = address(1);
    address guardian = address(2);
    address executor = address(3);
    address user = address(4);
    address attacker = address(5);

    function setUp() public virtual {

        timelock = new TimelockExecutor(governor);

        vault = new TreasuryVault(executor);

        distributor = new MerkleDistributor(executor);

        auth = new AuthorizationLayer();

        // multisig = new GuardianMultisig();
            address[] memory guardians = new address[](1);
        guardians[0] = guardian;
        multisig = new GuardianMultisig(guardians, 1);


        vm.deal(user, 10 ether);
        vm.deal(attacker, 10 ether);
    }

    // --- helper helpers --------------------------------------------------

    /// @dev warp the block.timestamp past the currently configured min delay
    /// in the timelock, plus a little extra to avoid edge-case equality.
    function _warpPastDelay() internal {
        // use the timedelay constant defined in the timelock contract
        vm.warp(block.timestamp + timelock.DELAY() + 1);
    }

}
