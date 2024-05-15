require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

const { API_URL, PRIVATE_KEY } = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // https://ethereum.stackexchange.com/questions/142621/transaction-reverted-trying-to-deploy-a-contract-whose-code-is-too-large
  solidity: {
    version: "0.8.21",
    optimizer: {
      enabled: true,
      runs: 1000,
      details: { yul: false },
    },
  },
  defaultNetwork: "hardhat",
   networks: {
      hardhat: {
        chainId: 1338,
        // govenorはこれが必要
        allowUnlimitedContractSize: true,
      },
      localhost: {
        chainId: 1338,
        url: "http://0.0.0.0:8545",
        gas: 12000000,
        allowUnlimitedContractSize: true,
      }
      // goerli: {
      //    url: API_URL,
      //    accounts: [`0x${PRIVATE_KEY}`]
      // }
  }
}