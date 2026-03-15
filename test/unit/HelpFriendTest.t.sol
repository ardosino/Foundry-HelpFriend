//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {HelpFriend} from "../../src/HelpFriend.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {DeployHelpFriend} from "../../script/DeployHelpFriend.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract HelpFriendTest is Test, HelperConfig {
    HelpFriend helpFriend;

    address USER = makeAddr("user");
    uint256 public constant SEND_VALUE = 200 ether;
    uint256 public constant STARTING_BALANCE = 400 ether;
    uint256 public constant GAS_PRICE = 1;
    address public constant FIRST_LOCAL_ANVIL_PRICE_FEED_MOCK = 0x90193C961A926261B756D1E5bb255e67ff9498A1;

    event AmountSentToFriendAddress(address indexed friendAddress, uint256 indexed amountSent);

    function setUp() external {
        DeployHelpFriend deployHelpFriend = new DeployHelpFriend();
        helpFriend = deployHelpFriend.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                          BASIC FUNCTIONS TEST
    //////////////////////////////////////////////////////////////*/

    function testPriceFeedSetsCorrectly() public view {
        address retrievedPriceFeed = address(helpFriend.getPriceFeed());
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            assertEq(retrievedPriceFeed, ETH_USD_SEPOLIA_PRICE_FEED);
        } else if (block.chainid == ZKSYNC_SEPOLIA_CHAIN_ID) {
            assertEq(retrievedPriceFeed, ETH_USD_ZKSYNC_SEPOLIA_PRICE_FEED);
        } else if (block.chainid == ZKSYNC_CHAIN_ID) {
            assertEq(retrievedPriceFeed, ETH_USD_ZKSYNC_MAINNET_PRICE_FEED);
        } else if (block.chainid == LOCAL_ANVIL_CHAIN_ID) {
            assertEq(retrievedPriceFeed, FIRST_LOCAL_ANVIL_PRICE_FEED_MOCK);
        }
    }

    function testGetVersionIsAccurate() public view {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            uint256 version = helpFriend.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == MAINNET_CHAIN_ID) {
            uint256 version = helpFriend.getVersion();
            assertEq(version, 6);
        } else if (block.chainid == LOCAL_ANVIL_CHAIN_ID) {
            uint256 version = helpFriend.getVersion();
            assertEq(version, 0);
        }
    }

	function testAggregatorV3InterfaceIsCorrect() public view {
		AggregatorV3Interface aggregatorV3Interface = helpFriend.getAggregatorV3Interface();
		assert(aggregatorV3Interface == AggregatorV3Interface(FIRST_LOCAL_ANVIL_PRICE_FEED_MOCK));
	}

    function testMinimumDollarIsFive() public view {
        assertEq(helpFriend.MINIMUM_USD(), 5e18);
    }

    function testTargetUsdToWithdrawIsCorrect() public view {
        assertEq(helpFriend.TARGET_USD_TO_WITHDRAW(), 300e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(helpFriend.getOwner(), msg.sender);
    }

	function testOwnerIsSetCorrectlyOnConstructor() public {
		address owner = helpFriend.getOwner();
		assertEq(owner, msg.sender);
	}

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier donated() {
        vm.startPrank(USER);
        helpFriend.donate{value: SEND_VALUE}();
        vm.stopPrank();
        assert(address(helpFriend).balance > 0);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             TEST EVENTS
    //////////////////////////////////////////////////////////////*/

    function testAmountSentToFriendAddressEmitsEvent() public donated {
        vm.startPrank(helpFriend.getOwner());
        vm.expectEmit(true, true, false, false, address(helpFriend));

        address friendAddress = helpFriend.getFriendAddress();
        emit AmountSentToFriendAddress(address(friendAddress), uint256(SEND_VALUE));
        helpFriend.withdraw();
        vm.stopPrank();
    }

	function testAmountSentToFriendAddressEvent() public donated {
		vm.startPrank(helpFriend.getOwner());
		vm.recordLogs();
		helpFriend.withdraw();
		vm.stopPrank();
		
		Vm.Log[] memory entries = vm.getRecordedLogs();
		bytes32 logFriendAddress = entries[0].topics[1];
		bytes32 amountSent = entries[0].topics[2];

		address friendAddress = address(uint160(uint256(logFriendAddress)));

		assertEq(friendAddress, helpFriend.getFriendAddress());
		assertEq(uint256(amountSent), SEND_VALUE);		
	}
    
    /*//////////////////////////////////////////////////////////////
                           TEST REVERT ERRORS
    //////////////////////////////////////////////////////////////*/

    function testSendFailsWithoutEnoughETH() public {
        uint256 insufficientEthToDonate = 0.001e18;
        bytes4 selector = helpFriend.getHelpFriendNotEnoughEthErrorSelector();
        vm.expectRevert(
        	abi.encodeWithSelector(selector, insufficientEthToDonate)
        );
        helpFriend.donate{value: insufficientEthToDonate}();
    }	

 	function testOnlyOwnerCanWithdraw() public donated {
 		bytes4 selector = helpFriend.getHelpFriendNotOwnerErrorSelector();
    
        vm.startPrank(USER);
        vm.expectRevert(
        	abi.encodeWithSelector(selector, USER)
        );
        helpFriend.withdraw();
        vm.stopPrank();
    }

    function testWithdrawFailsWithoutEnoughETH() public {
        uint256 insufficientEthToWithdraw = 1e18;
        bytes4 selector = helpFriend.getHelpFriendNotEnoughBalanceToWithdrawErrorSelector();

        vm.startPrank(USER);
        helpFriend.donate{value: insufficientEthToWithdraw}();
        vm.stopPrank();

        vm.startPrank(helpFriend.getOwner());
        vm.expectRevert(
        	abi.encodeWithSelector(selector, insufficientEthToWithdraw)
        );
        helpFriend.withdraw();
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                  TEST FUNCTIONS THAT CHANGE THE STATE
    //////////////////////////////////////////////////////////////*/

    function testFriendAddressIsSetCorrectly() public {
        HelperConfig helperConfig = new HelperConfig();
        address deployedFriendAddress = helperConfig.friendAddress();
        address friendAddress = helpFriend.getFriendAddress();
        assertEq(friendAddress, deployedFriendAddress);
    }

    function testDonateUpdatesContractBalance() public donated {
        assertEq(address(helpFriend).balance, SEND_VALUE);
    }

    function testMultipleDonationsUpdatesContractBalance() public {
        uint160 TimesToDonate = 10;
        for (uint160 i; i < TimesToDonate; i++) {
            hoax(address(i), SEND_VALUE);
            helpFriend.donate{value: SEND_VALUE}();
        }

        assertEq(address(helpFriend).balance, SEND_VALUE * TimesToDonate);
    }

    function testReceiveFunction() public {
        vm.startPrank(USER);
        payable(address(helpFriend)).call{value: SEND_VALUE}("");
        vm.stopPrank();
        assertEq(address(helpFriend).balance, SEND_VALUE);
    }

    function testFallbackFunction() public {
        vm.startPrank(USER);
        payable(address(helpFriend)).call{value: SEND_VALUE}("");
        vm.stopPrank();
        assertEq(address(helpFriend).balance, SEND_VALUE);
    }

    function testDonateUpdatesMappingDataStructure() public donated {
        uint256 amountDonated = helpFriend.getAddressToAmountDonated(USER);
        assertEq(amountDonated, SEND_VALUE);
    }

    function testDonateUpdatesArrayOfDonors() public donated {
        address donor = helpFriend.getDonor(0);
        assertEq(donor, USER);
    }

    function testWithdrawWithASingleDonor() public donated {
        //Arrange
        uint256 initialHelpFriendBalance = address(helpFriend).balance;
        uint256 initialFriendBalance = helpFriend.getFriendAddress().balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(helpFriend.getOwner());
        helpFriend.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        uint256 finalHelpFriendBalance = address(helpFriend).balance;
        uint256 finalFriendBalance = helpFriend.getFriendAddress().balance;

        assertEq(finalHelpFriendBalance, 0);
        assert(finalFriendBalance > initialFriendBalance);
        assertEq(finalFriendBalance, SEND_VALUE);
    }

    function testWithdrawFromMultipleDonors() public donated {
        //Arrange
        uint160 numberOfDonors = 10;
        uint160 startingDonorIndex = 1;

        for (uint160 i = startingDonorIndex; i < numberOfDonors; i++) {
            hoax(address(i), SEND_VALUE);
            helpFriend.donate{value: SEND_VALUE}();
        }

        uint256 initialFriendBalance = helpFriend.getFriendAddress().balance;
        uint256 initialHelpFriendBalance = address(helpFriend).balance;

        //Act
        vm.startPrank(helpFriend.getOwner());
        helpFriend.withdraw();
        vm.stopPrank();

        //Assert
        uint256 finalFriendBalance = helpFriend.getFriendAddress().balance;
        uint256 finalHelpFriendBalance = address(helpFriend).balance;

        assertEq(finalHelpFriendBalance, 0);
        assert(finalFriendBalance > initialFriendBalance);
        assertEq(finalFriendBalance, SEND_VALUE * numberOfDonors);
    }

    function testWithdrawCleanUpMapping() public donated {
        vm.startPrank(helpFriend.getOwner());
        helpFriend.withdraw();
        vm.stopPrank();

        uint256 mappingValueAtIndexZero = helpFriend.getAddressToAmountDonated(address(USER));
        assertEq(mappingValueAtIndexZero, 0);
    }

    function testWithdrawResetsArray() public donated {
        vm.startPrank(helpFriend.getOwner());
        helpFriend.withdraw();
        vm.stopPrank();

        vm.expectRevert();
        helpFriend.getDonor(0);
    }
}
