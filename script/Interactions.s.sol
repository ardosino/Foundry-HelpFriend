//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelpFriend} from "../src/HelpFriend.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract DonateHelpFriend is Script {
    uint256 public constant SEND_VALUE = 0.05 ether;

    function donateHelpFriend(address mostRecentDeployed) public {
        vm.startBroadcast();
        HelpFriend(payable(mostRecentDeployed)).donate{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Donated to HelpFriend with %s", SEND_VALUE);
    }

    function run() public {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("HelpFriend", block.chainid);
        donateHelpFriend(mostRecentDeployed);
    }
}

contract WithdrawHelpFriend is Script {
    function withdrawHelpFriend(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        HelpFriend(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("HelpFriend", block.chainid);
        withdrawHelpFriend(mostRecentlyDeployed);
    }
}
