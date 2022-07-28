const {ethers} = require("hardhat");

async function main () {
    const [deployer] = await ethers.getSigners()
    console.log(
      "Deploying contracts with the account:",
      deployer.address
    )
    const MlmBase = await ethers.getContractFactory("MlmSystem")
    console.log("Deploying contract...")
    const mlmBaseSystem = await MlmBase.deploy()
    await mlmBaseSystem.deployed()
    console.log("Deployed contract to", mlmBaseSystem.address)
}

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await ethers.getSigners()
  const chainId = network.config.chainId
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })