require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

const { ANVIL_URL, SEPOLIA_URL, PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  // https://ethereum.stackexchange.com/questions/142621/transaction-reverted-trying-to-deploy-a-contract-whose-code-is-too-large
  solidity: {
    version: "0.8.21",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
        details: { yul: false },
      }
    }
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
    },
    // 明示的な Anvil 設定
    anvil: {
      url: ANVIL_URL || "",
      chainId: 31337,
      allowUnlimitedContractSize: true,
      // Anvilのデフォルト秘密鍵（必要に応じて.envで管理）
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
    },
    // Sepoliaの設定を追加
    sepolia: {
      url: SEPOLIA_URL || "",
      chainId: 11155111,
      // 配列の 0番目が deployer
      accounts: [
        PRIVATE_KEY
      ]
    }
  }
}