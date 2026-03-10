// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../../src/core/TreasuryVault.sol";
import "../../src/core/TimeLockExecutor.sol";
import "../../src/modules/MerkleDistributor.sol";
import "../../src/auth/AuthorizationLayer.sol";
import "../../src/governance/GuardianMultiSig.sol";

contract BaseTest is Test {

    TreasuryVault vault;
    TimeLockExecutor timelock;
    MerkleDistributor distributor;
    AuthorizationLayer auth;
    GuardianMultiSig multisig;

    address governor = address(1);
    address guardian = address(2);
    address executor = address(3);
    address user = address(4);
    address attacker = address(5);

    function setUp() public virtual {

        timelock = new TimeLockExecutor(governor);

        vault = new TreasuryVault(executor);

        distributor = new MerkleDistributor(executor);

        auth = new AuthorizationLayer();

        multisig = new GuardianMultiSig();

        vm.deal(user, 10 ether);
        vm.deal(attacker, 10 ether);
    }
}