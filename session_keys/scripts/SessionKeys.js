const { ethers } = require("hardhat");
const noble = require("noble-ed25519");

// Replace with the actual contract address
const contractAddress = "0x...";

// Import the ABI of the contract
const contractAbi = require("./scripts/FoundationCommiteeV1.json");



const provider = new ethers.providers.JsonRpcProvider();
const signer = provider.getSigner();

const contract = new ethers.Contract(contractAddress, contractAbi, signer);

async function generateAddresses(count) {
  const addresses = [];
  const wallet = ethers.Wallet.createRandom();

  for (let i = 0; i < count; i++) {
    const address = ethers.utils.computeAddress(wallet.publicKey, i);
    addresses.push(address);
  }

  return addresses;
}

async function generateEd25519KeyPair() {
  const keyPair = noble.ed25519.keyPair();
  return {
    publicKey: keyPair.publicKey,
    privateKey: keyPair.secretKey,
  };
}

async function addSessionKeyWithExpiry(contract, keyPair, committeeType, sessionDuration) {
  const tx = await contract.addSessionKey(keyPair.publicKey, committeeType);
  await tx.wait();
  console.log(`Session key added for ${committeeType} committee member`);

  const sessionExpiryTx = await contract.setSessionKeyExpiry(
    keyPair.publicKey,
    Math.floor(Date.now() / 1000) + sessionDuration
  );
  await sessionExpiryTx.wait();
  console.log(`Session key expiry set for ${committeeType} committee member`);
}

async function addTechnicalMembers(contractAddress, technicalMembers, sessionDuration) {
  try {
    const committeeTypeTechnical = contract.CommitteeType.Technical;

    for (let i = 0; i < technicalMembers.length; i++) {
      const keyPair = await generateEd25519KeyPair();
      await addSessionKeyWithExpiry(contract, keyPair, committeeTypeTechnical, sessionDuration);
    }

    console.log("Technical members session key creation completed.");
  } catch (error) {
    console.error("An error occurred while adding technical members' session keys:", error);
  }
}

async function addResearchMember(contractAddress, researchMember, sessionDuration) {
  try {
    const committeeTypeResearch = contract.CommitteeType.Research;

    const keyPair = await generateEd25519KeyPair();
    await addSessionKeyWithExpiry(contract, keyPair, committeeTypeResearch, sessionDuration);

    console.log("Research member session key creation completed.");
  } catch (error) {
    console.error("An error occurred while adding research member's session key:", error);
  }
}

async function addAllSessionKeys() {
  // Call the functions to add session keys
  await addTechnicalMembers(contractAddress, addTechnicalMembers, sessionDuration);
  await addTechnicalMembers(contractAddress, addTechnicalMembers, sessionDuration);
  await addTechnicalMembers(contractAddress, addTechnicalMembers, sessionDuration);
  await addResearchMember(contractAddress, addResearchMember, sessionDuration);
}

// Call the function to add all session keys
addAllSessionKeys();
