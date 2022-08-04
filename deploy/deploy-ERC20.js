const {ethers} = require("hardhat");

async function main () {
    const [deployer] = await ethers.getSigners()
    console.log(
      "Deploying contracts with the account:",
      deployer.address
    )
    const MlmToken = await ethers.getContractFactory("MlmToken")
    console.log("Deploying contract...")
    const mlmTokenERC20 = await MlmToken.deploy()
    await mlmTokenERC20.deployed()
    console.log("Deployed contract to", mlmTokenERC20.address)
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