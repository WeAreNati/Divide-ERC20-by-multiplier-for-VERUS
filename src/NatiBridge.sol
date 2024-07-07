// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {IVerusBridge} from "./interfaces/IVerusBridge.sol";

import {VerusBridgeObjects} from "./utils/VerusBridgeObjects.sol";

/**
 * @title NatiBridge
 * @author We Are Nati
 * @notice The contract's function is to divide an ERC20's token supply
 * and send it to the Verus Bridge to comply with the 64-bit character
 * limit within Verus.
 *
 * This is a proxy bridge that will store the ERC20 token and create a new token
 * until the new token is returned to the contract and the correct amount
 * of the ERC20 token is sent back to the user.
 */
contract NatiBridge is ERC20 {
    using SafeERC20 for IERC20;

    uint256 public constant CAP = 33e26; // 3.3B with 18 decimal precision
    uint64 public constant VERUS_VETH_TRANSACTION_FEE = 3e5; // 0.003 vETH with 8 decimal precision
    uint8 private constant DEST_PKH = 2;
    uint8 private constant DEST_ID = 4;
    uint32 private constant VALID = 1;
    uint256 private constant SATS_TO_WEI_STD = 1e10;
    uint256 private constant MULTIPLIER = 1e4; // 1M constant for utility purposes

    address payable public immutable linkedERC20; // the token that this contract will accept to divide or multiply
    address public immutable verusBridgeContract; // verus bridge contract
    address public immutable thisTokeniAddress; // this proxy token's i-address in hex
    address public immutable bridgeiAddress;
    address public immutable vETHiAddress;

    error ERC20CapExceeded(uint256 increasedSupply, uint256 CAP);

    modifier onlyVerusBridge() {
        require(msg.sender == verusBridgeContract, "Not Verus Bridge contract");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _linkedERC20,
        address _verusBridgeContract,
        address _thisTokeniAddress,
        address _bridgeiAddress,
        address _vETHiAddress
    ) ERC20(_name, _symbol) {
        linkedERC20 = payable(_linkedERC20);
        verusBridgeContract = _verusBridgeContract;
        thisTokeniAddress = _thisTokeniAddress;
        bridgeiAddress = _bridgeiAddress;
        vETHiAddress = _vETHiAddress;
    }

    function transfer(address to, uint256 amount) public override onlyVerusBridge returns (bool) {
        _burn(msg.sender, amount);

        // send the scaled up amount back to the user on ethereum mainnet
        IERC20(linkedERC20).transfer(to, (amount * MULTIPLIER));

        return true;
    }

    // can only send to r-address on Verus
    function swapToBridge(uint256 _amountToSwap, address addressTo, uint8 addressType) public payable {
        require(msg.value == 0.003 ether, "0.003 ETH required");

        // make sure amount being sent is a multiple of the MULTIPLIER to stop wei being lost in truncation
        require(_amountToSwap % MULTIPLIER == 0, "Not divisible by 1e4");

        // send the real linked ERC20 asset to this contract and it will be stored.
        IERC20(linkedERC20).safeTransferFrom(msg.sender, address(this), _amountToSwap);

        // amount to mint of proxy token that only the bridge accepts
        uint256 amountToMint = _amountToSwap / MULTIPLIER;
        if (amountToMint + totalSupply() > CAP) {
            revert ERC20CapExceeded(amountToMint + totalSupply(), CAP);
        }

        _mint(address(this), amountToMint);
        _approve(address(this), verusBridgeContract, amountToMint);

        uint64 verusAmount = uint64(amountToMint / SATS_TO_WEI_STD); // from 18 decimals to 8

        IVerusBridge(verusBridgeContract).sendTransfer{value: msg.value}(
            buildReserveTransfer(verusAmount, addressTo, addressType)
        );
    }

    function buildReserveTransfer(uint64 value, address sendTo, uint8 addressType)
        internal
        view
        returns (VerusBridgeObjects.CReserveTransfer memory)
    {
        require(addressType == DEST_PKH || addressType == DEST_ID, "Invalid address type");

        VerusBridgeObjects.CReserveTransfer memory LPtransfer = VerusBridgeObjects.CReserveTransfer({
            version: 1,
            currencyvalue: VerusBridgeObjects.CCurrencyValueMap({currency: thisTokeniAddress, amount: value}),
            flags: VALID,
            feecurrencyid: vETHiAddress,
            fees: VERUS_VETH_TRANSACTION_FEE,
            destination: VerusBridgeObjects.CTransferDestination({
                destinationtype: addressType,
                destinationaddress: abi.encodePacked(sendTo)
            }),
            destcurrencyid: bridgeiAddress,
            destsystemid: address(0),
            secondreserveid: address(0)
        });

        return LPtransfer;
    }
}
