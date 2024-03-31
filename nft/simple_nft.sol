// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNftContract {
    // Structure to represent an NFT
    struct NFT {
        string metadataUrl;
    }

    // Mapping from token ID to NFT
    mapping(uint256 => NFT) private _nfts;

    // Counter to keep track of token IDs
    uint256 private _tokenIdCounter;

    // Event to emit when a new NFT is created
    event NFTCreated(uint256 indexed tokenId, address indexed creator, string metadataUrl);

    constructor() {
        _tokenIdCounter = 0;
    }

    // Function to mint a new NFT
    function mintNFT(string memory metadataUrl) external returns (uint256) {

        // Create the new NFT
        _nfts[_tokenIdCounter] = NFT(metadataUrl);

        // Emit an event for the creation of the NFT
        emit NFTCreated(_tokenIdCounter, msg.sender, metadataUrl);
        
         // Increment the tokenId counter
        _tokenIdCounter++;

        // Return the tokenId of the created NFT
        return _tokenIdCounter - 1;
    }

    // Function to get metadata URL of an NFT
    function getMetadataUrl(uint256 tokenId) external view returns (string memory) {
        return _nfts[tokenId].metadataUrl;
    }
}
