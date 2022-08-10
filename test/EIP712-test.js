const { ethers } = require("hardhat")
const { expect, assert, use } = require("chai")
const { Contract, signer, utils, _signTypedData } = require("ethers")
require("@nomiclabs/hardhat-waffle")

describe("MlmEIP712", function() {

    let mlmEIP712, acc1

    before(async function() {
        [acc1] = await ethers.getSigners()
        const mlmEIP712Factory = await ethers.getContractFactory("MlmEIP712")
        mlmEIP712 = await mlmEIP712Factory.deploy()
        await mlmEIP712.deployed()
        console.log("Contract address: ", mlmEIP712.address)
    })

    it("EIP712", async function() {
        const Domain = {
            name: "MlmEIP712",
            version: "0.0.1",
            chainId: 31337,
            verifyingContract: mlmEIP712.address,
        };
        const types = {
            Message: [
                { name: 'from', type: 'address' },
                { name: 'value', type: 'uint256' },
                { name: 'salt', type: 'uint256'},
                { name: 'name', type: 'string' }
            ]
        };
        const message = {
            from: acc1.address,
            value: 10,
            salt: 1337,
            name: "MlmEIP712"
        };

        const signature = await acc1._signTypedData(Domain, types, message)
        expect
            (await mlmEIP712.connect(acc1).verify(signature))
            .to.be.equal(true);
    })
    
})