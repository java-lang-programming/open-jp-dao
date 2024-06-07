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

  // const deployType = 1
  // // 最初からmintしたい
  // if (deployType === 1) {
  // 	await EmployeeAuthorityWorkerNFT.mintNFT(owner.address);
  // 	await EmployeeAuthorityWorkerNFT.mintNFT(addr1.address, 2);
  // }
}

main();