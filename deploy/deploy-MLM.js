const {ethers, network} = require("hardhat");
require("dotenv").config()
require("console")

async function main () {
    const MlmBase = await ethers.getContractFactory(
        "MlmBase"
    )
    console.log("Deploying contract...")
    const mlmBaseSystem = MlmBase.deploy()
    await mlmBaseSystem.deployed()
    console.log(`Deployed contract to ${mlmBaseSystem.address}`)
}

module.exports = async({getNameAccounts, deployments}) => {
    const {deploy, log} = deployments
    const {deployer} = await getNameAccounts()
    const chainId = network.config.chainId
};