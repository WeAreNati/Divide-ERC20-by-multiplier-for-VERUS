// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract VerusBridgeObjects {
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
