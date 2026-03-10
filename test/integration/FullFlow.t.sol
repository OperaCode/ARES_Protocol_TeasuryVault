// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "../utils/BaseTest.t.sol";

// contract FullFlowTest is BaseTest {

//     function testProposalLifecycle() public {

//         vm.startPrank(admin);

//         uint id = governor.createProposal(
//             address(vault),
//             1 ether,
//             ""
//         );

//         vm.stopPrank();

//         assertEq(id,1);
//     }
// }