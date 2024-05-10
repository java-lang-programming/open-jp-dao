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
      it("should be revert when mint to the zero address", async function () {
        await expect(NFT.mintNFT("0x0000000000000000000000000000000000000000", 0)).to.be.revertedWith("ERC721: mint to the zero address");
      });

      it("should be mintNFT when mint to the address", async function () {
        await NFT.mintNFT(addr1.address, 1);
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
        await NFT.mintNFT(addr1.address, 1);
        const uri = await NFT.tokenURI(1)
        expect(uri).to.equal("https://java-lang-programming.github.io/nfts/dwebnft/1");
      });

      // setTokenURIを利用する
      it("should be tokenURI of tokenID of mapping", async function () {
        await NFT.mintNFT(addr1.address, 1);
        await NFT.setTokenURI(1, "ipfs://QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx");
        const uri = await NFT.tokenURI(1)
        expect(uri).to.equal("ipfs://QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx");
      });
  });
});


// ## desposite


// ### encodeCall

// encodeCallは、関数呼び出しとそのパラメータを1つのバイト配列にエンコードできる関数です。このバイト配列を使って、他のコントラクトの関数を低レベルで呼び出すことができる。


// ### functionCall

// byteを渡して実行
  // balance of
// owner of 
  // 次はいか
  // _setApprovalForAll
  // 
  // describe("mintNFT", function () {
  //   it("Should get metadata", async function () {
  //     const tokenUri = "https://gateway.pinata.cloud/ipfs/QmYueiuRNmL4MiA2GwtVMm6ZagknXnSpQnB3z2gWbz36hP";
  //     await marsaAcademyNFT.mintNFT(owner.address, tokenUri);
  //     let metadata = await marsaAcademyNFT.tokenURI(1);
  //     expect(metadata).to.equal(tokenUri);
  //   });

  //   it("Should get balanceOf", async function () {
  //     const tokenUri = "https://gateway.pinata.cloud/ipfs/QmYueiuRNmL4MiA2GwtVMm6ZagknXnSpQnB3z2gWbz36hP";
  //     await marsaAcademyNFT.mintNFT(owner.address, tokenUri);
  //     let balance = await marsaAcademyNFT.balanceOf(owner.address);
  //     expect(balance).to.equal(1);
  //   });

  //   it("Should get ownerOf", async function () {
  //     const tokenUri = "https://gateway.pinata.cloud/ipfs/QmYueiuRNmL4MiA2GwtVMm6ZagknXnSpQnB3z2gWbz36hP";
  //     await marsaAcademyNFT.mintNFT(owner.address, tokenUri);
  //     let address_1 = await marsaAcademyNFT.ownerOf(1);
  //     expect(address_1).to.equal(owner.address);

  //     await marsaAcademyNFT.mintNFT(addr1.address, tokenUri);
  //     let address_2 = await marsaAcademyNFT.ownerOf(2);
  //     expect(address_2).to.equal(addr1.address);
  //   });
  // });

});