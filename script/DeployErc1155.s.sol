// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import { MyToken } from "../src/Erc1155.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployErc1155 is Script {
    function run() external returns (MyToken) {

        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        MyToken myToken =new MyToken(address(1), ethUsdPriceFeed);
        vm.stopBroadcast();
        return myToken;
    }
}