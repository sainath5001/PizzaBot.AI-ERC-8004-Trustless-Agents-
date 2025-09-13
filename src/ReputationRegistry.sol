// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReputationRegistry {
    struct Feedback {
        uint256 fromAgentId;
        uint256 toAgentId;
        uint8 rating; // 0-100
    }

    Feedback[] public feedbacks;

    event FeedbackGiven(uint256 fromAgentId, uint256 toAgentId, uint8 rating);

    function giveFeedback(uint256 fromId, uint256 toId, uint8 rating) external {
        require(rating <= 100, "Invalid rating");
        feedbacks.push(Feedback(fromId, toId, rating));
        emit FeedbackGiven(fromId, toId, rating);
    }

    function getFeedbackCount() external view returns (uint256) {
        return feedbacks.length;
    }
}
