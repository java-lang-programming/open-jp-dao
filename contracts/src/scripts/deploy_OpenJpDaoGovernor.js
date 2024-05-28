// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const VoteTokenAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
  const OpenJpDaoGovernorFactory = await ethers.getContractFactory('OpenJpDaoGovernor');
  console.log('Deploying OpenJpDaoGovernor...');
  const OpenJpDaoGovernor = await OpenJpDaoGovernorFactory.deploy(VoteTokenAddress);
  await OpenJpDaoGovernor.deployed();
  console.log('OpenJpDaoGovernor deployed to:', OpenJpDaoGovernor.address);
}

main();