// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {console} from "lib/forge-std/src/console.sol";

import {IProxy} from "../src/interfaces/IProxy.sol";

/**
 * @title ProxyTest
 * @author mgnfy-view
 * @notice This is a contract to write tests (POCs) by forking the Ethereum Sepolia Testnet.
 */
contract ProxyTest is Test {
    struct ProxyConfig {
        address linkedERC20;
        address thisTokeniAddress;
        address destinationCurrency;
        address vETHiAddress;
    }

    ProxyConfig public s_config;
    address public s_proxy;
    address public s_verusBridge;
    address public s_natiWhale;
    address public s_receiver;

    uint256 private s_sepoliaFork;
    uint256 private s_rollTo;

    function setUp() public {
        s_config = ProxyConfig({
            linkedERC20: 0xA23DFcF889e9544fa8d7DC8e3774b979F4Ca5bA1,
            thisTokeniAddress: 0xE73b92E469c49A4651AeFf204ecFE920a78022DB,
            destinationCurrency: 0xffEce948b8A38bBcC813411D2597f7f8485a0689,
            vETHiAddress: 0x67460C2f56774eD27EeB8685f29f6CEC0B090B00
        });

        s_proxy = 0xc363C4eda3bEF13984F1E170a6840E0d8Bc777aA;
        s_verusBridge = 0xCaA98A4eC79dAC8A06Cb3BfDcF5351b6576d939f;
        s_natiWhale = 0x4a7C219FB111982C81Ce777F2edBD692663e0A34;

        s_rollTo = 6304433;
        s_receiver = 0x55F51a22c79018A00CEd41e758560F5dF7d4d35d;

        string memory SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
        s_sepoliaFork = vm.createSelectFork(SEPOLIA_RPC_URL);
        vm.rollFork(s_rollTo);
    }

    function testBridgingSmallAmountsLeadsToTokenLoss() public {
        uint256 dealAmount = 0.003 ether;
        deal(s_natiWhale, dealAmount);

        uint8 addresstype = 2;
        uint256 amountToBridge = 5e13;

        uint256 bridgeProxyTokenBalanceBefore = IERC20(s_proxy).balanceOf(s_verusBridge);
        uint256 whaleNatiBalanceBefore = IERC20(s_config.linkedERC20).balanceOf(s_natiWhale);
        uint256 proxyNatiTokenBalanceBefore = IERC20(s_config.linkedERC20).balanceOf(s_proxy);

        vm.startPrank(s_natiWhale);
        IERC20(s_config.linkedERC20).approve(s_proxy, amountToBridge);
        IProxy(s_proxy).swapToBridge{value: dealAmount}(
            amountToBridge, s_receiver, addresstype, s_verusBridge, s_config.destinationCurrency, s_config.vETHiAddress
        );

        uint256 bridgeProxyTokenBalanceAfter = IERC20(s_proxy).balanceOf(s_verusBridge);
        uint256 whaleNatiBalanceAfter = IERC20(s_config.linkedERC20).balanceOf(s_natiWhale);
        uint256 proxyNatiTokenBalanceAfter = IERC20(s_config.linkedERC20).balanceOf(s_proxy);

        assertEq(bridgeProxyTokenBalanceBefore, bridgeProxyTokenBalanceAfter);
        assertEq(whaleNatiBalanceBefore - whaleNatiBalanceAfter, amountToBridge);

        console.log("The proxy tokens held by the verus bridge contract before: ", bridgeProxyTokenBalanceBefore);
        console.log("The proxy tokens held by the verus bridge contract after: ", bridgeProxyTokenBalanceAfter);
        console.log("The NATI tokens held by user before bridging: ", whaleNatiBalanceBefore);
        console.log("The NATI tokens held by user after bridging: ", whaleNatiBalanceAfter);
        console.log("Tokens stuck in the proxy: ", proxyNatiTokenBalanceAfter - proxyNatiTokenBalanceBefore);
    }

    function testProxyRevertsOnZeroAmountBridging() public {
        uint256 dealAmount = 0.003 ether;
        deal(s_natiWhale, dealAmount);

        uint8 addresstype = 2;
        uint256 amountToBridge = 5e13;

        vm.startPrank(s_natiWhale);
        IERC20(s_config.linkedERC20).approve(s_proxy, amountToBridge);
        vm.expectRevert("Insufficient amount to bridge");
        IProxy(s_proxy).swapToBridge{value: dealAmount}(
            amountToBridge, s_receiver, addresstype, s_verusBridge, s_config.destinationCurrency, s_config.vETHiAddress
        );
    }

    function testRoundingDownCausesTokensToBeStuck() public {
        uint256 dealAmount = 0.003 ether;
        deal(s_natiWhale, dealAmount);

        uint8 addresstype = 2;
        uint256 amountToBridge = 1000050000000000000;

        uint256 bridgeProxyTokenBalanceBefore = IERC20(s_proxy).balanceOf(s_verusBridge);
        uint256 proxyNatiTokenBalanceBefore = IERC20(s_config.linkedERC20).balanceOf(s_proxy);

        vm.startPrank(s_natiWhale);
        IERC20(s_config.linkedERC20).approve(s_proxy, amountToBridge);
        IProxy(s_proxy).swapToBridge{value: dealAmount}(
            amountToBridge, s_receiver, addresstype, s_verusBridge, s_config.destinationCurrency, s_config.vETHiAddress
        );

        uint256 bridgeProxyTokenBalanceAfter = IERC20(s_proxy).balanceOf(s_verusBridge);
        uint256 proxyNatiTokenBalanceAfter = IERC20(s_config.linkedERC20).balanceOf(s_proxy);

        uint256 tokensLost = (proxyNatiTokenBalanceAfter - proxyNatiTokenBalanceBefore)
            - (bridgeProxyTokenBalanceAfter - bridgeProxyTokenBalanceBefore) * 1e4;
        console.log("The amount of $NATI tokens stuck in the contract and cannot be recovered: ", tokensLost);
    }
}
