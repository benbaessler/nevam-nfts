// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nevam is ERC1155, Ownable {

  uint256 public constant TIER_1 = 1;
  uint256 public constant TIER_2 = 2;
  uint256 public constant TIER_3 = 3;

  uint256 public constant TIER_1_SUPPLY = 1410;
  uint256 public constant TIER_2_SUPPLY = 650;
  uint256 public constant TIER_3_SUPPLY = 140;

  constructor() ERC1155("ipfs://QmeEW8VV7gzTd64dcgYmw7EL2QqrRszNzwopGV9VVt8XC9/{id}.json") {}

  function mint(uint256 _id) public {
    _mint(msg.sender, _id, 1, "");
  }

  function mintBatch(uint256[] memory _ids, uint256[] memory _amounts) public onlyOwner {
    _mintBatch(msg.sender, _ids, _amounts, "");
  }

}