const {  upgrades, ethers } = require("hardhat");

async function main() {
  const MlmSystem = await ethers.getContractFactory("MlmSystem");
  const mlmsSystemProxyDeploy = await upgrades.deployProxy(
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
                {initializer: "initializeInitialValues"}, 
  );
  await mlmsSystemProxyDeploy.deployed();
  console.log(mlmsSystemProxyDeploy.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });