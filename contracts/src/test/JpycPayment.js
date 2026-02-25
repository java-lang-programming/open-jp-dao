const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("JpycPayment contract", function () {
  let JpycPayment, paymentContract, jpyc;
  let owner, treasury, user;
  
  // v5では ethers.utils を使います
  const PRICE_PER_MONTH = ethers.utils.parseUnits("330", 18);
  const MONTH_DURATION = 30 * 24 * 60 * 60; 

  beforeEach(async function () {
    [owner, treasury, user] = await ethers.getSigners();

    // モックトークンのデプロイ
    const MockERC20 = await ethers.getContractFactory("ERC20Mock");
    jpyc = await MockERC20.deploy("JPYC", "JPYC");
    await jpyc.deployed(); 

    // 決済コントラクトのデプロイ
    JpycPayment = await ethers.getContractFactory("JpycPayment");
    paymentContract = await JpycPayment.deploy(jpyc.address, treasury.address);
    await paymentContract.deployed();

    // ユーザーに配布
    const mintAmount = ethers.utils.parseUnits("1000", 18);
    await jpyc.mint(user.address, mintAmount);
    
    // v5では .address を使い、utils.parseUnits を使います
    await jpyc.connect(user).approve(paymentContract.address, mintAmount);
  });

  describe("Deployment", function () {
    it("Should set the right treasury and jpyc address", async function () {
      expect(await paymentContract.treasury()).to.equal(treasury.address);
      expect(await paymentContract.jpyc()).to.equal(jpyc.address);
    });
  });

  describe("payOneMonth", function () {
    it("Should transfer JPYC and update expiry", async function () {
      const initialTreasuryBalance = await jpyc.balanceOf(treasury.address);

      await expect(paymentContract.connect(user).payOneMonth())
        .to.emit(paymentContract, "SubscriptionPaid")
        .withArgs(user.address, PRICE_PER_MONTH, MONTH_DURATION);

      // v5のBigNumber比較
      const finalBalance = await jpyc.balanceOf(treasury.address);
      expect(finalBalance).to.equal(initialTreasuryBalance.add(PRICE_PER_MONTH));

      const latestBlockTime = await time.latest();
      const expiry = await paymentContract.userExpiry(user.address);
      expect(expiry).to.equal(latestBlockTime + MONTH_DURATION);
    });

    it("Should extend expiry if user is already active", async function () {
      await paymentContract.connect(user).payOneMonth();
      const firstExpiry = await paymentContract.userExpiry(user.address);

      await paymentContract.connect(user).payOneMonth();
      
      const secondExpiry = await paymentContract.userExpiry(user.address);
      // BigNumberの加算は .add() を使うのが安全です
      expect(secondExpiry).to.equal(firstExpiry.add(MONTH_DURATION));
    });

    it("Should fail if user has not enough allowance", async function () {
      const [, , , stranger] = await ethers.getSigners();
      // 承認していないユーザーは失敗する
      await expect(paymentContract.connect(stranger).payOneMonth()).to.be.reverted;
    });
  });

  describe("isActive", function () {
    it("Should return false for user who never paid", async function () {
      expect(await paymentContract.isActive(user.address)).to.equal(false);
    });

    it("Should return true immediately after payment", async function () {
      await paymentContract.connect(user).payOneMonth();
      expect(await paymentContract.isActive(user.address)).to.equal(true);
    });

    it("Should return false after 30 days and 1 second", async function () {
      await paymentContract.connect(user).payOneMonth();

      // 30日 + 1秒 時間を進める
      await time.increase(MONTH_DURATION + 1);

      expect(await paymentContract.isActive(user.address)).to.equal(false);
    });

    it("Should return true if expiry is extended", async function () {
      await paymentContract.connect(user).payOneMonth(); // 30日間
      await time.increase(25 * 24 * 60 * 60); // 25日経過 (残り5日)
      
      expect(await paymentContract.isActive(user.address)).to.equal(true);

      await paymentContract.connect(user).payOneMonth(); // さらに30日追加
      
      await time.increase(10 * 24 * 60 * 60); // さらに10日経過 (本来なら切れてるはず)
      expect(await paymentContract.isActive(user.address)).to.equal(true);
    });
  });
});
