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

  describe('Minting', () => {
    it('Should not allow minting if sale is closed', async () => {
      await expect(contract.mint(1)).to.be.revertedWith('Sale is not active')
    })

    it('Should not mint token IDs over 3', async () => {
      await contract.setSaleStatus(2)
      await expect(contract.mint(4)).to.be.revertedWith('Invalid token ID')
    })

    it('Should not mint if there is no supply', async () => {
      await contract.setSaleStatus(2)
      await contract.mintPrivate([1, 2, 3], [1410, 650, 140])

      await expect(contract.mint(1)).to.be.revertedWith('All tokens with this ID were already minted')
    })

    it('Should not be able to mint a token twice', async () => {
      await contract.setSaleStatus(2)
      await contract.mint(1)

      await expect(contract.mint(1)).to.be.revertedWith('You already minted this token')
    })

    it('Should update the supply', async () => {
      await contract.setSaleStatus(2)
      await contract.mint(1)

      const response = await contract.amountLeft(1)
      expect(response).to.equal(1409)
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
      await expect(contract.connect(user1).mintPrivate([1, 2, 3], [10, 10, 10]))
        .to.be.revertedWith('Ownable: caller is not the owner')
    })
  })

  describe('Presale minting', async () => {
    it('Should be able to whitelist addresses', async () => {
      let response = await contract.whitelisted(user1.address)
      expect(response).to.equal(false)

      await contract.setWhitelist([user1.address])

      response = await contract.whitelisted(user1.address)
      expect(response).to.equal(true)
    })

    it('Should be able to change saleStatus to presale', async () => {
      await expect(contract.connect(user1).mint(1)).to.be.revertedWith('Sale is not active')

      await contract.setWhitelist([user1.address])
      await contract.setSaleStatus(1)

      await contract.connect(user1).mint(1)

      const response = await contract.balanceOf(user1.address, 1)

      expect(response).to.equal(1)
    })

    it('Should not be able for non-whitelisted addresses to mint', async () => {
      await contract.setSaleStatus(1)
      await expect(contract.connect(user1).mint(1)).to.be.revertedWith('You are not whitelisted')
    })
  })


})