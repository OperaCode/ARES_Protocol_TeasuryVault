// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;


// import {BaseTest} from "../utility/BaseTest.t.sol";



// contract FullFlowTest is BaseTest {

//     function testFullTreasuryExecutionFlow() public {

//         vm.deal(address(vault), 10 ether);

//         assertEq(address(vault).balance, 10 ether);

//         bytes memory data =
//             abi.encodeWithSignature(
//                 "transferETH(address,uint256)",
//                 user,
//                 1 ether
//             );

//         bytes32 operationHash =
//             keccak256(
//                 abi.encode(
//                     address(vault),
//                     0,
//                     data
//                 )
//             );

//         // governor queues operation
//         vm.prank(governor);
//         timelock.queue(operationHash);

//         (uint256 executeAfter, bool executed) =
//             timelock.operations(operationHash);

//         assertGt(executeAfter, block.timestamp);
//         assertFalse(executed);

//         // simulate timelock delay
//         vm.warp(block.timestamp + 1 hours);

//         // governor executes
//         vm.prank(governor);
//         timelock.execute(
//             operationHash,
//             address(vault),
//             0,
//             data
//         );

//         // verify transfer occurred
//         assertEq(user.balance, 11 ether);
//         assertEq(address(vault).balance, 9 ether);
//     }
// }