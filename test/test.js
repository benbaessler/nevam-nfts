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

  describe('Private minting', () => {
    it('Should be able for owner to mint team-allocated tokens', async () => {
      await contract.mintPrivate([1, 2, 3], [210, 150, 40])

      // Checking if mint was successful
      let response = await contract.balanceOf(owner.address, 1)
      expect(response).to.equal(210)

      response = await contract.balanceOf(owner.address, 2)
      expect(response).to.equal(150)

      response = await contract.balanceOf(owner.address, 3)
      expect(response).to.equal(40)

      // Checking if supply has updated
      response = await contract.amountLeft(1)
      expect(response).to.equal(1200)

      response = await contract.amountLeft(2)
      expect(response).to.equal(500)

      response = await contract.amountLeft(3)
      expect(response).to.equal(100)
    })

    it('Should not be able for user to mint team-allocated tokens', async () => {
      await contract.connect(user1)

      await expect(contract.connect(user1).mintPrivate([1, 2, 3], [10, 10, 10]))
        .to.be.revertedWith('Ownable: caller is not the owner')
    })


  })
})