require('@nomiclabs/hardhat-ethers');
require("dotenv").config()
require("hardhat-deploy");
require('@nomicfoundation/hardhat-toolbox')
require('@openzeppelin/hardhat-upgrades');

module.exports = {
  defaultNetwork: "hardhat",
  solidity: "0.8.12",
  networks: {
    hardhat: {
      gasPrice: 20000000000,
      chainId: 31337,
    },
  },
};