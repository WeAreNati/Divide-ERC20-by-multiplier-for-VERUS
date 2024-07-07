// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import {VerusBridgeObjects} from "../utils/VerusBridgeObjects.sol";

interface IVerusBridge {
    function sendTransfer(VerusBridgeObjects.CReserveTransfer memory _transfer) external payable;
}
