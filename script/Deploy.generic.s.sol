// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Upgrade.sol";
import "contracts/AdminFacet.sol";
import "contracts/SwapFacet.sol";
import "contracts/SwapAuxillaryFacet.sol";
import "contracts/pools/vc/VC.sol";
import "contracts/pools/vc/VeVC.sol";
import "contracts/pools/converter/WETHConverter.sol";
import "contracts/pools/xyk/XYKPoolFactory.sol";
import "contracts/pools/stableswap/StableSwapPoolFactory.sol";
import "contracts/MockERC20.sol";
import "contracts/lens/Lens.sol";
import "contracts/NFTHolderFacet.sol";
import "contracts/InspectorFacet.sol";
import "contracts/SwapHelperFacet.sol";
import "contracts/lens/VelocoreLens.sol";
import "contracts/pools/constant-product/ConstantProductPoolFactory.sol";
import "contracts/pools/constant-product/ConstantProductLibrary.sol";
import "contracts/pools/linear-bribe/LinearBribeFactory.sol";
import "contracts/authorizer/SimpleAuthorizer.sol";

contract Placeholder is ERC1967Upgrade {
    address immutable admin;

    constructor() {
        admin = msg.sender;
    }

    function upgradeTo(address newImplementation) external {
        require(msg.sender == admin, "not admin");
        ERC1967Upgrade._upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external {
        require(msg.sender == admin, "not admin");
        ERC1967Upgrade._upgradeToAndCall(newImplementation, data, true);
    }
}

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

contract WETH9 is IWETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        (bool success,) = msg.sender.call{value: wad}("");
        require(success);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;


        return true;
    }
}

