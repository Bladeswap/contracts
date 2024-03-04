// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/StdCheats.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/pools/vc/TVC.sol";
import "contracts/pools/vc/VeVC.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/wombat/WombatPool.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/pools/converter/MendiWinder.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";

//address constant oldVC = 0x85D84c774CF8e9fF85342684b0E795Df72A24908;
address constant oldVeVC = 0xbdE345771Eb0c6adEBc54F41A169ff6311fE096F;

contract UpgradeScript is Script, StdCheats {
    function setUp() public {}

    function run() public returns (IVault, VC, VeVC) {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");
        vm.startBroadcast(deployerPrivateKey);
        MendiWinder mw = new MendiWinder(
            Comptroller(0x1b4d3b0421dDc1eB216D230Bc01527422Fb93103),
            IWETH9(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f),
            IVault(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535)
        );
        vm.stopBroadcast();
    }
}
