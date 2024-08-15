// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "hardhat/console.sol";

contract EmployeeAuthorityWorkerNFT is ERC721EnumerableUpgradeable {
    //using Counters for Counters.Counter;

    uint256 private _tokenId;
    mapping(uint256 => string) private _urls;

    function initialize(string memory name_, string memory symbol_) initializer public onlyInitializing {
        __ERC721_init(name_, symbol_);
        __ERC721Enumerable_init();
        _tokenId = 0;
    }

    function mintNFT(address to)
        public
    {
        unchecked {
            _tokenId += 1;
        }
        _safeMint(to, _tokenId);
    }

    function currentTokenID() public view returns (uint256) {
       return _tokenId;
    }

    // ここはプロジェクトによって書き換えること
    function _baseURI() internal view virtual override returns (string memory) {
        return "https://java-lang-programming.github.io/nfts/dwebnft/";
    }

    // urlと紐づける
    function setTokenURI(uint256 tokenId, string memory url) public virtual {
        _urls[tokenId] = url;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenIDUrl = _urls[tokenId];
        // データがない場合はでデフォルト
        if (keccak256(bytes("")) == keccak256(bytes(tokenIDUrl))) {
            return super.tokenURI(tokenId);
        }
        return _urls[tokenId];
    }

    //　譲渡不可能にする(ロックの有無を考えても良い)
    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721Upgradeable, IERC721) {
      require(from == address(0), "Err: token is SOUL BOUND");
      super.transferFrom(from, to, tokenId);
    }
}
