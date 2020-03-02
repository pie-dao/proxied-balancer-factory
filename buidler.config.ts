import { BuidlerConfig, usePlugin, task } from "@nomiclabs/buidler/config";
import { PProxiedBalancerFactoryFactory } from "./typechain/PProxiedBalancerFactoryFactory";
import { PBPoolOverridesFactory } from "./typechain/PBPoolOverridesFactory";

usePlugin("@nomiclabs/buidler-waffle");
usePlugin("@nomiclabs/buidler-etherscan");
usePlugin("buidler-typechain");
usePlugin("solidity-coverage");

const INFURA_API_KEY = "";
const RINKEBY_PRIVATE_KEY = "";
const ETHERSCAN_API_KEY = "";

interface ExtendedBuidlerConfig extends BuidlerConfig {
  [x:string]: any
}

const config: ExtendedBuidlerConfig = {
  defaultNetwork: "buidlerevm",
  solc: {
    version: "0.6.2"
  },
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [RINKEBY_PRIVATE_KEY]
    },
    coverage: {
      url: 'http://127.0.0.1:8555' // Coverage launches its own ganache-cli client
    }
  },
  etherscan: {
    // The url for the Etherscan API you want to use.
    url: "https://api-rinkeby.etherscan.io/api",
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: ETHERSCAN_API_KEY
  },
  typechain: {
    outDir: "typechain",
    target: "ethers"
  }
};

task("deploy-overrides", "deploys the overrides contract")
  .setAction(async (taskArgs, { ethers }) => {
    const signer = (await ethers.getSigners())[0];
    const factory = new PBPoolOverridesFactory(signer);
    const contract = await factory.deploy();

    console.log(`Deployed overrides at: ${contract.address}`);
  });

task("deploy-factory", "deploys the proxied balancer pool factory")
  .addParam("factory", "The address of the Balancer factory contract")
  .addParam("overrides", "The address of the overrides contract")
  .setAction(async (taskArgs, { ethers }) => {
    const signer = (await ethers.getSigners())[0];
    const factory = new PProxiedBalancerFactoryFactory(signer);

    const contract = await factory.deploy(taskArgs.overrides, taskArgs.factory);
    console.log(`Deployed proxied pool factory at: ${contract.address}`);
});

export default config;
