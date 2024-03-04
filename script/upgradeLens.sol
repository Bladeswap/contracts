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
import "contracts/pools/xyk/XYKPoolFactory.sol";
import "contracts/pools/stableswap/StableSwapPoolFactory.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";

//address constant oldVC = 0x85D84c774CF8e9fF85342684b0E795Df72A24908;
address constant oldVeVC = 0xbdE345771Eb0c6adEBc54F41A169ff6311fE096F;

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public returns (IVault, VC, VeVC) {
        vm.startBroadcast();
        Lens(0x82eb3c8cC8F13FA1092779d70110f3C2623E5DEB).upgrade(
            address(
                new VelocoreLens(
                    NATIVE_TOKEN,
                    VC(0x7D98803cfc3077370BA9bBb532C089c7635f191B),
                    XYKPoolFactory(
                      0x119AdEDe46599e9743fffFC33945E6E48d9f21D0
                    ),
                    StableSwapPoolFactory(0x75cB3eC310d3D1E22637F79D61eab5D9aBCD68BD),
                    VelocoreLens(0x82eb3c8cC8F13FA1092779d70110f3C2623E5DEB)
                )
            )
        );
        // add voterfactory
        vm.stopBroadcast();
    }
}