contract DeployScript is Script {
    Deployer public deployer;
    Placeholder public placeholder_;
    IVault public vault;
    VC public vc;
    VeVC public veVC;
    MockERC20 public oldVC;
    XYKPoolFactory public cpf;
    IAuthorizer public auth;
    AdminFacet public adminFacet;
    LinearBribeFactory public lbf;
    WETH9 public weth;
    WETHConverter public wethConverter;
    ConstantProductLibrary public cpl;
    StableSwapPoolFactory public spf;
    VelocoreLens public lens;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");
        vm.startBroadcast(deployerPrivateKey);
        deployer = new Deployer();
        placeholder_ = new Placeholder();
        auth = new SimpleAuthorizer();
        adminFacet = new AdminFacet(
            auth,
            0x1234561fEd41DD2D867a038bBdB857f291864225
        );
        vault = IVault(adminFacet.deploy(vm.getCode("Diamond.yul:Diamond")));
        vc = VC(placeholder());
        veVC = VeVC(placeholder());
        lbf = new LinearBribeFactory(vault);
        weth = new WETH9();
        wethConverter = new WETHConverter(vault, weth);
        lbf.setFeeToken(toToken(veVC));
        lbf.setFeeAmount(1000e18);
        lbf.setTreasury(0x1234561fEd41DD2D867a038bBdB857f291864225);
        SimpleAuthorizer(address(auth)).grantRole(
            keccak256(abi.encodePacked(bytes32(uint256(uint160(address(vault)))), IVault.attachBribe.selector)),
            address(lbf)
        );
        oldVC.mint(100000000e18);
        oldVC.approve(address(vault), type(uint256).max);

        cpl = new ConstantProductLibrary();

        cpf = new XYKPoolFactory(vault);
        spf = new StableSwapPoolFactory(vault);
        cpf.setFee(0.01e9);
        lens = VelocoreLens(address(new Lens(vault)));

        Lens(address(lens)).upgrade(
            address(
                new VelocoreLens(
                    NATIVE_TOKEN,
                    vc,
                    cpf,
                    spf,
                    VelocoreLens(address(lens))
                )
            )
        );

        vault.admin_addFacet(new SwapFacet(vc, weth, toToken(veVC)));
        vault.admin_addFacet(new SwapAuxillaryFacet(vc, toToken(veVC)));
        vault.admin_addFacet(new NFTHolderFacet());
        vault.admin_addFacet(new InspectorFacet());
        vault.admin_addFacet(new SwapHelperFacet(address(vc), cpf, spf));
        Placeholder(address(vc)).upgradeToAndCall(
            address(
                new VC(
                    address(vc),
                    vault,
                    toToken(IERC20(address(0))),
                    address(veVC)
                )
            ),
            abi.encodeWithSelector(VC.initialize.selector)
        );

        Placeholder(address(veVC)).upgradeToAndCall(
            address(new VeVC(address(veVC), vault, IVotingEscrow(address(0)), vc)),
            abi.encodeWithSelector(VeVC.initialize.selector)
        );

        cpf.deploy(NATIVE_TOKEN, toToken(vc));
        vm.stopBroadcast();

        console.log("authorizer: %s", address(auth));
        console.log("IVault: %s", address(vault));
        console.log("Lens: %s", address(lens));

        console.log("cpf: %s", address(cpf));
        console.log("vc: %s", address(vc));
        console.log("veVC: %s", address(veVC));
        console.log("LinearBribeFactory: %s", address(lbf));
        console.log("WETH: %s", address(weth));
        console.log("WETHConverter: %s", address(wethConverter));
    }

    function run3(
        uint256 value,
        IPool pool,
        uint8 method,
        Token t1, //token
        uint8 m1, //method
        int128 a1, //amount
        Token t2,
        uint8 m2,
        int128 a2,
        Token t3,
        uint8 m3,
        int128 a3
    ) public {
        Token[] memory tokens = new Token[](3);

        VelocoreOperation[] memory ops = new VelocoreOperation[](1);

        tokens[0] = (t1);
        tokens[1] = (t2);
        tokens[2] = (t3);

        ops[0].poolId = bytes32(bytes1(method)) | bytes32(uint256(uint160(address(pool))));
        ops[0].tokenInformations = new bytes32[](3);
        ops[0].data = "";

        ops[0].tokenInformations[0] =
            bytes32(bytes1(0x00)) | bytes32(bytes2(uint16(m1))) | bytes32(uint256(uint128(uint256(int256(a1)))));
        ops[0].tokenInformations[1] =
            bytes32(bytes1(0x01)) | bytes32(bytes2(uint16(m2))) | bytes32(uint256(uint128(uint256(int256(a2)))));
        ops[0].tokenInformations[2] =
            bytes32(bytes1(0x02)) | bytes32(bytes2(uint16(m3))) | bytes32(uint256(uint128(uint256(int256(a3)))));
        vault.execute{value: value}(tokens, new int128[](3), ops);
    }

    function run2(uint256 value, IPool pool, uint8 method, Token t1, uint8 m1, int128 a1, Token t2, uint8 m2, int128 a2)
        public
    {
        Token[] memory tokens = new Token[](2);

        VelocoreOperation[] memory ops = new VelocoreOperation[](1);

        tokens[0] = (t1);
        tokens[1] = (t2);

        ops[0].poolId = bytes32(bytes1(method)) | bytes32(uint256(uint160(address(pool))));
        ops[0].tokenInformations = new bytes32[](2);
        ops[0].data = "";

        ops[0].tokenInformations[0] =
            bytes32(bytes1(0x00)) | bytes32(bytes2(uint16(m1))) | bytes32(uint256(uint128(uint256(int256(a1)))));
        ops[0].tokenInformations[1] =
            bytes32(bytes1(0x01)) | bytes32(bytes2(uint16(m2))) | bytes32(uint256(uint128(uint256(int256(a2)))));
        vault.execute{value: value}(tokens, new int128[](2), ops);
    }

    function placeholder() internal returns (address) {
        return deployer.deployAndCall(vm.getCode("DumbProxy.yul:DumbProxy"), abi.encode(placeholder_));
    }
}
