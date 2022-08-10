require('@nomiclabs/hardhat-ethers');
require("dotenv").config()
require("hardhat-deploy");
require('@nomicfoundation/hardhat-toolbox')
require('@openzeppelin/hardhat-upgrades');

const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

module.exports = {
  defaultNetwork: "hardhat",
  solidity: "0.8.12",
  networks: {
    hardhat: {
      chainId: 31337,
    },
  },
};