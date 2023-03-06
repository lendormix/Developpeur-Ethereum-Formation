const Voting = artifacts.require("Voting");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');


contract("Voting", accounts => {

  const _owner = accounts[0];
  const _voter = accounts[1];
  
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

});

