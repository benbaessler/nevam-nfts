const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Token contract', () => {

  let contract;
  let owner;
  let user;

  beforeEach(async () => {
    const Nevam = await ethers.getContractFactory('Nevam');
    [owner, user] = await ethers.getSigners();

    contract = await Nevam.deploy()
  })

  describe('Deployment', () => {
    it('Should set the initial supply', async () => {
      let response = await contract.getAmountsLeft()

      expect(response[0]).to.equal(1410)
      expect(response[1]).to.equal(650)
      expect(response[2]).to.equal(140)
    })
  })

  describe('Sale status', () => {
    it('Should allow owner to set the sale status', async () => {
      await expect(contract.connect(user).mint(1)).to.be.revertedWith('Sale is not active')
      
      await contract.setSaleStatus(2)
      await contract.connect(user).mint(1)
      
      const response = await contract.balanceOf(user.address, 1)
      expect(response).to.equal(1)
    })

    it('Should not be able to mint if sale is closed', async () => {
      await expect(contract.mint(1)).to.be.revertedWith('Sale is not active')
    })

    // it('Should only be able for whitelisted accounts to mint during presale', async () => {
    //   await contract.setSaleStatus(1)

    //   await expect(contract.mint(1)).to.be.revertedWith('You are not whitelisted')

    //   await contract.connect(user).mint(1)

    //   const response = await contract.balanceOf(user.address, 1)
    //   expect(response).to.equal(1)
    // })

    it('Should be able for anyone to mint during public sale', async () => {
      await contract.setSaleStatus(2)

      await contract.mint(1)
      await contract.connect(user).mint(1)

      let response = await contract.balanceOf(owner.address, 1)
      expect(response).to.equal(1)

      response = await contract.balanceOf(user.address, 1)
      expect(response).to.equal(1)
    })
  })

  describe('Minting', () => {
    beforeEach(async () => { await contract.setSaleStatus(2) })

    it('Should not mint token IDs over 3', async () => {
      await expect(contract.mint(4)).to.be.revertedWith('Invalid token ID')
    })

    it('Should not mint if there is no supply', async () => {
      await contract.mintPrivate([1, 2, 3], [1410, 650, 140])

      await expect(contract.mint(1)).to.be.revertedWith('All tokens with this ID were already minted')
    })

    it('Should not be able to mint a token twice', async () => {
      await contract.mint(1)

      await expect(contract.mint(1)).to.be.revertedWith('You already minted this token')
    })

    it('Should update the supply', async () => {
      await contract.mint(1)

      const response = await contract.getAmountsLeft()
      expect(response[0]).to.equal(1409)
    })

    it('Should update the users token balance', async () => {
      await contract.connect(user).mint(1)

      const response = await contract.balanceOf(user.address, 1)
      expect(response).to.equal(1)
    })
  })

  describe('Batch minting', () => {
    beforeEach(async () => { await contract.setSaleStatus(2) })

    it('Should not be able to mint more than 3 tokens', async () => { 
      await expect(contract.mintBatch([1, 2, 3, 4])).to.be.revertedWith('You can only mint a maximum of 3 tokens')
    })

    it('Should revert if the user has already minted one of the tokens', async () => {
      await contract.mintBatch([1, 2])

      await expect(contract.mintBatch([2, 3])).to.be.revertedWith('You already minted this token')
    })

    it('Should update the supply of all minted tokens', async () => {
      await contract.mintBatch([1, 2, 3])

      let response = await contract.getAmountsLeft()

      expect(response[0]).to.equal(1409)
      expect(response[1]).to.equal(649)
      expect(response[2]).to.equal(139)
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
      response = await contract.getAmountsLeft()
      
      expect(response[0]).to.equal(1200)
      expect(response[1]).to.equal(500)
      expect(response[2]).to.equal(100)
    })

    it('Should not be able for user to mint team-allocated tokens', async () => {
      await expect(contract.connect(user).mintPrivate([1, 2, 3], [10, 10, 10]))
        .to.be.revertedWith('You are not the owner of this contract')
    })
  })  
})