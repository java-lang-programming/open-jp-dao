const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  // v5では BigNumber を使用
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // --- 設定項目 ---
  // Sepolia上のJPYC v2 アドレス (公式のデプロイ状況に合わせて変更してください)
  // 取得できない場合は、先に MockERC20 をデプロイしてそのアドレスを使います
  // https://faq.jpyc.co.jp/s/article/developer-documentation
  const JPYC_SEPOLIA_ADDRESS = "0xE7C3D8C9a439feDe00D2600032D5dB0Be71C3c29"; 
  const TREASURY_ADDRESS = process.env.DEV_TREASURY_ADDRESS;
  // ----------------

  const JpycPayment = await ethers.getContractFactory("JpycPayment");
  const payment = await JpycPayment.deploy(JPYC_SEPOLIA_ADDRESS, TREASURY_ADDRESS);

  // v5の待機方法
  await payment.deployed();

  console.log("--------------------------------------------");
  console.log("JpycPayment deployed to:", payment.address);
  console.log("JPYC Address set to:", JPYC_SEPOLIA_ADDRESS);
  console.log("Treasury Address set to:", TREASURY_ADDRESS);
  console.log("--------------------------------------------");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
