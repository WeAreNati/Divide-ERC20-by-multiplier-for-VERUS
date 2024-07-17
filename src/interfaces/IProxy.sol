// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

interface IProxy {
    function swapToBridge(
        uint256 _amountToSwap,
        address addressTo,
        uint8 addressType,
        address bridgeAddress,
        address destinationCurrency,
        address feecurrencyid
    ) external payable;
}
