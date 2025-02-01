// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract NFTMarketplace {
    // Enum for NFT rarity
    /*

     0 : Common
     1 : Rare
     2 : Legendary
     3 : Mythic 

    */
    enum Rarity { Common, Rare, Legendary , Mythic}

    // Struct to represent an NFT

    struct NFT {
        uint tokenId;
        address payable owner;
        string uri;
        uint price;
        bool forSale;
        Rarity rarity; // Rarity of the NFT
    }

    uint private nextTokenId = 1;
    mapping(uint => NFT) public nfts; // Mapping from tokenId to NFT struct
    mapping(address => uint[]) public ownerNFTs;

    // Mint a new NFT

    function mintNFT(string memory _uri, uint _price, uint _rarity) public {
        require(_rarity <= uint(Rarity.Legendary), "Invalid rarity value");

        uint tokenId = nextTokenId;
        nextTokenId++;

        nfts[tokenId] = NFT({
            tokenId: tokenId,
            owner: payable(msg.sender),
            uri: _uri,
            price: _price,
            forSale: true,
            rarity: Rarity(_rarity)
        });

        ownerNFTs[msg.sender].push(tokenId);
    }

    // List NFT for sale - change list price
    function listNFT(uint _tokenId, uint _price) public {
        NFT storage nft = nfts[_tokenId];
        require(msg.sender == nft.owner, "Not the owner");
        nft.price = _price;
        nft.forSale = true;
    }

    // Buy NFT

    function buyNFT(uint _tokenId) public payable {
        NFT storage nft = nfts[_tokenId];
        require(nft.forSale, "NFT not for sale");
        require(msg.value == nft.price, "Incorrect price");

        // Transfer ownership

        // Pay the seller
        nft.owner.transfer(msg.value);

        // Change ownership
        nft.owner = payable(msg.sender);

        // NFT no longer for sale
        nft.forSale = false; 

        // Update owner's NFT collection
        ownerNFTs[msg.sender].push(_tokenId);
    }

    // Fetch all NFTs owned by an address
    function getOwnerNFTs(address _owner) public view returns (uint[] memory) {
        return ownerNFTs[_owner];
    }

    // Get rarity of an NFT by tokenId
    function getNFTRarity(uint _tokenId) public view returns (Rarity) {
        return nfts[_tokenId].rarity;
    }

    // Convert rarity enum to string

    function rarityToString(Rarity _rarity) public pure returns (string memory) {
        if (_rarity == Rarity.Common) return "Common";
        if (_rarity == Rarity.Rare) return "Rare";
        if (_rarity == Rarity.Legendary) return "Legendary";
        if (_rarity == Rarity.Mythic) return "Mythic";
        return "";
    }
}
