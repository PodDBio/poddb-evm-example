import { ethers } from "ethers";
const reputationAbi = require("../artifacts/contracts/Reputation.sol/Reputation.json");

// Please replace this with the correct reputation contract address
const reputationAddress = "0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82";
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const wallet = new ethers.Wallet(
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
  provider
);

const reputationContract = new ethers.Contract(
  reputationAddress,
  reputationAbi.abi,
  provider
).connect(wallet);

async function main() {
  const reputationTagClassId = await reputationContract.ReputationTagClassId();
  console.log("reputationTagClassId:", reputationTagClassId);

  const userAddress = wallet.address;
  const setTx = await reputationContract.setReputation(100, userAddress);
  setTx.wait();

  let score = await reputationContract.getReputation(userAddress);
  console.log("Score:", score);
}

void main();
