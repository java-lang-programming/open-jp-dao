// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const EmployeeAuthorityWorkerNFTFactory = await ethers.getContractFactory('EmployeeAuthorityWorkerNFT');
  console.log('Deploying EmployeeAuthorityWorkerNFT...');
  const EmployeeAuthorityWorkerNFT = await upgrades.deployProxy(EmployeeAuthorityWorkerNFTFactory, ["EmployeeAuthorityWorkerNFT", "EAWNFT"]);
  [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
  // デプロイ完了まで待機
  await EmployeeAuthorityWorkerNFT.deployed();
  console.log('EmployeeAuthorityWorkerNFT deployed to:', EmployeeAuthorityWorkerNFT.address);
  console.log('owner is :', owner.address);
}

main();