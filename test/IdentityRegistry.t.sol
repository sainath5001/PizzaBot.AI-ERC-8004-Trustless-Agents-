// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/IdentityRegistry.sol";

contract IdentityRegistryTest is Test {
    IdentityRegistry registry;

    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        registry = new IdentityRegistry();
    }

    function testRegisterNewAgent() public {
        vm.prank(alice);
        uint256 id = registry.register("agent.alice");

        IdentityRegistry.Agent memory ag = registry.getAgent(id);

        assertEq(ag.agentId, id);
        assertEq(ag.agentDomain, "agent.alice");
        assertEq(ag.agentAddress, alice);
    }

    function testCannotRegisterTwice() public {
        vm.startPrank(alice);
        registry.register("agent.alice");
        vm.expectRevert("Already registered");
        registry.register("agent.alice2");
        vm.stopPrank();
    }

    function testUpdateAgentDomain() public {
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        registry.update(id, "updated.alice");
        vm.stopPrank();

        IdentityRegistry.Agent memory ag = registry.getAgent(id);
        assertEq(ag.agentDomain, "updated.alice");
    }

    function testCannotUpdateIfNotOwner() public {
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert("Not your agent");
        registry.update(id, "hacker.bob");
    }

    function testfuzzing() public {
        // Fuzzing test to check for unexpected behavior
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        registry.update(id, "fuzzed.alice");
        vm.stopPrank();

        IdentityRegistry.Agent memory ag = registry.getAgent(id);
        assertEq(ag.agentDomain, "fuzzed.alice");

        // Attempt to register a new agent with the same address
        vm.startPrank(bob);
        uint256 bobId = registry.register("agent.bob");
        assertEq(bobId, 1); // Should be a new ID since bob is different
        vm.stopPrank();
    }

    function testfuzzingWithInvalidData() public {
        // Fuzzing test with invalid data
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        vm.expectRevert("Invalid domain");
        registry.update(id, ""); // Empty domain should revert
        vm.stopPrank();
    }
}
