// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { MyToken } from "../src/Erc1155.sol";
import {DeployErc1155} from "../script/DeployErc1155.s.sol";

contract Erc1155Test is Test {
    MyToken public erc1155;

    address USER = makeAddr("user");
    address USER2 = makeAddr("user2");
    address USER3 = makeAddr("user3");
    address USER4 = makeAddr("user4");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BLANCE = 10 ether;

    function setUp() external {
        // erc1155 = new MyToken(address(1));
        DeployErc1155 deployErc1155 = new DeployErc1155();
        erc1155 = deployErc1155.run();
        vm.deal(USER, STARTING_BLANCE);
    }

    function testMininmumDollarIsFive() public view {
        console.log(erc1155.MINIMUM_USD());
        assertEq(erc1155.MINIMUM_USD(), 5 * 1e18);
    }

    function testMintFailsWithoutEnoughFundsAndNotBeeingOnWhitelist() public {
        vm.expectRevert();
        erc1155.mint(0, 100, false);
    }

   function testMintPayingEnoughFundsWithoutWhitelist() public {
        vm.prank(USER);
        // erc1155.mint(0, 100, false);
        // uint256 amountFunded = erc1155.getAddressToAmountFounded(USER4);
        // assertEq(erc1155.balanceOf(USER4, 0), 100);
        // assertEq(amountFunded, SEND_VALUE);
        erc1155.mint{value: 1 ether}(0, 1, false);
        assertEq(erc1155.balanceOf(USER, 0), 1);
   }
}