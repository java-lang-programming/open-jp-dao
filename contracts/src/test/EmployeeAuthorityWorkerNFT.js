const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("EmployeeAuthorityWorkerNFT contract", function () {

  let Token;
  let NFT;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("EmployeeAuthorityWorkerNFT");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been
    // mined.
    // 更新可能にする
    NFT = await upgrades.deployProxy(Token, ["EmployeeAuthorityWorkerNFT", "EAWNFT"]);
    // DWebNFT = await Token.deploy();
    // waiting deploy...
    // await marsaAcademyNFT.deployed();
  });

  // You can nest describe calls to create subsections.
  describe("IERC721Metadata", function () {
    it("should assign symbol of token", async function () {
      expect(await NFT.symbol()).to.equal("EAWNFT");
    });

    it("should assign name of token", async function () {
      expect(await NFT.name()).to.equal("EmployeeAuthorityWorkerNFT");
    });

    it("should revert when tokenID is not exists", async function () {
      await expect(NFT.tokenURI(0)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("should be true when IERC721 is implemented", async function () {
      expect(await NFT.supportsInterface("0x5b5e139f")).to.be.true;
    });
  });

  describe("IERC165", function () {
    it("should be true when ERC165 is implemented", async function () {
      expect(await NFT.supportsInterface("0x01ffc9a7")).to.be.true;
    });
  });

  describe("EmployeeAuthorityWorkerNFT", function () {
    describe("mintNFT", function () {
      // it("should be revert when mint to the zero address", async function () {
      //   await expect(NFT.mintNFT("0x0000000000000000000000000000000000000000", 0)).to.be.revertedWith("ERC721: mint to the zero address");
      // });

      it("should be mintNFT when mint to the address", async function () {
        await NFT.mintNFT(addr1.address);
        expect(await NFT.balanceOf(addr1.address)).to.equal(1);
        expect(await NFT.balanceOf(owner.address)).to.equal(0);
      });
    });

    describe("tokenURI", function () {
      // tokenIdのNFTが存在しない場合
      it("should be revert when tokenId is not exsists.", async function () {
        await expect(NFT.tokenURI(1)).to.be.revertedWith("ERC721: invalid token ID");
      });

      // setTokenURIを利用してない場合
      it("should be tokenURI of tokenID", async function () {
        await NFT.mintNFT(addr1.address);
        const tokenID = await NFT.currentTokenID();
        const uri = await NFT.tokenURI(1)
        expect(uri).to.equal("https://java-lang-programming.github.io/nfts/dwebnft/1");
      });

      // setTokenURIを利用する
      it("should be tokenURI of tokenID of mapping", async function () {
        await NFT.mintNFT(addr1.address);
        await NFT.setTokenURI(1, "ipfs://QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx");
        const uri = await NFT.tokenURI(1)
        expect(uri).to.equal("ipfs://QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx");
      });
    });

    describe("transferFrom", function () {
      it("should be error when transferred from owner.address to addr1.address.", async function () {
        await NFT.mintNFT(owner.address);
        await expect(NFT.transferFrom(owner.address, addr1.address, 1)).to.be.revertedWith("Err: token is SOUL BOUND");
      });
    });


    describe("currentTokenID", function () {
      it("should be zero when no mint.", async function () {
        const currentTokenID = await NFT.currentTokenID();
        await expect(currentTokenID).to.equal(0);
      });

      it("should be number when mint is executed.", async function () {
        await NFT.mintNFT(owner.address);
        await NFT.mintNFT(addr1.address);
        const currentTokenID = await NFT.currentTokenID();
        await expect(currentTokenID).to.equal(2);
      });
    });

    describe("totalSupply", function () {
      it("should be zero when no mint.", async function () {
        const totalSupply = await NFT.totalSupply();
        await expect(totalSupply).to.equal(0);
      });

      it("should be number when mint is executed.", async function () {
        await NFT.mintNFT(owner.address);
        await NFT.mintNFT(addr1.address);
        const totalSupply = await NFT.totalSupply();
        await expect(totalSupply).to.equal(2);
      });
    });


    // safeTransferFromが動作しない
    // describe("safeTransferFrom", function () {
    //   it("should be error when safeTransferFrom from owner.address to addr1.address.", async function () {
    //     await NFT.mintNFT(owner.address, 1);
    //     await expect(NFT.safeTransferFrom(owner.address, addr1.address, 1, [])).to.be.revertedWith("Err: token is SOUL BOUND");
    //   });
    // });
  });
});