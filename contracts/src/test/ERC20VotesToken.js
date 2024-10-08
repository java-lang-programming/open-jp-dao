const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("ERC20VotesToken contract", function () {

  let Token;
  let VoteToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // // Get the ContractFactory and Signers here.
    // Token = await ethers.getContractFactory("OpenJpDaoGovernor");
    // [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // // To deploy our contract, we just have to call Token.deploy() and await
    // // for it to be deployed(), which happens once its transaction has been
    // // mined.
    // // 更新可能にする
    // NFT = await upgrades.deployProxy(Token, ["OpenJpDaoGovernor"]);
    // DWebNFT = await Token.deploy();
    // waiting deploy...
    // await marsaAcademyNFT.deployed();
    Token = await ethers.getContractFactory("ERC20VotesToken");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // https://ethereum.stackexchange.com/questions/139417/how-to-deploy-a-contract-with-many-arguments

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been
    // mined.
    // 1億
    VoteToken = await Token.deploy(addr1.address);
    // waiting deploy...
    await VoteToken.deployed();
  });

  // You can nest describe calls to create subsections.
  describe("IERC20Metadata", function () {
    it("should assign symbol of token", async function () {
      expect(await VoteToken.symbol()).to.equal("EVT");
    });

    it("should assign name of token", async function () {
      expect(await VoteToken.name()).to.equal("ERC20VotesToken");
    });
  });

　describe("ERC20VotesToken", function () {

    describe("mint", function () {
      it("should be mint 1000000.", async function () {
        await VoteToken.mint(owner.address, 1000000);
        expect(await VoteToken.totalSupply()).to.equal(1000000);
        expect(await VoteToken.balanceOf(owner.address)).to.equal(1000000);
      });
    });

    describe("transfer", function () {
      // ownerでmintしてrtarnsferで渡す
      it("should be transformed to addr1 and addr2", async function () {
        await VoteToken.mint(owner.address, 1000000);
        await VoteToken.transfer(addr1.address, 100);
        await VoteToken.transfer(addr2.address, 100);
        expect(await VoteToken.totalSupply()).to.equal(1000000);
        expect(await VoteToken.balanceOf(owner.address)).to.equal(999800);
        expect(await VoteToken.balanceOf(addr1.address)).to.equal(100);
        expect(await VoteToken.balanceOf(addr2.address)).to.equal(100);
      });
    });

    // 投票権
    describe("getVotes", function () {
      it("should get vote.", async function () {
        // 投票権
        expect(await VoteToken.getVotes(owner.address)).to.equal(0);
        expect(await VoteToken.getVotes(addr1.address)).to.equal(0);
        expect(await VoteToken.getVotes(addr2.address)).to.equal(0);

        // ownerがERC20Voteを10000mint
        await VoteToken.mint(owner.address, 10000);
        // Gownerがaddr1に1000を渡す
        await VoteToken.transfer(addr1.address, 100);
        // 投票権をadd1からownerに投票権を委譲する
        await VoteToken.connect(addr1).delegate(owner.address);

        // 投票権
        expect(await VoteToken.getVotes(owner.address)).to.equal(100);
        expect(await VoteToken.getVotes(addr1.address)).to.equal(0);
        expect(await VoteToken.getVotes(addr2.address)).to.equal(0);

        // 残高
        expect(await VoteToken.balanceOf(owner.address)).to.equal(9900);
        expect(await VoteToken.balanceOf(addr1.address)).to.equal(100);
        expect(await VoteToken.balanceOf(addr2.address)).to.equal(0);
      });
    });

    describe("numCheckpoints", function () {
      it("should get numCheckpoints.", async function () {
        // チェックポイント数
        expect(await VoteToken.numCheckpoints(owner.address)).to.equal(0);
        expect(await VoteToken.numCheckpoints(addr1.address)).to.equal(0);
        expect(await VoteToken.getVotes(addr2.address)).to.equal(0);

        // ownerがERC20Voteを10000mint
        await VoteToken.mint(owner.address, 10000);
        // ownerがaddr1に1000を渡す
        await VoteToken.transfer(addr1.address, 100);
        // 投票権をadd1からownerに投票権を委譲する
        await VoteToken.connect(addr1).delegate(owner.address);

        expect(await VoteToken.numCheckpoints(owner.address)).to.equal(1);
        expect(await VoteToken.numCheckpoints(addr1.address)).to.equal(0);

        // ownerがaddr2に100を渡す
        await VoteToken.transfer(addr2.address, 200);
        // 投票権をadd2からownerに投票権を委譲する
        await VoteToken.connect(addr2).delegate(owner.address);

        expect(await VoteToken.numCheckpoints(owner.address)).to.equal(2);
        expect(await VoteToken.numCheckpoints(addr1.address)).to.equal(0);
        expect(await VoteToken.numCheckpoints(addr2.address)).to.equal(0);
      });
    });

    describe("clock", function () {
      it("should get clock.", async function () {
        before_count = await VoteToken.clock();

        // 3回トランザクションを実行する //

        // ownerがERC20Voteを10000mint
        await VoteToken.mint(owner.address, 10000);
        // ownerがaddr1に1000を渡す
        await VoteToken.transfer(addr1.address, 100);
        // 投票権をadd1からownerに投票権を委譲する
        await VoteToken.connect(addr1).delegate(owner.address);

        after_count = await VoteToken.clock();

        expect(after_count).to.equal(before_count + 3);
      });
    });

  });

  describe("Ownable2Step", function () {
    it("should be owner deploy address", async function () {
      expect(await VoteToken.owner()).to.equal(addr1.address);
    });    
  });
});