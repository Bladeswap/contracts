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
import "contracts/pools/wombat/WombatRegistry.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/sale/VoterFactory.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "openzeppelin/governance/TimelockController.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public returns (IVault, VC, VeVC) {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");
        vm.startBroadcast(deployerPrivateKey);
        //address[] memory m = new address[](1);
        //m[0] = 0x1234561fEd41DD2D867a038bBdB857f291864225;
        //TimelockController tc = new TimelockController(7 days, m, m, address(0));

        address vault = 0xf5E67261CB357eDb6C7719fEFAFaaB280cB5E2A6;
        address dev = 0x1234561fEd41DD2D867a038bBdB857f291864225;
        address cpf = 0x544D7D954f7c8f3dF1b0ffCE0736647Eab6a5232;
        address reg = 0xB46E1ed4e1A68cd6cCE76f6a73FA5a42ce2aC032;
        address vf = 0xb3696Be5065c952D64F288db1d568Ffb6A89A6FD;
        address lbf = 0xc137d074DB1F839700eA8bb16d1eF2903e2DE7B2;
        grant(vault, IVault.attachBribe.selector, dev);
        grant(vault, IVault.killBribe.selector, dev);
        grant(vault, IVault.killGauge.selector, dev);
        grant(vault, IVault.admin_pause.selector, dev);
        grant(cpf, ConstantProductPoolFactory.setFee.selector, dev);
        grant(cpf, ConstantProductPoolFactory.setDecay.selector, dev);
        grant(cpf, ConstantProductPool.setParam.selector, dev);
        grant(reg, WombatPool.setDecayRate.selector, dev);
        grant(reg, WombatPool.setFee.selector, dev);
        grant(reg, WombatRegistry.register.selector, dev);
        grant(vf, Voter.sudo_execute.selector, dev);
        grant(vf, Voter.withdrawTokens.selector, dev);
        grant(vf, VoterFactory.deploy.selector, dev);
        grant(lbf, LinearBribeFactory.setFeeAmount.selector, dev);
        grant(lbf, LinearBribeFactory.setTreasury.selector, dev);
        grant(lbf, LinearBribeFactory.setFeeToken.selector, dev);
        SimpleAuthorizer(0xE6D4C953A094Fbc1DBF0D46f51C2B56aB51e9780).grantRole(
            bytes32(0),
            0x73f6353689c11a1b1e4c20C56c901587dD9F52B1
        );
        vm.stopBroadcast();
        /*
        SimpleAuthorizer(address(0xE6D4C953A094Fbc1DBF0D46f51C2B56aB51e9780)).renounceRole(
            0x00, 0x1234561fEd41DD2D867a038bBdB857f291864225
        );

        LinearBribeFactory(0xc137d074DB1F839700eA8bb16d1eF2903e2DE7B2).setFeeAmount(10000e18);
       */
    }

    function grant(address factory, bytes4 selector, address who) internal {
        SimpleAuthorizer(address(0xE6D4C953A094Fbc1DBF0D46f51C2B56aB51e9780))
            .grantRole(
                keccak256(
                    abi.encodePacked(
                        bytes32(uint256(uint160(address(factory)))),
                        selector
                    )
                ),
                who
            );
    }
}
