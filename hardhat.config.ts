import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-etherscan'
import '@nomiclabs/hardhat-waffle'
import '@typechain/hardhat'
import 'hardhat-deploy'
import 'hardhat-deploy-ethers'
import 'hardhat-preprocessor'
import { config as dotenvConfig } from 'dotenv'
import type { HardhatUserConfig, task } from 'hardhat/config'

import fs from 'fs'
import { resolve } from 'path'

import "@matterlabs/hardhat-zksync-toolbox";
import "@matterlabs/hardhat-zksync-solc";
const remappings = fs
  .readFileSync('remappings.txt', 'utf8')
  .split('\n')
  .filter(Boolean)
  .map(line => line.trim().split('='))

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  zksolc: {
    version: "1.3.5",
    compilerSource: "binary",  // binary or docker (deprecated)
    settings: {
      optimizer: {
        enabled: true,
      },
      compilerPath: "./zksolc",  // ignored for compilerSource: "docker"
      libraries: {}, // optional. References to non-inlinable libraries
      isSystem: false, // optional.  Enables Yul instructions available only for zkSync system contracts and libraries
      forceEvmla: false // optional. Falls back to EVM legacy assembly if there is a bug with Yul
    }
  },
  networks: {
    test: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "goerli",
      accounts: [process.env.VELOCORE_DEPLOYER!],
      zksync: true,
      verifyURL: 'https://zksync2-testnet-explorer.zksync.dev/contract_verification'
    },
    zksync: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: "ethereum",
      accounts: [process.env.VELOCORE_DEPLOYER!],
      zksync: true,
      verifyURL: 'https://zksync2-mainnet-explorer.zksync.io/contract_verification'
    },
    goerli: {
      url: "https://rpc.ankr.com/eth_goerli" // URL of the Ethereum Web3 RPC (optional)
    },
    ethereum: {
      url: "https://rpc.ankr.com/eth" // URL of the Ethereum Web3 RPC (optional)
    },
    anvil: {
      url: "http://localhost:8545" // URL of the Ethereum Web3 RPC (optional)
    },
  },
  namedAccounts: {
    deployer: 0
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  etherscan: {
    apiKey: {
    }
  },
  paths: {
    cache: "./cache_hardhat",
  },
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
}

export default config

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line: string) => line.trim().split("="));
}
