// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nevam is ERC1155, Ownable {

  enum SaleStatus { CLOSED, PRESALE, PUBLIC }

  uint256 public constant TIER_1_SUPPLY = 1410;
  uint256 public constant TIER_2_SUPPLY = 650;
  uint256 public constant TIER_3_SUPPLY = 140;

  SaleStatus public saleStatus = SaleStatus.CLOSED;

  mapping(uint256 => uint256) public amountLeft;
  mapping(uint256 => mapping(address => bool)) public mintedTier;
  mapping(address => bool) public whitelisted;

  modifier onlyExternal() {
    require(msg.sender == tx.origin, "Contracts are not allowed to mint");
    _;
  }

  constructor() ERC1155("ipfs://QmeEW8VV7gzTd64dcgYmw7EL2QqrRszNzwopGV9VVt8XC9/{id}.json") {
    amountLeft[1] = TIER_1_SUPPLY;
    amountLeft[2] = TIER_2_SUPPLY;
    amountLeft[3] = TIER_3_SUPPLY;
  }

  // With _ storage vars: 75258 
  // Without _ storage vars: 78580   
  function mint(uint256 _id) external onlyExternal {
    SaleStatus _status = saleStatus;
    require(_status != SaleStatus.CLOSED, "Sale is not active");

    if (_status == SaleStatus.PRESALE) {
      require(whitelisted[msg.sender], "You are not whitelisted");
    }

    mapping(address => bool) storage _minted = mintedTier[_id];
    uint256 _amountLeft = amountLeft[_id];

    require(_id < 4, "Invalid token ID");
    require(_amountLeft > 0, "All tokens with this ID were already minted");
    require(_minted[msg.sender] == false, "You already minted this token");

    _minted[msg.sender] = true;
    _amountLeft -= 1;

    _mint(msg.sender, _id, 1, "");
  }

  // Remove _amounts and replace with [1, 1, 1] in function.
  function mintBatch(uint256[] memory _ids) external onlyExternal {
    SaleStatus _status = saleStatus;
    require(_status != SaleStatus.CLOSED, "Sale is not active");

    if (_status == SaleStatus.PRESALE) {
      require(whitelisted[msg.sender], "You are not whitelisted");
    }

    require(_ids.length < 4, "You can only mint a maximum of 3 tokens");

    uint256[] memory amounts = new uint256[](_ids.length);

    for (uint256 i = 0; i < _ids.length; i++) {
      uint256 id = _ids[i];
      mapping(address => bool) storage _minted = mintedTier[id];
      uint256 _amountLeft = amountLeft[id];

      require(id < 4, "Invalid token ID");
      require(_amountLeft > 0, "All tokens with this ID were already minted");
      require(_minted[msg.sender] == false, "You already minted this token");

      amounts[i] = 1;
      _minted[msg.sender] = true;
      _amountLeft -= 1;
    }

    _mintBatch(msg.sender, _ids, amounts, "");
  }

  // Private batch minting function, does not check for payment.
  function mintPrivate(uint256[] memory _ids, uint256[] memory _amounts) external onlyOwner {
    for (uint256 i = 0; i < _amounts.length; i++) {
      amountLeft[i + 1] -= _amounts[i];
    }

    _mintBatch(msg.sender, _ids, _amounts, "");
  }

  // 0 = CLOSED; 1 = PRESALE; 2 = PUBLIC;
  function setSaleStatus(uint256 _status) external onlyOwner {
    saleStatus = SaleStatus(_status);
  }

  function setWhitelist(address[] memory _addresses) external onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      whitelisted[_addresses[i]] = true;
    }
  }

}