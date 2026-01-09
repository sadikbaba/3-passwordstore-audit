// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {PasswordStore} from "src/PasswordStore.sol";

contract TestPasswordStore is Test {

    PasswordStore passwordStore;
    address owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        passwordStore = new PasswordStore();
        vm.stopPrank();
    }


    // @audit test anyone can set password 

    function testAnyOneCanSetPassword(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory randomPassword = "myPassWord";
        passwordStore.setPassword(randomPassword);
        vm.prank(owner);

       string memory actualPassword = passwordStore.getPassword();
       assertEq(actualPassword, randomPassword);
    }
}