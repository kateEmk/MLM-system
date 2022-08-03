const { expect } = require('chai')

let mlmSystem, mlmSystemFactory

describe('MlmSystem (proxy)', function () {
  beforeEach(async function () {
    mlmSystem = await ethers.getContractFactory("MlmSystem")
    mlmSystemFactory = await upgrades.deployProxy(
        MlmSystem, 
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
          [10, 7, 5, 2, 1, 1, 1, 1, 1, 1]
        ],
        {initializer: "initializeInitialValues"})
  })
//   it('retrieve returns a value previously initialized', async function () {
//     expect((await box.retrieve()).toString()).to.equal('42')
//     expect(() => { box.increment() }).to.throw(TypeError)
//   })
  it('upgrades', async function () {
    const MlmSystemV2 = await ethers.getContractFactory("MlmSystemV2")
    mlmSystemFactory = await upgrades.upgradeProxy(mlmSystemFactory.address, MlmSystemV2)
    //await mlmSystemFactory.increment()
    //let result = await box.retrieve()
    //expect(result).to.equal(43)
  })
})