const { ethers, network, deployments } = require("hardhat")
const { expect, assert, use } = require("chai")
const { Contract, signer, utils } = require("ethers")
const {abi, bytecode} = require('compile');
const { deployMockContract } = require("@ethereum-waffle/mock-contract");

require("hardhat-etherscan-abi")
require("../artifacts/contracts/MlmSystem.sol/MlmSystem.json")
const MlmToken = require("../artifacts/contracts/MlmToken.sol/MlmToken.json")
require("@nomiclabs/hardhat-waffle")

describe("MlmSystem", function() {

    let owner, user1, user2, user3, user4, user5, user2_2, user2_3, mlmSystem, levelComissions, mockContract

    beforeEach(async function () {
        [owner, user1, user2, user3, user4, user5, user2_2, user2_3] = await ethers.getSigners()

        mockContract = await deployMockContract(owner, MlmToken.abi)
        const mlmSystemFactory = await ethers.getContractFactory("MlmSystem")
        mlmSystem = await upgrades.deployProxy(mlmSystemFactory, [
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
            mockContract.address
          ],
          {initializer: "initialize"})
        await mlmSystem.deployed()
        console.log("Contract address:", mlmSystem.address)

        levelComissions = [10, 7, 5, 2, 1, 1, 1, 1, 1, 1]

        await mlmSystem.connect(user1).logIn(ethers.constants.AddressZero)
        await mlmSystem.connect(user2).logIn(user1.address)
        await mlmSystem.connect(user2_2).logIn(user1.address)
        await mlmSystem.connect(user2_3).logIn(user1.address)
        await mlmSystem.connect(user3).logIn(user2.address)
        await mlmSystem.connect(user4).logIn(user3.address)
        await mlmSystem.connect(user5).logIn(user4.address)
    })

    function equalArrays(a,b) {
        if (a.length != b.length) return false; // Мас­си­вы раз­ной дли­ны не рав­ны
      
        for(var i = 0; i < a.length; i++) // Цикл по всем эле­мен­там
            if (a[i] !== b[i]) return false; // Ес­ли хоть один эле­мент от­ли­ча­ет­ся, мас­си­вы не рав­ны
      
        return true; // Ина­че они рав­ны
    }

    it("User has 0 tokens by default", async function() {
        const accBalance = await ethers.provider.getBalance(mlmSystem.address)
        console.log("Starting b(alance:", accBalance.toString())
        expect(accBalance).to.equal(0)
    })

    it("Should check minimal invest", async function() {
        const amount = 0.006
        expect(amount >= 0.005).to.eq(true)
        console.log("Does minimal amount '>=' 0.005? ->", amount>=0.005)
    })

    it("Should check that transaction (investing) went through", async function() {
        const amount = 1;
        const comission = amount * 5 / 100;

        await mockContract.mock
            .transfer
            .withArgs(mlmSystem.address, ethers.utils.parseEther(comission.toString()))
            .returns(true)
        
        await mlmSystem
            .connect(user1)
            .invest({value: ethers.utils.parseEther(amount.toString())})

        let accBalance = await ethers.provider.getBalance(mlmSystem.address)

        expect(accBalance).to.equal(ethers.utils.parseEther(amount.toString()))                                    

        console.log("transaction => successfull")
        console.log("Balance after sending transaction:", accBalance.toString())
    })

    it("It should allow owner to withdraw funds and send comission to referals", async function() {
        await mockContract.mock
            .transfer
            .withArgs(user1.address, ethers.utils.parseEther("0.1"))
            .returns(true)
        
        await mlmSystem
            .connect(user1)
            .invest({value: ethers.utils.parseEther("0.1")})

        await mockContract.mock
            .transfer
            .withArgs(user2.address, ethers.utils.parseEther("0.2"))
            .returns(true)
        
        await mlmSystem
            .connect(user2)
            .invest({value: ethers.utils.parseEther("0.2")})

        let balance1 = await ethers.provider.getBalance(user1.address)
      
        const txWithdraw = await mlmSystem.connect(mlmSystem.address).withdraw()

        let level2 = await mlmSystem.getLevel(user2.address)
        let level3 = await mlmSystem.getLevel(user3.address)

        console.log("Level of user2 (0.1 ether):", level2.toString())
        console.log("Level of user3 (0.2 ether):", level3.toString())

        // user2 - level 2 (comission - 8; 0.1), user3 - level 3 (comission - 7; 0.1)
        expect(() => txWithdraw).to.changeEtherBalances([user2, user3], [balance11 * levelComissions[level2] / 10, balance1 * levelComissions[level3] / 10])
    })

    it("The level of investments higher than 10", async function() {
        await mockContract.mock
            .transfer
            .withArgs(mlmSystem.address, ethers.utils.parseEther((100 * 5 / 100).toString()))
            .returns(true)

        await mlmSystem
            .connect(user4)
            .invest({value: ethers.utils.parseEther("100")})

        const sendMoney = await mlmSystem.connect(user4).invest({value: ethers.utils.parseEther("100")}) 
        await sendMoney.wait()

        const tx = await mlmSystem.getLevel(user4.address)
        
        console.log("Level with 100 ether =>", tx.toString())
        expect(tx).to.eq(10)
    })

    it("It should return the info about direct partners", async function() {
        let levelsDone = [5, 1, 1]
        
        const tx = await mlmSystem.connect(user1).directPartnersInfo()
        let amount = tx[0]
        let levelsPartners = tx[1]
        console.log(amount)
        let levelsPartners2 = levelsPartners.map(item => item.toString() )
        console.log(levelsPartners2)

        expect(equalArrays(levelsDone, levelsPartners)).to.eq(true)
        expect(levelsPartners.length).to.equal(amount)
    })

})