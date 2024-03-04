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
import "lzapp/token/oft/v1/ProxyOFT.sol";

interface ILayerZeroRelayerV2 {
    // @notice query price and assign jobs at the same time
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify proof to be relayed
    // @param _userApplication - the source sending contract address. relayers may apply price discrimination to user apps
    // @param _payloadSize - the length of the payload. it is an indicator of gas usage for relaying cross-chain messages
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function assignJob(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint256 _payloadSize,
        bytes calldata _adapterParams
    ) external returns (uint256 price);

    // @notice query the relayer price for relaying the payload and its proof to the destination chain
    // @param _dstChainId - the destination endpoint identifier
    // @param _outboundProofType - the proof type identifier to specify proof to be relayed
    // @param _userApplication - the source sending contract address. relayers may apply price discrimination to user apps
    // @param _payloadSize - the length of the payload. it is an indicator of gas usage for relaying cross-chain messages
    // @param _adapterParams - optional parameters for extra service plugins, e.g. sending dust tokens at the destination chain
    function getFee(
        uint16 _dstChainId,
        uint16 _outboundProofType,
        address _userApplication,
        uint256 _payloadSize,
        bytes calldata _adapterParams
    ) external view returns (uint256 price);

    // @notice withdraw the accrued fee in ultra light node
    // @param _to - the fee receiver
    // @param _amount - the withdrawal amount
    function withdrawFee(address payable _to, uint256 _amount) external;
}

interface ILayerZeroUltraLightNodeV2 {
    function defaultAppConfig(uint16) external;

    function estimateFees(
        uint16 _dstChainId,
        address _ua,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);

    // Relayer functions
    function validateTransactionProof(
        uint16 _srcChainId,
        address _dstAddress,
        uint256 _gasLimit,
        bytes32 _lookupHash,
        bytes32 _blockData,
        bytes calldata _transactionProof
    ) external;

    // an Oracle delivers the block data using updateHash()
    function updateHash(uint16 _srcChainId, bytes32 _lookupHash, uint256 _confirmations, bytes32 _blockData) external;

    // can only withdraw the receivable of the msg.sender
    function withdrawNative(address payable _to, uint256 _amount) external;

    function withdrawZRO(address _to, uint256 _amount) external;

    // view functions
    function getAppConfig(uint16 _remoteChainId, address _userApplicationAddress)
        external
        view
        returns (ApplicationConfiguration memory);

    function accruedNativeFee(address _address) external view returns (uint256);

    struct ApplicationConfiguration {
        uint16 inboundProofLibraryVersion;
        uint64 inboundBlockConfirmations;
        address relayer;
        uint16 outboundProofType;
        uint64 outboundBlockConfirmations;
        address oracle;
    }

    event HashReceived(
        uint16 indexed srcChainId, address indexed oracle, bytes32 lookupHash, bytes32 blockData, uint256 confirmations
    );
    event RelayerParams(bytes adapterParams, uint16 outboundProofType);
    event Packet(bytes payload);
    event InvalidDst(
        uint16 indexed srcChainId, bytes srcAddress, address indexed dstAddress, uint64 nonce, bytes32 payloadHash
    );
    event PacketReceived(
        uint16 indexed srcChainId, bytes srcAddress, address indexed dstAddress, uint64 nonce, bytes32 payloadHash
    );
    event AppConfigUpdated(address indexed userApplication, uint256 indexed configType, bytes newConfig);
    event AddInboundProofLibraryForChain(uint16 indexed chainId, address lib);
    event EnableSupportedOutboundProof(uint16 indexed chainId, uint16 proofType);
    event SetChainAddressSize(uint16 indexed chainId, uint256 size);
    event SetDefaultConfigForChainId(
        uint16 indexed chainId,
        uint16 inboundProofLib,
        uint64 inboundBlockConfirm,
        address relayer,
        uint16 outboundProofType,
        uint64 outboundBlockConfirm,
        address oracle
    );
    event SetDefaultAdapterParamsForChainId(uint16 indexed chainId, uint16 indexed proofType, bytes adapterParams);
    event SetLayerZeroToken(address indexed tokenAddress);
    event SetRemoteUln(uint16 indexed chainId, bytes32 uln);
    event SetTreasury(address indexed treasuryAddress);
    event WithdrawZRO(address indexed msgSender, address indexed to, uint256 amount);
    event WithdrawNative(address indexed msgSender, address indexed to, uint256 amount);
}

contract UpgradeScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("VELOCORE_DEPLOYER");

        vm.startBroadcast(deployerPrivateKey);

        LzApp(0x7d637d806b750B9C9f5d8e4e3634AA6639246924).setTrustedRemote(
            183, hex"48D9CDF4343d95E3B8d8F2BfcFdAE9d495f90cCA7d637d806b750B9C9f5d8e4e3634AA6639246924"
        );

        vm.stopBroadcast();
    }
}
