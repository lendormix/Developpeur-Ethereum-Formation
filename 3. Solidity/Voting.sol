// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    mapping (address => Voter) voters;
    WorkflowStatus workflowStatus;
    Proposal[] proposals;
    
    uint winningProposalId;

    bool definitivelyTallied;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    function getWinner() public view returns (uint) {
        require(workflowStatus == WorkflowStatus.VotesTallied, "Vote is not tallied.");
        require(definitivelyTallied, "Vote is computing, please be patient.");

        return winningProposalId;
    }

    constructor () {
        // Start directly with registering voters
        workflowStatus = WorkflowStatus.RegisteringVoters;
        definitivelyTallied = false;
    }

    function addVoter(address _address) public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Can't register new voters anymore.");
        require(!voters[_address].isRegistered, "Can't add voter twice.");

        voters[_address] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0
        });

        emit VoterRegistered(_address);
    }

    function transitionWorkflow(WorkflowStatus previousStatus, WorkflowStatus newStatus) internal {
        require(workflowStatus == previousStatus, "Operation not allowed, please see event log.");
        workflowStatus = newStatus;
        emit WorkflowStatusChange(previousStatus , newStatus);   
    }

    function startProposals() public onlyOwner {
        transitionWorkflow(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function addProposal(string memory _description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Operation not allowed, please see event log.");
        require(voters[msg.sender].isRegistered, "You 're not allowed to add a proposal.");

        proposals.push(Proposal({
                description: _description,
                voteCount: 0
            })
        );

        emit ProposalRegistered(proposals.length - 1);
    }

    function seeProposal(uint _proposalId) public view returns (string memory) {
        require(voters[msg.sender].isRegistered || msg.sender == owner(), "You 're not allowed to see proposal.");
        require(_proposalId >= 0 && _proposalId < proposals.length, "Wrong proposal id");

        return proposals[_proposalId].description;
    }

    function stopProposals() public onlyOwner {
        transitionWorkflow(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVoting() public onlyOwner {
        transitionWorkflow(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function vote(uint _proposalId) public {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "Operation not allowed, please see event log.");
        require(voters[msg.sender].isRegistered, "You 're not allowed to vote.");
        require(!voters[msg.sender].hasVoted, "You already voted.");
        require(_proposalId >= 0 && _proposalId < proposals.length, "Wrong proposal id");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;

        proposals[_proposalId].voteCount ++;

        emit Voted (msg.sender, _proposalId);
    }

    function stopVoting() public onlyOwner {
        transitionWorkflow(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function tallyVotes() public onlyOwner {
        transitionWorkflow(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        uint voteCount = 0;

        for(uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount >= voteCount) {
                // @todo what if two proposals have the same voteCount value ?
                voteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }

        // Used because whenever workflow have changed, it can be very time consuming 
        // if proposals.length is huge.
        definitivelyTallied = true;
    }

}
