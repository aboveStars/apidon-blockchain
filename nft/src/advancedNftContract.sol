// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedNftContract is ERC721Enumerable, Ownable {
    uint256 private constant MAX_TOKEN_ID =  10000;

    address private admin;
    bool private _notEntered;

    event AdminSet(address indexed _oldAdmin, address indexed _newAdmin);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(msg.sender) {
        admin = msg.sender;
    }

    modifier onlyAdminOrOwner() {
        if (msg.sender != admin && msg.sender != owner()) {
            revert Unauthorized();
        }
        _;
    }
    modifier nonReentrant() {
        require(_notEntered, "Reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    function setAdmin(address _newAdmin) external onlyOwner {
        address oldAdmin = admin;
        admin = _newAdmin;
        emit AdminSet(oldAdmin, _newAdmin);
    }

    function mint(address _to, uint256 _id) external onlyAdminOrOwner nonReentrant {
        if (_id > MAX_TOKEN_ID) {
            revert TokenIdExceedsMaxAllowed();
        }
      
        _safeMint(_to, _id);
    }

    function getNumberOfNFTs(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }
 


    error Unauthorized();
    error TokenIdExceedsMaxAllowed();
}
