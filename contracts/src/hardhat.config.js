require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

const { API_URL, PRIVATE_KEY } = process.env;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.21",
    optimizer: {
      enabled: true,
      runs: 200,
      details: { yul: false },
    },
  }, 
  defaultNetwork: "hardhat",
   networks: {
      hardhat: {
        chainId: 1338
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