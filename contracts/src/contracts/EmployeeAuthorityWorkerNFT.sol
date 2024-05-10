// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract EmployeeAuthorityWorkerNFT is ERC721Upgradeable {
    mapping(uint256 => string) private _urls;

    function initialize(string memory name_, string memory symbol_) initializer public onlyInitializing {
        __ERC721_init(name_, symbol_);
    }

    function mintNFT(address to, uint256 tokenID)
        public
    {
        _safeMint(to, tokenID);
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
}
