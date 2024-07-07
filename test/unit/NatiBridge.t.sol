// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {DeployNatiBridge, NetworkConfig} from "../../script/DeployNatiBridge.s.sol";
import {NatiBridge} from "../../src/NatiBridge.sol";

contract NatiBridgeTest is Test {
    NetworkConfig.Config public networkConfig;
    NatiBridge public natiBridge;

    uint256 private sepoliaFork;
    uint256 private mainnetFork;

    address public natiHodlerSepolia;

    function setUp() public {
        DeployNatiBridge deploy = new DeployNatiBridge();
        (networkConfig, natiBridge) = deploy.run();
    }

    function testInitialization() public view {
        assertEq(natiBridge.name(), networkConfig.name);
        assertEq(natiBridge.symbol(), networkConfig.symbol);
        assertEq(natiBridge.verusBridgeContract(), networkConfig.verusBridgeContract);
        assertEq(natiBridge.thisTokeniAddress(), networkConfig.thisTokeniAddress);
        assertEq(natiBridge.vETHiAddress(), networkConfig.vETHiAddress);
        assertEq(natiBridge.bridgeiAddress(), networkConfig.bridgeiAddress);
    }
}
