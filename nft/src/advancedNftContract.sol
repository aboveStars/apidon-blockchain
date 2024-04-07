// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedNftContract is ERC721Enumerable, Ownable {
    uint256 public constant MAX_TOKEN_ID = 10000;

    address public admin;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(msg.sender) {
        admin = msg.sender;
    }

    modifier onlyAdminOrOwner() {
        require(msg.sender == admin || msg.sender == owner(), "Unauthorized");
        _;
    }

    function setAdmin(address _newAdmin) external onlyOwner {
        admin = _newAdmin;
    }

    function mint(address _to, uint256 _id) external onlyAdminOrOwner {
        require(_id <= MAX_TOKEN_ID, "Token ID exceeds maximum allowed");
      
        _safeMint(_to, _id);
    }

    function getNumberOfNFTs(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }
}
