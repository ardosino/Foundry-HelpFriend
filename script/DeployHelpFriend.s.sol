//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {HelpFriend} from "../src/HelpFriend.sol";

contract DeployHelpFriend is Script {
    function run() external returns (HelpFriend) {
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeNetworkConfig();
        (address friendAddress) = helperConfig.friendAddress();

        vm.startBroadcast();
        HelpFriend helpFriend = new HelpFriend(priceFeed, friendAddress);
        vm.stopBroadcast();
        return helpFriend;
    }
}
