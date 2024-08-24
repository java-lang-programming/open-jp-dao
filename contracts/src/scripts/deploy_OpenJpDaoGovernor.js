// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const VoteTokenAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  const OpenJpDaoGovernorFactory = await ethers.getContractFactory('OpenJpDaoGovernor');
  console.log('Deploying OpenJpDaoGovernor...');
  const OpenJpDaoGovernor = await OpenJpDaoGovernorFactory.deploy(VoteTokenAddress);
  await OpenJpDaoGovernor.deployed();
  console.log('OpenJpDaoGovernor deployed to:', OpenJpDaoGovernor.address);
}

main();