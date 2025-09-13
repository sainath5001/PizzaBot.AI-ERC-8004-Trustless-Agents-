// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ValidationRegistry {
    struct Validation {
        uint256 validatorId;
        uint256 serverId;
        bytes32 dataHash;
        uint8 response; // 0 = fail, 100 = pass
        bool completed;
    }

    mapping(bytes32 => Validation) public validations;

    event ValidationRequested(uint256 validatorId, uint256 serverId, bytes32 dataHash);
    event ValidationResponded(uint256 validatorId, uint256 serverId, bytes32 dataHash, uint8 response);

    function requestValidation(uint256 validatorId, uint256 serverId, bytes32 dataHash) external {
        validations[dataHash] = Validation(validatorId, serverId, dataHash, 0, false);
        emit ValidationRequested(validatorId, serverId, dataHash);
    }

    function respondValidation(bytes32 dataHash, uint8 response) external {
        Validation storage v = validations[dataHash];
        require(!v.completed, "Already validated");
        v.response = response;
        v.completed = true;
        emit ValidationResponded(v.validatorId, v.serverId, dataHash, response);
    }
}
