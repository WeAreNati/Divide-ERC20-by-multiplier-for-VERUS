// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract NetworkConfig {
    struct Config {
        string name;
        string symbol;
        address linkedERC20;
        address verusBridgeContract;
        address thisTokeniAddress;
        address bridgeiAddress;
        address vETHiAddress;
    }

    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    error NetworkConfig__UnsupportedChainId();

    function getConfig() external view returns (Config memory) {
        if (block.chainid == SEPOLIA_CHAIN_ID) return _getSepoliaConfig();
        else if (block.chainid == MAINNET_CHAIN_ID) return _getMainnetConfig();
        else if (block.chainid == LOCAL_CHAIN_ID) return _getLocalConfig();

        revert NetworkConfig__UnsupportedChainId();
    }

    function _getSepoliaConfig() internal pure returns (Config memory) {
        return Config({
            name: _getTokenName(),
            symbol: _getTokenSymbol(),
            linkedERC20: 0xA23DFcF889e9544fa8d7DC8e3774b979F4Ca5bA1,
            verusBridgeContract: 0xffEce948b8A38bBcC813411D2597f7f8485a0689,
            thisTokeniAddress: 0x497cD73d40b72D0fF80A62B189e0D7829083b55e,
            bridgeiAddress: 0xffEce948b8A38bBcC813411D2597f7f8485a0689,
            vETHiAddress: 0x67460C2f56774eD27EeB8685f29f6CEC0B090B00
        });
    }

    function _getMainnetConfig() internal pure returns (Config memory) {
        return Config({
            name: _getTokenName(),
            symbol: _getTokenSymbol(),
            linkedERC20: 0x0B9aE6b1D4f0EEeD904D1CEF68b9bd47499f3fFF,
            verusBridgeContract: 0x71518580f36FeCEFfE0721F06bA4703218cD7F63,
            thisTokeniAddress: 0x497cD73d40b72D0fF80A62B189e0D7829083b55e, // @todo set the correct address
            bridgeiAddress: 0x0200EbbD26467B866120D84A0d37c82CdE0acAEB,
            vETHiAddress: 0x454CB83913D688795E237837d30258d11ea7c752
        });
    }

    function _getLocalConfig() internal pure returns (Config memory) {
        // using the mainnet config as a placeholder for
        return _getMainnetConfig();
    }

    function _getTokenName() internal pure returns (string memory) {
        return "itan.veth";
    }

    function _getTokenSymbol() internal pure returns (string memory) {
        return "itanP";
    }
}
