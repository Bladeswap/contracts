import { HardhatRuntimeEnvironment } from "hardhat/types";
import { utils, Provider, Contract, Wallet } from "zksync-web3";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";


export default async function (hre: HardhatRuntimeEnvironment) {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const wallet = new Wallet(process.env.VELOCORE_DEPLOYER!);
  const deployer = new Deployer(hre, wallet);

  async function deploy(name: string, args: any[]) {
    const contract = await deployer.deploy(await deployer.loadArtifact(name), args);
    await contract.deployed();
    console.log(`${name}: ${contract.address}`);
    return contract;
  }
  const getContractAt = async (name: string, addr: string) => new Contract(addr, (await deployer.loadArtifact(name)).abi, deployer.zkWallet)

  await (await getContractAt("OFT", "0xcB61BC4aE1613abf8662B7003BaD0E2aa3F7D746")).setTrustedRemote(
    199,
    "038b198152a83102F6380ee17d9Fbd69cde9797FcB61BC4aE1613abf8662B7003BaD0E2aa3F7D746"
  );

  return;
  console.log("Asdf")
  const aaa = await deploy("SwapHelperFacet", ["0x544D7D954f7c8f3dF1b0ffCE0736647Eab6a5232"])
  console.log("Asdf")
  await (await getContractAt("AdminFacet", "0xf5E67261CB357eDb6C7719fEFAFaaB280cB5E2A6")).admin_addFacet((aaa).address)

}
