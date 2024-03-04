// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/pools/vc/VC.sol";
import "contracts/pools/vc/VeVC.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/wombat/WombatPool.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/vc/TVC.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";
import "lzapp/token/oft/v1/OFT.sol";

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");

        vm.startBroadcast(deployerPrivateKey);
        LzApp(0x48D9CDF4343d95E3B8d8F2BfcFdAE9d495f90cCA).setTrustedRemote(
            199, hex"7d637d806b750B9C9f5d8e4e3634AA663924692448D9CDF4343d95E3B8d8F2BfcFdAE9d495f90cCA"
        );
        vm.stopBroadcast();
    }
}
