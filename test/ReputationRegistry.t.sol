// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ReputationRegistry.sol";

contract ReputationRegistryTest is Test {
    ReputationRegistry rep;

    function setUp() public {
        rep = new ReputationRegistry();
    }

    function testGiveFeedback() public {
        rep.giveFeedback(1, 2, 90);

        (uint256 fromId, uint256 toId, uint8 rating) = rep.feedbacks(0);
        assertEq(fromId, 1);
        assertEq(toId, 2);
        assertEq(rating, 90);
    }

    function testCannotGiveInvalidFeedback() public {
        vm.expectRevert("Invalid rating");
        rep.giveFeedback(1, 2, 120);
    }

    function testFeedbackCountIncreases() public {
        assertEq(rep.getFeedbackCount(), 0);
        rep.giveFeedback(1, 2, 50);
        assertEq(rep.getFeedbackCount(), 1);
    }
}
