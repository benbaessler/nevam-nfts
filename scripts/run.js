const hre = require("hardhat");

async function main() {
  const Nevam = await hre.ethers.getContractFactory("Nevam");
  const contract = await Nevam.deploy();

  await contract.deployed();

  console.log("Contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
