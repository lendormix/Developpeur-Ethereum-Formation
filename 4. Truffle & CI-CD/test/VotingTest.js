const Voting = artifacts.require("Voting");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');


contract("Voting", accounts => {

  const _owner = accounts[0];
  const _voter = accounts[1];
  const _another_voter = accounts[2];
  
  let votingInstance;

  beforeEach(async function() {
    votingInstance = await Voting.new({from: _owner});
  });

  it("...voter added", async () => {
    const addVoter = await votingInstance.addVoter(_voter, {from: _owner});

    expectEvent(addVoter, 'VoterRegistered', {voterAddress: _voter});
  });

  it("...voter can’t be added twice", async () => {
    await votingInstance.addVoter(_voter, {from: _owner});

    await expectRevert(
      votingInstance.addVoter(_voter, {from: _owner}),
      "Can't add voter twice."
    );
  });

  it("...starts proposals ", async () => {
    const proposalStarted = await votingInstance.startProposals( {from: _owner});

    expectEvent(proposalStarted, 'WorkflowStatusChange', {
      previousStatus: new BN(0), // Voting.WorkflowStatus.RegisteringVoters
      newStatus: new BN(1) // Voting.WorkflowStatus.ProposalsRegistrationStarted
    });

  });

  it("...can’t add another voter when proposal is started", async () => {
    await votingInstance.addVoter(_voter, {from: _owner});
    await votingInstance.startProposals( {from: _owner});

    await expectRevert(
      votingInstance.addVoter(_another_voter, {from: _owner}),
      "Can't register new voters anymore."
    );
  });


});

