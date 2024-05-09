// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * In a library contract all functions must be declared as internal
 *
 */
library PriceConverter {
    /**
     * Returns the latest price.
     */
    function getPrice(/*AggregatorV3Interface priceFeed*/) internal view returns (uint256) {
        // Address Sepoli ETH/USD 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (
            ,
            /* uint80 roundID */
            int256 price, /*uint startedAt*/
            ,
            ,
        ) = /*uint timeStamp*/
        /*uint80 answeredInRound*/
         priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // 2000.000000000
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount /*, AggregatorV3Interface priceFeed*/) internal view returns (uint256) {
        // uint256 ethPrice = getPrice(priceFeed);
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}
