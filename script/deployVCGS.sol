// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/SwapAuxillaryFacet.sol";
import "contracts/pools/vc/TVC.sol";
import "contracts/pools/vc/VeTVC.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/wombat/WombatPool.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/InspectorFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";
import "contracts/sale/VelocoreGirls.sol";
import "contracts/sale/Airdrop.sol";

contract Deployer {
    function deployAndCall(bytes memory bytecode, bytes memory cd) external returns (address) {
        address deployed;
        bool success;
        assembly ("memory-safe") {
            deployed := create(0, add(bytecode, 32), mload(bytecode))
            success := call(gas(), deployed, 0, add(cd, 32), mload(cd), 0, 0)
        }
        require(deployed != address(0) && success);
        return deployed;
    }
}

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");
        vm.startBroadcast(deployerPrivateKey);
        TVC(address(0xe65B77F52d8645EcaD3EdfDf4D3E5b1A9D31f988)).upgradeTo(
            address(
                new TVC(
                    address(0xe65B77F52d8645EcaD3EdfDf4D3E5b1A9D31f988),
                    IVault(0x0117A9094c29e5A3D24ae608264Ce63B15b631d9),
                    toToken(IERC20(address(0))),
                    0x68B1e7eFee0b4ffEC938DD131458567157B4D45d
                )
            )
        );

        vm.stopBroadcast();
    }
}
