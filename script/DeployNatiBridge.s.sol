// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";

import {NetworkConfig} from "./config/NetworkConfig.sol";
import {NatiBridge} from "../src/NatiBridge.sol";

contract DeployNatiBridge is Script {
    function run() public returns (NetworkConfig.Config memory, NatiBridge) {
        vm.broadcast();
        NetworkConfig networkConfig = new NetworkConfig();
        NetworkConfig.Config memory config = networkConfig.getConfig();

        NatiBridge natiBridge = new NatiBridge(
            config.name,
            config.symbol,
            config.linkedERC20,
            config.verusBridgeContract,
            config.thisTokeniAddress,
            config.bridgeiAddress,
            config.vETHiAddress
        );

        return (config, natiBridge);
    }
}
