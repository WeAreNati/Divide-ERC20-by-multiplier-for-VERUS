/ SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
 * @title Contract function is to devide a ERC20's token supply 
 * and send it to the Verus Bridge to comply with the 64bit character
 * limit within Verus. (9,999,999,999B)
 * 
 * This is a proxy bridge that will store the ERC20 token and create a new token
 * until the new token is returned to the contract and the correct amount 
 * of the ERC token is sent back to the user. 
 *
 * Code is currrently routed to the VerusTestBridge for testing.
 *
 * @dev implementation
 */

 library Objects {
    struct CTransferDestination {
        uint8 destinationtype;
        bytes destinationaddress;
    }

    struct CCurrencyValueMap {
        address currency;
        uint64 amount;
    }

    struct CReserveTransfer {
        uint32 version;
        CCurrencyValueMap currencyvalue;
        uint32 flags;
        address feecurrencyid;
        uint64 fees;
        CTransferDestination destination;
        address destcurrencyid;
        address destsystemid;
        address secondreserveid;
    }
 }

interface VerusBridge {
    function sendTransfer(Objects.CReserveTransfer memory _transfer) external payable;
}
 
contract GNATI_BRIDGE_TEST_0 is ERC20{
    address payable immutable linkedERC20; //the token that this contract will accept to divide an dmultiply
    address private immutable thisTokeniaddress;  //this proxytokens iaddress in hex
    uint256 private constant cap = 999999999999999999;  //9,999,999,999.99999999
    address private immutable verusBridgeContract; //verus bridgecontract
    uint256 private constant multiplier = 1000000;  // to convert from 18 decomials ETH to 8 deimals Verus
    using SafeERC20 for GNATI_BRIDGE_TEST_0;
    uint constant SATS_TO_WEI_STD = 10000000000;

    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);
    uint8 constant DEST_PKH = 2;
    uint32 constant VALID = 1;
    uint64 constant public verusvETHTransactionFee = 300000; //0.003 vETH 8 decimals
    // Currenctly coded for VerusTestnet
    address bridgeiaddress = 0xffEce948b8A38bBcC813411D2597f7f8485a0689;
    address vETHiaddress = 0x67460C2f56774eD27EeB8685f29f6CEC0B090B00;
    // address bridgeiaddress = 0x0200EbbD26467B866120D84A0d37c82CdE0acAEB;
    // address vETHiaddress = 0x454CB83913D688795E237837d30258d11ea7c752;
    using SafeERC20 for GNATI_BRIDGE_TEST_0;

    constructor (string memory _name, string memory _symbol, address payable _linkedERC20,
        address iaddress, address _verusBridgeContract) 
        ERC20(_name, _symbol){
        linkedERC20 = _linkedERC20;
        thisTokeniaddress = iaddress;
        verusBridgeContract = _verusBridgeContract;
    }


    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();

        require (owner == verusBridgeContract); 
        _transfer(owner, address(this), amount);
        _burn(msg.sender, amount);

        //send the scaled up amount back to the user on ETH
        ERC20(linkedERC20).transfer(to, (amount * multiplier));
 
        return true;
    }

    //only can send to r-address on Verus
    function swapToBridge(uint256 _amountToSwap, address raddressTo) public payable {
        
        require(msg.value == 0.003 ether);

        // send the real linked ERC20 asset to this contract and it will be stored.
        GNATI_BRIDGE_TEST_0(linkedERC20).safeTransferFrom(msg.sender, address(this), _amountToSwap);
        
        // amount to mint of proxy token that only the bridge accepts
        uint256 amountToMint = _amountToSwap / multiplier;

        if ((amountToMint + totalSupply()) > cap) {
            revert ERC20ExceededCap((amountToMint + totalSupply()) , cap);
        }
        _mint(verusBridgeContract, amountToMint);

        uint64 verusAmount = uint64(amountToMint / SATS_TO_WEI_STD); // from 18 decimals to 8

        VerusBridge(verusBridgeContract).sendTransfer{value: msg.value}(buildReserveTransfer(verusAmount, raddressTo));
    }
  

    function buildReserveTransfer (uint64 value, address sendTo) private view returns (Objects.CReserveTransfer memory) {
        
        Objects.CReserveTransfer memory LPtransfer;
      
        LPtransfer.version = 1;
        LPtransfer.destination.destinationtype = DEST_PKH; //only can send to r-address
        LPtransfer.destcurrencyid = bridgeiaddress;
        LPtransfer.destsystemid = address(0);
        LPtransfer.secondreserveid = address(0);
        LPtransfer.flags = VALID;
        LPtransfer.destination.destinationaddress = abi.encodePacked(sendTo);
        LPtransfer.currencyvalue.currency = thisTokeniaddress;
        LPtransfer.feecurrencyid = vETHiaddress;
        LPtransfer.fees = verusvETHTransactionFee;
        LPtransfer.currencyvalue.amount = value;          
        
        return LPtransfer;
    }
}
