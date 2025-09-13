// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IdentityRegistry {
    struct Agent {
        uint256 agentId;
        string agentDomain;
        address agentAddress;
    }

    uint256 public nextId = 1;
    mapping(uint256 => Agent) public agents;
    mapping(address => uint256) public addressToId;

    event AgentRegistered(uint256 agentId, string agentDomain, address agentAddress);
    event AgentUpdated(uint256 agentId, string agentDomain, address agentAddress);

    function register(string memory domain) external returns (uint256) {
        require(addressToId[msg.sender] == 0, "Already registered");
        uint256 agentId = nextId++;
        agents[agentId] = Agent(agentId, domain, msg.sender);
        addressToId[msg.sender] = agentId;

        emit AgentRegistered(agentId, domain, msg.sender);
        return agentId;
    }

    function update(uint256 agentId, string memory newDomain) external {
        Agent storage ag = agents[agentId];
        require(ag.agentAddress == msg.sender, "Not your agent");
        ag.agentDomain = newDomain;

        emit AgentUpdated(agentId, newDomain, msg.sender);
    }

    function getAgent(uint256 agentId) external view returns (Agent memory) {
        return agents[agentId];
    }
}
