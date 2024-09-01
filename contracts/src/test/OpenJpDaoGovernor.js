const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("OpenJpDaoGovernor contract", function () {

  let Token;
  let VoteToken;
  let Governor;
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
    Token = await ethers.getContractFactory("ERC20VotesToken");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been
    // mined.
    // 1億
    VoteToken = await Token.deploy(owner.address);
    // waiting deploy...
    await VoteToken.deployed();
    //console.log("ERC20VotesToken deployed to address:", VoteToken.address);

    const token_address = VoteToken.address;



    // Grab the contract factory 
    // const MyGovernor = await ethers.getContractFactory("MyGovernor");
 
    // Start deployment, returning a promise that resolves to a contract object
    //const myGovernor = await MyGovernor.deploy("TOKEN_CONTRACT_ADDRESS"); // Instance of the contract taking token contract address as input
    // console.log("Contract deployed to address:", myGovernor.address);
    // // To deploy our contract, we just have to call Token.deploy() and await
    // // for it to be deployed(), which happens once its transaction has been
    // // mined.
    // // 更新可能にする
    // NFT = await upgrades.deployProxy(Token, ["OpenJpDaoGovernor"]);
    // DWebNFT = await Token.deploy();
    // waiting deploy...
    // await marsaAcademyNFT.deployed();
    const MyGovernorFactory = await ethers.getContractFactory("OpenJpDaoGovernor");
    // [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // https://docs.alchemy.com/docs/how-to-create-a-dao-governance-token
    //console.log("MyGovernor");
    

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been
    // mined.
    // 1億
    Governor = await MyGovernorFactory.deploy(VoteToken.address);
    //console.log("deploy MyGovernor");
    // waiting deploy...
    await Governor.deployed();
    //console.log("OpenJpDaoGovernor deployed to address:", Governor.address);


  //     const factoryDex = await ethers.getContractFactory('DWebDEX');
  // console.log('Deploying DWebDEX...');

  // const dex = await factoryDex.deploy(token.address);
  // // デプロイ完了まで待機
  // await dex.deployed();
  // console.log('DWebDEX deployed to:', dex.address);
  // console.log('owner is :', owner.address);

  });

  describe("OpenJpDaoGovernor", function () {
    describe("version", function () {
      it("should be name", async function () {
        expect(await Governor.name()).to.equal("OpenJpDaoGovernor");
      });
    });

    // アカウントがプロポーザルを作成するために必要な最低投票数。
    describe("proposalThreshold", function () {
      it("should be zero Threshold", async function () {
        expect(await Governor.proposalThreshold()).to.equal(0);
      });
    });

    // test
    describe("proposalThreshold", function () {
      it("should be zero Threshold", async function () {
        const MessageHash = await Governor.getMessageHash("test");
        console.log(MessageHash);
        //expect(await Governor.getMessageHash("test")).to.equal(0);
      });
    });



    // 投票権を与える
    // 両方とも賛成票
    // Goveから100tokenをaddr1.addressに渡す
    describe("propose for", function () {
      // calldataなし
      it("should be creadted propose. no calldata", async function () {
        const proposal_tx = await Governor.propose(
          [VoteToken.address],
          [0],
          ["0x"],
          "Proposal #1: 日本語",
        );

        // console.log(proposal_tx);

        const receipt = await proposal_tx.wait(1)
        const proposalId = receipt.events[0].args.proposalId.toString();

        console.log("proposalId");
        console.log(proposalId);

        const proposalSnapshot = await Governor.proposalSnapshot(proposalId);

        console.log("proposalSnapshot");
        console.log(proposalSnapshot);
      });

      //　賛成の場合
      it("should be creadted propose", async function () {
        // コントラクトにイーサ
        await VoteToken.mint(Governor.address, 10000);
        // console.log("mint");
        await VoteToken.mint(owner.address, 3000);
        // weight
        await VoteToken.transfer(addr1.address, 1000);
        await VoteToken.transfer(addr2.address, 1000);

        // governor 10000
        const governor_balance_1 = await VoteToken.balanceOf(Governor.address);

        // addr1 1000
        const addr1_balance_1 = await VoteToken.balanceOf(addr1.address);
        
        // 投票権をadd1からownerに委譲する
        await VoteToken.connect(addr1).delegate(owner.address);
        // 自身にdelegate
        await VoteToken.connect(addr2).delegate(addr2.address);

        // delegateeはない？

        // voteチェック
        const t_owner_vote = await VoteToken.getVotes(owner.address);
        expect(t_owner_vote).to.equal(1000);
        const t_addr1_vote = await VoteToken.getVotes(addr1.address);
        expect(t_addr1_vote).to.equal(0);
        const t_addr2_vote = await VoteToken.getVotes(addr2.address);
        expect(t_addr2_vote).to.equal(1000);

        // https://docs.uxd.fi/uxdprogram-ethereum/governance/governance-proposals
        const teamAddress = addr1.address;
        const grantAmount = 200;
        // ethers.keccak256
        const transferCalldata = VoteToken.interface.encodeFunctionData("transfer", [teamAddress, grantAmount]);

        // const proposalId = 
        // ここでproposalIdは取得できない。イベントから取得する
        // https://forum.openzeppelin.com/t/question-regarding-the-governor-propose/21678/3
        const proposal_tx = await Governor.propose(
          [VoteToken.address],
          [0],
          [transferCalldata],
          "Proposal #1: Give grant to team",
        );


        // console.log(proposal_tx);

        // https://forum.openzeppelin.com/t/question-regarding-the-governor-propose/21678/4
        const receipt = await proposal_tx.wait(1)
        const proposalId = receipt.events[0].args.proposalId.toString();

        console.log("proposalId");
        console.log(proposalId);
        // expect(receipt.events[0].args.proposalId).to.equal(76581773275773702640151039093264761630080263083005103229063328352517182367742);

        // https://ethereum.stackexchange.com/questions/130880/governor-proposal-not-successful
        const proposalState = await Governor.state(proposalId);
        // state check is pendding
        expect(proposalState).to.equal(0);

        // TODO votingDelayをとってblockを進める処理を書く
        // ここでblockを進める(これが重要)
        await VoteToken.transfer(addr1.address, 100);
        //await VoteToken.transfer(addr1.address, 100);

        // statsの変更を確認
        //const proposalState2 = await Governor.state(proposalId);
        // state check = active
        // expect(proposalState2).to.equal(1);

        // The account that created a proposal.
        const proposalProposer = await Governor.proposalProposer(proposalId);
        expect(proposalProposer).to.equal(owner.address);

        const ownerhasVoted = await Governor.hasVoted(proposalId, owner.address);
        expect(ownerhasVoted).to.equal(false);

        const addr1hasVoted = await Governor.hasVoted(proposalId, addr1.address);
        expect(addr1hasVoted).to.equal(false);

        const addr2hasVoted = await Governor.hasVoted(proposalId, addr2.address);
        expect(addr2hasVoted).to.equal(false);

        // https://forum.openzeppelin.com/t/question-regarding-the-governor-propose/21678/5

        // statsの変更を確認
        const proposalState2 = await Governor.state(proposalId);
        // state check = pendding
        expect(proposalState2).to.equal(0);

        // cast vote
        const voteWay = 1 // 0 = Against, 1 = For, 2 = Abstain
        // connect(owner)
        const voteTx = await Governor.connect(addr2).castVote(proposalId, voteWay);
        // console.log("voteTx");
        // console.log(voteTx);
        await voteTx.wait(1);

        // const ssss = await Governor.proposalVotes(proposalId);
        // console.log(ssss);
        // console.log("aaaa")

        //const snapshot = await Governor.proposalSnapshot(proposalId);
        //console.log("snapshot");
        //console.log(snapshot);
        //const snapshot_s = snapshot.toString();

        // const owner_vote = await Governor.getVotes(owner.address, snapshot_s);
        // ここでblockを進める
        // await VoteToken.transfer(addr1.address, 100);


        // 投票結果
        const ownerhasVoted2 = await Governor.hasVoted(proposalId, owner.address);
        expect(ownerhasVoted2).to.equal(false);

        const addr1hasVoted2 = await Governor.hasVoted(proposalId, addr1.address);
        expect(addr1hasVoted2).to.equal(false);

        const addr2hasVoted2 = await Governor.hasVoted(proposalId, addr2.address);
        expect(addr2hasVoted2).to.equal(true);

        // statsの変更を確認
        // const proposalState4 = await Governor.state(proposalId);
        // state check = active
        // console.log(proposalState4);

        // ここでblockを進める
        await VoteToken.transfer(addr1.address, 100);

        // TODO block取得

        // 投票2
        const voteTx2 = await Governor.connect(owner).castVote(proposalId, voteWay);
        // console.log("voteTx");
        // console.log(voteTx);
        await voteTx2.wait(1);

        // 投票結果
        // const ownerhasVoted2 = await Governor.hasVoted(proposalId, owner.address);
        expect(await Governor.hasVoted(proposalId, owner.address)).to.equal(true);
        expect(await Governor.hasVoted(proposalId, addr1.address)).to.equal(false);
        expect(await Governor.hasVoted(proposalId, addr2.address)).to.equal(true);


        const proposalState4 = await Governor.state(proposalId);
        console.log(proposalState4);





        // ここでblockを進める
        // await VoteToken.transfer(addr2.address, 100);

        // // 投票結果
        // const addr1hasVoted3 = await Governor.hasVoted(proposalId, addr1.address);
        // // console.log("addr1hasVoted3");
        // // console.log(addr1hasVoted3);

        // // ここでblockを進める
        // await VoteToken.transfer(addr1.address, 100);


        // console.log("temp_block");
        // a = await Governor.temp_blockNumber();
        // console.log(a);

        // againstVotes, proposalVote.forVotes, proposalVote.abstainVotes

        


        // const snapshot = await Governor.proposalSnapshot(proposalId);
        // console.log("snapshot");
        // console.log(snapshot);

        // const snapshot_s = snapshot.toString();

        // console.log(snapshot_s);
        // const quorum = await Governor.quorum(snapshot_s);
        // console.log("quorum");
        // console.log(quorum);
        // ここでexecute


        // aaaa = await Governor.hashProposal2(
        //   [VoteToken.address],
        //   [100],
        //   [transferCalldata],
        //   "Proposal #1: Give grant to team"
        // );
        // console.log("hashProposal2");
        // console.log(aaaa);


         
        //const descriptionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("Proposal #1: Give grant to team"));
        const descriptionHash = ethers.utils.id("Proposal #1: Give grant to team");
        //console.log("descriptionHash");
        //console.log(descriptionHash);

        // aaaa = await Governor.getMessageHash("Proposal #1: Give grant to team");
        // console.log("descriptionHash2");
        // console.log(aaaa);

        // await Governor.queue(
        //   [VoteToken.address],
        //   [0],
        //   [transferCalldata],
        //   descriptionHash,
        // );

        await Governor.execute(
          [VoteToken.address],
          [0],
          [transferCalldata],
          descriptionHash,
        );


        // tokenの移動
        expect(await VoteToken.balanceOf(Governor.address)).to.equal(9800);
        expect(await VoteToken.balanceOf(addr1.address)).to.equal(1400);
        // Executed
        expect(await Governor.state(proposalId)).to.equal(7);

        // addr1.address)

// 戻り値はトランザクションでは使用できません。関数は戻り値を持っていますが、トランザクションレシートからそれを取得することはできません。

// トランザクションIDを取得する期待される方法は、イベントから取得することです。トランザクションレシートの中にデコードされたProposalCreatedイベント、つまりawait proposal_tx.wait()の戻り値があります。そこからidを取り出すことができます。

// idを取得するもう一つの方法は、governor.hashProposal 10を使用することです。
        // const proposalId = await Governor.hashProposal([VoteToken.address], [0], [transferCalldata], ethers.keccak256(ethers.toUtf8Bytes.bytes("Proposal #1: Give grant to team")));
        // npx hardhat test test/OpenJpDaoGovernor.js
        // console.log(proposalId);
        //expect(proposalId).to.equal(1);
      });
    });

    // describe("version", function () {
    //   it("should be 1", async function () {
    //     expect(await Governor.version()).to.equal("1");
    //   });
    // });

    // describe("propose", function () {
    //   it("should be 0", async function () {
    //     const id = await Governor.propose();
    //     // expect(await Governor.propose()).to.equal(0);
    //   });
    // });
  });

});