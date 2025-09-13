// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ValidationRegistry.sol";

contract ValidationRegistryTest is Test {
    ValidationRegistry val;

    uint256 validatorId = 1;
    uint256 serverId = 10;
    bytes32 dataHash = keccak256("test-data");

    function setUp() public {
        val = new ValidationRegistry();
    }

    function testRequestValidation() public {
        val.requestValidation(validatorId, serverId, dataHash);

        (uint256 vId, uint256 sId, bytes32 hash, uint8 response, bool completed) = val.validations(dataHash);

        assertEq(vId, validatorId);
        assertEq(sId, serverId);
        assertEq(hash, dataHash);
        assertEq(response, 0);
        assertEq(completed, false);
    }

    function testRespondValidation() public {
        val.requestValidation(validatorId, serverId, dataHash);
        val.respondValidation(dataHash, 100);

        (,,, uint8 response, bool completed) = val.validations(dataHash);

        assertEq(response, 100);
        assertEq(completed, true);
    }

    function testCannotRespondTwice() public {
        val.requestValidation(validatorId, serverId, dataHash);
        val.respondValidation(dataHash, 50);

        vm.expectRevert("Already validated");
        val.respondValidation(dataHash, 80);
    }
}
