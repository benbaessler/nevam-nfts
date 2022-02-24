// SPDX-License-Identifier: UNLICENSED
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

  constructor() ERC1155("ipfs://QmeEW8VV7gzTd64dcgYmw7EL2QqrRszNzwopGV9VVt8XC9/{id}.json") {
    // _mintBatch(msg.sender, [1, 2, 3], [210, 150, 40], "");

    amountLeft[1] = TIER_1_SUPPLY;
    amountLeft[2] = TIER_2_SUPPLY;
    amountLeft[3] = TIER_3_SUPPLY;
  }

  function mint(uint256 _id) external {
    require(saleStatus == SaleStatus.PUBLIC, "Public sale is not active");

    require(_id < 4, "Invalid token ID");
    require(amountLeft[_id] > 0, "All tokens were already minted");
    require(mintedTier[_id][msg.sender] == false, "You already minted this token");

    mintedTier[_id][msg.sender] = true;
    amountLeft[_id] -= 1;

    _mint(msg.sender, _id, 1, "");
  }

  // Private batch minting function, does not check for payment.
  function mintPrivate(uint256[] memory _ids, uint256[] memory _amounts) external onlyOwner {
    _mintBatch(msg.sender, _ids, _amounts, "");
  }

  // 0 = CLOSED; 1 = PRESALE; 2 = PUBLIC;
  function setSaleStatus(uint256 _status) external onlyOwner {
    saleStatus = SaleStatus(_status);
  }

}