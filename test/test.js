const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Token contract', () => {

  let contract;
  let owner;
  let user1;
  let user2;

  beforeEach(async () => {
    const Nevam = await ethers.getContractFactory('Nevam');
    [owner, user1, user2] = await ethers.getSigners();

    contract = await Nevam.deploy()
  })

  describe('Deployment', () => {
    it('Should set the initial supply', async () => {
      let response = await contract.amountLeft(1)
      expect(response).to.equal(1410)

      response = await contract.amountLeft(2)
      expect(response).to.equal(650)

      response = await contract.amountLeft(3)
      expect(response).to.equal(140)
    })
  })

})