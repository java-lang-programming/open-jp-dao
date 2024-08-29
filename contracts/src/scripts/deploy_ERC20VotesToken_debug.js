// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

// Token = await ethers.getContractFactory("ERC20VotesToken");
async function main () {
  const ERC20VotesTokenFactory = await ethers.getContractFactory('ERC20VotesToken');
  console.log('Deploying ERC20VotesTokenFactory...');
  const owner = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
  const ERC20VotesToken = await ERC20VotesTokenFactory.deploy(owner);
  await ERC20VotesToken.deployed();
  console.log('ERC20VotesToken deployed to:', ERC20VotesToken.address);
}

main();