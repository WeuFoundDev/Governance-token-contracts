const { ethers } = require("hardhat");

async function main() {
  const FoundationCommitteeV1 = await ethers.getContractFactory("FoundationCommitteeV1");
  const foundationCommitteeV1 = await FoundationCommitteeV1.deploy();

  await foundationCommitteeV1.deployed(); // Wait for the contract to be deployed

  console.log("Contract deployed to:", foundationCommitteeV1.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
