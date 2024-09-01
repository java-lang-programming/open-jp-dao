// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
//import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "hardhat/console.sol";


contract OpenJpDaoGovernor is Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction {

    constructor(
        IVotes _token
    ) Governor("OpenJpDaoGovernor") GovernorVotes(_token) GovernorVotesQuorumFraction(0) {}

    // 指定された遅延の後に開始される
    // これだと1blockになる。
    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block
    }

    // 登場はvotingPeriodで指定された期間続く。
    // これだと3block
    function votingPeriod() public pure override returns (uint256) {
        // return 45818; // 1 week
        return 3; // 1 block
    }
  
    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    // The following functions are overrides required by Solidity.
    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    //function temp_timestamp() public returns (uint256) {
    //    return SafeCast.toUint48(block.timestamp);
    //}


    /**
     * @dev Get the block number as a Timepoint.
     */
    function temp_blockNumber() public returns (uint48) {
        return SafeCast.toUint48(block.number);
    }

    function hashProposal_temp(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    function hashProposal2(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public pure virtual returns (uint256) {
        return hashProposal(targets, values, calldatas, keccak256(bytes(description)));
        //return proposalId;
    }

    // テストコードサンプル
    // https://zenn.dev/lowzzy/articles/5978c87df5873c#%E3%83%86%E3%82%B9%E3%83%88%E3%82%B3%E3%83%BC%E3%83%89-by-hardhat    

    //
    //function hash(string memory _message) public {
    //    messageHash = keccak256(bytes(_message));
    //}

    function getMessageHash(string memory _message) public view returns (bytes32) {
        console.logBytes(bytes(_message));
        return keccak256(bytes(_message));
    }
}
