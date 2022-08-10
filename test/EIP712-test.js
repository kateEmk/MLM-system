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
    })

    it("EIP712", async function() {
        const types = { 
            Message: [
                { name: 'name', type: 'string' },
                { name: 'from', type: 'address' },
                { name: 'value', type: 'uint256' },
                { name: 'salt', type: 'uint256'},
            ]
        };
        const domain = {
            name: "MlmEIP712",
            version: "0.0.1",
            chainId: 31337,
            verifyingContract: mlmEIP712.address,
        };
        const message = {
            name: "MlmEIP712",
            from: acc1.address,
            value: 10,
            salt: 1337,
            signature: "",
        };

        message.signature = await acc1._signTypedData(domain, types, message)
        expect
            (await mlmEIP712.connect(acc1).verify(message))
            .to.be.equal(true);
    });
})