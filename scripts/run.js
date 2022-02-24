const hre = require("hardhat");

async function main() {
  const Nevam = await hre.ethers.getContractFactory("Nevam");
  const contract = await Nevam.deploy();

  await contract.deployed();

  console.log("Contract deployed to:", contract.address);

  await contract.mint([1])
  console.log("Minted tier 1")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
