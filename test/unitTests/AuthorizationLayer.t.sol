// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "../utility/BaseTest.t.sol";

// contract AuthorizationLayerTest is BaseTest {

//     function testNonceIncrements() public {

//         uint256 nonceBefore = auth.nonces(user);

//         vm.prank(user);

//         auth.consumeNonce();

//         uint256 nonceAfter = auth.nonces(user);

//         assertEq(nonceAfter, nonceBefore + 1);
//     }

//     function testInvalidSignatureReverts() public {

//         bytes32 hash = keccak256("message");

//         bytes memory fakeSignature = hex"1234";

//         vm.expectRevert();

//         auth.verifySignature(user, hash, fakeSignature);
//     }

// }