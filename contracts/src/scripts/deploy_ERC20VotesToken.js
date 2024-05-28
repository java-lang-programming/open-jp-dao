// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const ERC20VotesTokenFactory = await ethers.getContractFactory('ERC20VotesToken');
  console.log('Deploying ERC20VotesTokenFactory...');
  const ERC20VotesToken = await ERC20VotesTokenFactory.deploy();
  await ERC20VotesToken.deployed();
  console.log('ERC20VotesToken deployed to:', ERC20VotesToken.address);
}

main();