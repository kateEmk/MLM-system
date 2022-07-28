//const chai = require("chai")
const { ethers } = require("hardhat")
const { expect } = require("chai")
const { Contracts } = require("ethers")

describe("MlmSystem", function() {

    let mlmSystemFactory, mlmSystem
    beforeEach(async function () {
        mlmSystemFactory = await ethers.getContractFactory("MlmSystem")
        mlmSystem = await mlmSystemFactory.deploy()
        await mlmSystemFactory.deployed()
    })

    it("", async function() {

    })

})