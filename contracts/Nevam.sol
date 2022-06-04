// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Nevam is ERC1155, Ownable {

  enum SaleStatus { CLOSED, PRESALE, PUBLIC }

  SaleStatus public saleStatus = SaleStatus.CLOSED;
  uint256[] public amountsLeft = [1410, 650, 140];

  // IMPORTANT!: Set MerkleRoot hash (for whitelist)
  bytes32 public merkleRoot = 0x0;

  mapping(address => mapping(uint256 => bool)) public mintedTier;

  modifier onlyExternal() {
    require(msg.sender == tx.origin, "Contracts are not allowed to mint");
    _;
  }

  // IMPORTANT!: Set IPFS metadata URI
  constructor() ERC1155("ipfs://QmeEW8VV7gzTd64dcgYmw7EL2QqrRszNzwopGV9VVt8XC9/{id}.json") {}

  modifier isAvailable(uint256 _id) {
    require(_id < 4, "Invalid token ID");
    require(amountsLeft[_id - 1] > 0, "All tokens with this ID were already minted");
    _;
  }

  function mintPresale(uint256 _id, bytes32[] calldata _merkleProof) external onlyExternal isAvailable(_id) {
    require(saleStatus == SaleStatus.PRESALE, "Presale is not active");
    require(!mintedTier[msg.sender][_id], "You already minted this token");

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "You are not whitelisted");

    // @dev: ! Test that mintedTier really updates
    mintedTier[msg.sender][_id] = true;
    amountsLeft[_id - 1] -= 1;

    _mint(msg.sender, _id, 1, "");
  }

  function mintBatchPresale(uint256[] calldata _ids, bytes32[] calldata _merkleProof) external onlyExternal {
    require(saleStatus == SaleStatus.PUBLIC, "Sale is not active");
    require(_ids.length < 4, "You can only mint a maximum of 3 tokens");

    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "You are not whitelisted");

    mapping(uint256 => bool) storage _mintedTier = mintedTier[msg.sender];

    // Create new array, change and assign to amountsLeft at the end of loop
    uint256[] memory _amountsLeft = amountsLeft;
    uint256[] memory amounts = new uint256[](_ids.length);

    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];

      require(id < 4, "Invalid token ID");
      require(_amountsLeft[i] > 0, "All tokens with this ID were already minted");
      require(!_mintedTier[id], "You already minted this token");

      _amountsLeft[i] -= 1;
      _mintedTier[id] = true;
    }

    amountsLeft = _amountsLeft;
    _mintBatch(msg.sender, _ids, amounts, "");
  }

  function mint(uint256 _id) public onlyExternal isAvailable(_id) {
    require(saleStatus == SaleStatus.PUBLIC, "Sale is not active");
    require(!mintedTier[msg.sender][_id], "You already minted this token");

    mintedTier[msg.sender][_id] = true;
    amountsLeft[_id - 1] -= 1;

    _mint(msg.sender, _id, 1, "");
  }

  function mintBatch(uint256[] calldata _ids) external onlyExternal {
    require(saleStatus == SaleStatus.PUBLIC, "Sale is not active");
    require(_ids.length < 4, "You can only mint a maximum of 3 tokens");

    mapping(uint256 => bool) storage _mintedTier = mintedTier[msg.sender];

    uint256[] storage _amountsLeft = amountsLeft;
    uint256[] memory amounts = new uint256[](_ids.length);

    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];

      require(id < 4, "Invalid token ID");
      require(_amountsLeft[i] > 0, "All tokens with this ID were already minted");
      require(!_mintedTier[id], "You already minted this token");

      _amountsLeft[i] -= 1;
      _mintedTier[id] = true;
    }
    
    _mintBatch(msg.sender, _ids, amounts, "");
  }

  // Private batch minting function, does not check for payment.
  function mintPrivate(uint256[] memory _ids, uint256[] memory _amounts) external onlyOwner {
    for (uint256 i = 0; i < _amounts.length; i++) {
      amountsLeft[i] -= _amounts[i];
    }

    _mintBatch(msg.sender, _ids, _amounts, "");
  }

  // 0 = CLOSED; 1 = PRESALE; 2 = PUBLIC;
  function setSaleStatus(uint256 _status) external onlyOwner {
    saleStatus = SaleStatus(_status);
  }

  function getAmountsLeft() external view returns(uint256[] memory) {
    return amountsLeft;
  } 

}