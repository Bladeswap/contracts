// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/SwapAuxillaryFacet.sol";
import "contracts/pools/vc/LVC.sol";
import "contracts/pools/vc/VeVC.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/wombat/WombatPool.sol";
import "contracts/pools/wombat/WombatRegistry.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/InspectorFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/sale/VoterFactory.sol";

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");
        vm.startBroadcast(deployerPrivateKey);

        WombatRegistry reg = WombatRegistry(0x111A6d7f5dDb85776F1b6A6DEAbe552815559f9E);
        IVault vault = IVault(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535);
        WombatPool wombat = new WombatPool(
            address(reg),
            vault,
            0.0005e18,
            0.00125e18
        );
        wombat.addToken(toToken(IERC20(0x894134a25a5faC1c2C26F1d8fBf05111a3CB9487)), 255);
        wombat.addToken(toToken(IERC20(0x176211869cA2b568f2A7D4EE941E073a821EE1ff)), 255);
        reg.register(wombat);
        vm.stopBroadcast();
    }
}
