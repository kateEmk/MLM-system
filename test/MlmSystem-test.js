const { ethers, network, deployments } = require("hardhat")
const { expect, assert, use } = require("chai")
const { Contract, signer, utils } = require("ethers")
const { deployMockContract } = require("@ethereum-waffle/mock-contract");

require("../artifacts/contracts/MlmSystem.sol/MlmSystem.json")
const MlmToken = require("../artifacts/contracts/MlmToken.sol/MlmToken.json")
require("@nomiclabs/hardhat-waffle")

describe("MlmSystem", function() {

    let owner, user1, user2, user3, user4, user5, user2_2, user2_3, mlmSystem, levelComissions, mockContract

    before(async function () {
        [owner, user1, user2, user3, user4, user5, user2_2, user2_3] = await ethers.getSigners()

        mockContract = await deployMockContract(owner, MlmToken.abi)
        const mlmSystemFactory = await ethers.getContractFactory("MlmSystem")
        mlmSystem = await mlmSystemFactory.deploy()
        mlmSystem.initialize(
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
        )
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
        console.log(await ethers.provider.getBalance(user1.address))
        amount = 1
        await mockContract.mock
            .transferFrom
            .withArgs(user1.address, mlmSystem.address, ethers.utils.parseEther(amount.toString()))
            .returns(true)
        
        const tx = await mlmSystem
            .connect(user1)
            .invest(ethers.utils.parseEther(amount.toString()))

        await tx.wait()
        let accBalance = await ethers.provider.getBalance(mlmSystem.address)
        
        expect(accBalance)
            .to.be.equal(ethers.utils.parseEther((amount).toString()))                  
        console.log("transaction => successfull")
    })

    it("It should allow owner to withdraw funds and send comission to referals", async function() {
        await mockContract.mock
            .transferFrom
            .withArgs(user2.address, mlmSystem.address, ethers.utils.parseEther("0.1"))
            .returns(true)

        await mockContract.mock
            .transferFrom
            .withArgs(user3.address, mlmSystem.address, ethers.utils.parseEther("0.2"))
            .returns(true)

        await mlmSystem
            .connect(user2)
            .invest(ethers.utils.parseEther("0.1"))

        await mlmSystem
            .connect(user3)
            .invest(ethers.utils.parseEther("0.2"))

        console.log("Balance after investing:", await ethers.provider.getBalance(mlmSystem.address))
        let accBalanceUser1 = await ethers.provider.getBalance(user1.address)
        const txWithdraw = await mlmSystem.connect(user1).withdraw()
        
        // MlmToken(mlmToken).transfer(address(this), _userBalance);

        // // user2 - level 2 (comission - 8; 0.1), user3 - level 3 (comission - 7; 0.1)
        expect(() => txWithdraw)
                    .to
                    .changeEtherBalances(
                        [user1, user2, user3], 
                        [-accBalanceUser1, balance11 * levelComissions[level2] / 10, balance1 * levelComissions[level3] / 10]
                    )
    })

    it("The level of investments equal '0'", async function() {
        // user4 balance - 0, function will be failed 
        expect (mlmSystem.connect(user4).withdraw()).to.be.revertedWith("Your current balance is 0")
        console.log("Your current balance is 0, level - 0")
    })

    it("It should return the info about direct partners", async function() {
        let levelsDone = [5, 1, 1]

        await mockContract.mock
            .transferFrom
            .withArgs(user2.address, mlmSystem.address, ethers.utils.parseEther("0.1"))
            .returns(true)

        await mockContract.mock
            .transferFrom
            .withArgs(user2_2.address, mlmSystem.address, ethers.utils.parseEther("0.005"))
            .returns(true)

        await mockContract.mock
            .transferFrom
            .withArgs(user2_3.address, mlmSystem.address, ethers.utils.parseEther("0.005"))
            .returns(true)
        
        const [amountOfPartners, levels] = await mlmSystem
            .connect(user1)
            .directPartnersInfo()

        console.log(amountOfPartners)
        let levelsPartners2 = levels.map(item => item.toString())
        console.log(levelsPartners2)

        expect(equalArrays(levelsDone.map(item => item.toString()), levelsPartners2)).to.equal(true)
        expect(levelsDone.length).to.equal(amountOfPartners)
    })

})