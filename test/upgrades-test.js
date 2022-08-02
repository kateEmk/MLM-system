const { expect } = require('chai')
const { ethers } = require('hardhat')

let mlmSystem, mlmSystemFactory, mlmToken

describe('MlmSystem (proxy)', function () {
  beforeEach(async function () {
    mlmSystem = await ethers.getContractFactory("MlmSystem")
    mlmToken = await ethers.getContractFactory("MlmToken")
    mlmSystemFactory = await upgrades.deployProxy(
        mlmSystem, 
        [
          ethers.utils.parseEther("0.005"), 
          [ethers.utils.parseEther("0.005"), 
           ethers.utils.parseEther("0.01"), 
           ethers.utils.parseEther("0.02"), 
           ethers.utils.parseEther("0.05"), 
           ethers.utils.parseEther("0.1"), 
           ethers.utils.parseEther("0.2"), 
           ethers.utils.parseEther("0.5"), 
           ethers.utils.parseEther("1"), 
           ethers.utils.parseEther("2"), 
           ethers.utils.parseEther("5")], 
          [10, 7, 5, 2, 1, 1, 1, 1, 1, 1],
          mlmToken.address
        ],
        {initializer: "initializeInitialValues"})
  })

  it('Should return the greeting after deployment', async function () {
    const upgradeableContract = await ethers.getContractFactory("MlmSystem");
    const contract = await upgrades.deployProxy(OurUpgradeableNFT1, ["Hello, upgradeable world!"], { initializer: 'initialize', kind: 'uups'});
    await contract.deployed();
  
    // const MlmSystemV2 = await ethers.getContractFactory("MlmSystemV2")
    // mlmSystemFactory = await upgrades.upgradeProxy(mlmSystemFactory.address, MlmSystemV2)
  })
})