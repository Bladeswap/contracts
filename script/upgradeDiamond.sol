// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/SwapAuxillaryFacet.sol";
import "contracts/pools/vc/LVC.sol";
import "contracts/pools/vc/BLADE.sol";
import "contracts/pools/vc/VeVC.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/wombat/WombatPool.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/SwapHelperFacet.sol";
import "contracts/InspectorFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";
import {VeBlade} from "contracts/pools/vc/veBLADE.sol";
//address constant oldVC = 0x85D84c774CF8e9fF85342684b0E795Df72A24908;

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public returns (IVault, VC, VeVC) {
        vm.startBroadcast();
        IVault vault = IVault(0x10F6b147D51f7578F760065DF7f174c3bc95382c);

        /*
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_addFacet(
            new AdminFacet(IAuthorizer(0x0978112d4Ea277aD7fbf9F89268DEEdDeB743996), address(0))
        );
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_addFacet(
            new SwapFacet(VC(0xcc22F6AA610D1b2a0e89EF228079cB3e1831b1D1), toToken(IERC20(0xAeC06345b26451bdA999d83b361BEaaD6eA93F87)))
        );
        AdminFacet(0x7276C73d787310758D79005152C63C7c74D5Ed92).admin_addFacet(
            new SwapAuxillaryFacet(
               IVC(0x27ADaa4a6719F08Be9306b916E6c7c57A1Dc0c77),
               toToken(IERC20(0xcb89b0124A18960455635f2D1bfdBb21596c1BE9))
            )
        );
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_addFacet(
            new SwapAuxillaryFacet(VC(0xcc22F6AA610D1b2a0e89EF228079cB3e1831b1D1), toToken(IERC20(0xAeC06345b26451bdA999d83b361BEaaD6eA93F87)))
        );
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_addFacet(new NFTHolderFacet());
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_addFacet(new InspectorFacet());
        AdminFacet(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).admin_setTreasury(
            0x1234561fEd41DD2D867a038bBdB857f291864225
        );
        */
        VeBlade(0xF8f2ab7C84CDB6CCaF1F699eB54Ba30C36B95d85).upgradeTo(
            address(
                new VeBlade(address(0xF8f2ab7C84CDB6CCaF1F699eB54Ba30C36B95d85), vault, IVC(0xD1FedD031b92f50a50c05E2C45aF1aDb4CEa82f4))
            )
        );
        /*
        vault.admin_addFacet(new SwapFacet(IVC(0x7D98803cfc3077370BA9bBb532C089c7635f191B), IWETH(0x4200000000000000000000000000000000000023), toToken(IERC20(0x2f793C479D912c378dC42a5fe96487B097Ba4875))));
        vault.admin_addFacet(new SwapAuxillaryFacet(IVC(0x7D98803cfc3077370BA9bBb532C089c7635f191B), toToken(IERC20(0x2f793C479D912c378dC42a5fe96487B097Ba4875))));
        

        Token[] memory tokens = new Token[](1);

        VelocoreOperation[] memory ops = new VelocoreOperation[](1);

        tokens[0] = toToken(LVC(0xcc22F6AA610D1b2a0e89EF228079cB3e1831b1D1));

        ops[0].poolId = bytes32(uint256(uint160(address(0xcc22F6AA610D1b2a0e89EF228079cB3e1831b1D1))));
        ops[0].tokenInformations = new bytes32[](tokens.length);
        ops[0].data = "";

        ops[0].tokenInformations[0] = bytes32(bytes2(0x0001));

        IVault(0x1d0188c4B276A09366D05d6Be06aF61a73bC7535).execute(tokens, new int128[](1), ops);
        */
        vm.stopBroadcast();
    }

    function grant(address factory, bytes4 selector, address who) internal {
        SimpleAuthorizer(address(0x0978112d4Ea277aD7fbf9F89268DEEdDeB743996)).grantRole(
            keccak256(abi.encodePacked(bytes32(uint256(uint160(address(factory)))), selector)), who
        );
    }
}
