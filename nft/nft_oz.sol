// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public constant MAX_TOKEN_ID = 10000; // Maximum token ID allowed

    address public admin;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        admin = msg.sender; // Contract deployer is set as the admin
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
        require(!_exists(_id), "Token ID already exists");

        _safeMint(_to, _id);
    }
}
