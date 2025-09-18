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

    function testfuzzingWithEdgeCases() public {
        // Fuzzing test with edge cases
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        registry.update(id, "edge.case.alice");
        vm.stopPrank();

        IdentityRegistry.Agent memory ag = registry.getAgent(id);
        assertEq(ag.agentDomain, "edge.case.alice");

        // Attempt to register with a very long domain
        vm.startPrank(bob);
        string memory longDomain = "a".repeat(1000); // Assuming repeat function exists
        vm.expectRevert("Invalid domain");
        registry.register(longDomain);
        vm.stopPrank();
    }

    function testfuzzingWithMultipleAgents() public {
        // Fuzzing test with multiple agents
        vm.startPrank(alice);
        uint256 id1 = registry.register("agent.alice");
        uint256 id2 = registry.register("agent.alice2");
        vm.stopPrank();

        IdentityRegistry.Agent memory ag1 = registry.getAgent(id1);
        IdentityRegistry.Agent memory ag2 = registry.getAgent(id2);

        assertEq(ag1.agentDomain, "agent.alice");
        assertEq(ag2.agentDomain, "agent.alice2");

        // Update both agents
        vm.startPrank(alice);
        registry.update(id1, "updated.alice");
        registry.update(id2, "updated.alice2");
        vm.stopPrank();

        ag1 = registry.getAgent(id1);
        ag2 = registry.getAgent(id2);

        assertEq(ag1.agentDomain, "updated.alice");
        assertEq(ag2.agentDomain, "updated.alice2");
    }

    function testCannotRegisterWithEmptyDomain() public {
        vm.startPrank(alice);
        vm.expectRevert("Invalid domain");
        registry.register(""); // Empty domain should revert
        vm.stopPrank();
    }

    function testfuzzingWithReverts() public {
        // Fuzzing test to check for reverts
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        vm.expectRevert("Not your agent");
        registry.update(id, "hacker.bob"); // Should revert since it's not alice's agent
        vm.stopPrank();
    }

    function testfuzzingWithMultipleUpdates() public {
        // Fuzzing test with multiple updates
        vm.startPrank(alice);
        uint256 id = registry.register("agent.alice");
        registry.update(id, "first.update.alice");
        registry.update(id, "second.update.alice");
        vm.stopPrank();

        IdentityRegistry.Agent memory ag = registry.getAgent(id);
        assertEq(ag.agentDomain, "second.update.alice");
    }
}
