// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";


contract ERC20VotesToken is ERC20Votes, Ownable2Step {

    constructor(address owner) ERC20("ERC20VotesToken", "EVT") EIP712("ERC20VotesToken", "1") Ownable(owner) {}

    //function _update(address from, address to, uint256 value) internal virtual override(ERC20Votes) {
    //    super._update(from, to, value);
    //}

    //function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
    //    super._afterTokenTransfer(from, to, amount);
    //}

    function mint(address to, uint256 amount) public {
        super._mint(to, amount);
    }

    function burn(address account, uint256 amount) public {
        super._burn(account, amount);
    }
}
