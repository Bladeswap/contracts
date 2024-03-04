// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/token/ERC20/ERC20.sol";

//address constant oldVC = 0x85D84c774CF8e9fF85342684b0E795Df72A24908;
address constant oldVeVC = 0xbdE345771Eb0c6adEBc54F41A169ff6311fE096F;

contract Meme is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10_000_000e18);
    }
}

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Meme("USDB", "USDB");
        vm.stopBroadcast();
    }
}
