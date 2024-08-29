// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const VoteTokenAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  const OpenJpDaoGovernorFactory = await ethers.getContractFactory('OpenJpDaoGovernor');
  console.log('Deploying OpenJpDaoGovernor...');
  const OpenJpDaoGovernor = await OpenJpDaoGovernorFactory.deploy(VoteTokenAddress);
  await OpenJpDaoGovernor.deployed();
  console.log('OpenJpDaoGovernor deployed to:', OpenJpDaoGovernor.address);
  const proposal_tx = await OpenJpDaoGovernor.propose(
    [VoteTokenAddress],
    [0],
    ["0x"],
    "Proposal #1: 日本語",
  );

  // console.log(proposal_tx);
  const receipt = await proposal_tx.wait(1)
  const proposalId = receipt.events[0].args.proposalId.toString();

  console.log("proposalId");
  console.log(proposalId);

  const proposalSnapshot = await OpenJpDaoGovernor.proposalSnapshot(proposalId);
  console.log("proposalSnapshot");
  console.log(proposalSnapshot);
}

main();