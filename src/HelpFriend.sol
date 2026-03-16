//SPDX-License-identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

//CUSTOM ERROS

error HelpFriend__SendFailed();
error HelpFriend__NotOwner(address senderAddress);
error HelpFriend__Not_Enough_ETH(uint256 ethDonated);
error HelpFriend__Not_Enough_Balance_To_Withdraw(uint256 contractBalance);

/**
 *@title HelpFriend contract
 *@author ardosino
 *@notice This contract enables people to fund it
 *@notice and when it reaches a certain amount of funds,
 *@notice the owner can withdraw these funds directly to his friend's address
 *@dev Using Chainlink price feed
 */

contract HelpFriend {
    /*TYPE DECLARATIONS */
    using PriceConverter for uint256;

    /*EVENTS */
    event AmountSentToFriendAddress(address indexed friendAddress, uint256 indexed amountSent);

    /*STATE VARIABLES */
    address private immutable i_owner;
    address private immutable i_priceFeed;
    address private immutable i_friendAddress;
    uint256 public constant MINIMUM_USD = 5e18; //Set a minimum of 5 USD to donate
    uint256 public constant TARGET_USD_TO_WITHDRAW = 300e18; //Minimum USD amount required to withdraw
    address[] private s_donors;
    mapping(address => uint256) private s_addressToAmountDonated;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed, address friendAddress) {
        i_owner = msg.sender; //Set the owner as the deployer address
        i_priceFeed = priceFeed;
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_friendAddress = friendAddress;
    }

    /*//////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier OnlyOwner() {
        //Check if the msg.sender is the owner
        if (msg.sender != i_owner) revert HelpFriend__NotOwner(msg.sender);
        _;
    }

    modifier BalanceToWithdraw() {
        //Check the contract's balance to withdraw
        uint256 contractBalance = address(this).balance;
        if (contractBalance.getConversionRate(s_priceFeed) < TARGET_USD_TO_WITHDRAW) {
            revert HelpFriend__Not_Enough_Balance_To_Withdraw(address(this).balance);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    //Donnate to the contract based on the ETH/USD price
    function donate() public payable {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert HelpFriend__Not_Enough_ETH(msg.value);
        }
        s_donors.push(msg.sender); //List the donnator on the array
        s_addressToAmountDonated[msg.sender] += msg.value; //Track the amount each sender donnated
    }

    //Owner withdraw contract's balance to the friend's address
    function withdraw() public OnlyOwner BalanceToWithdraw {
        //Clean up mapping
        uint256 donorsLength = s_donors.length;
        for (uint256 donorsIndex = 0; donorsIndex < donorsLength; donorsIndex++) {
            address donor = s_donors[donorsIndex];
            s_addressToAmountDonated[donor] = 0;
        }

        s_donors = new address[](0); //Reset the array

        //Actually withdraw funds
        uint256 contractBalance = address(this).balance;
        (bool callSucess,) = payable(i_friendAddress).call{value: contractBalance}("");
        if (callSucess == true) {
            emit AmountSentToFriendAddress(i_friendAddress, contractBalance);
        } else {
            revert HelpFriend__SendFailed();
        }
    }

    //If user donates to the contract outside the donate function
    receive() external payable {
        donate();
    }

    //If user donates to the contract outside the donate function
    fallback() external payable {
        donate();
    }

    /*//////////////////////////////////////////////////////////////
                            GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFriendAddress() public view returns (address) {
        return i_friendAddress;
    }

    function getAggregatorV3Interface() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getPriceFeed() public view returns (address) {
        return i_priceFeed;
    }

    function getDonor(uint256 donorIndex) external view returns (address) {
        return s_donors[donorIndex];
    }

    function getAddressToAmountDonated(address donorAddress) external view returns (uint256) {
        return s_addressToAmountDonated[donorAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getBalance() public view returns (uint256) {
        uint256 contractBalance = address(this).balance;
        return contractBalance;
    }

    function getEthPrice() public view returns (uint256) {
        uint256 ethPrice = PriceConverter.getPrice(s_priceFeed);
        return ethPrice;
    }

    /*//////////////////////////////////////////////////////////////
                          GET ERRORS SELECTORS
    //////////////////////////////////////////////////////////////*/

    function getHelpFriendNotOwnerErrorSelector() external pure returns (bytes4) {
        return HelpFriend__NotOwner.selector;
    }

    function getHelpFriendSendFailedErrorSelector() external pure returns (bytes4) {
        return HelpFriend__SendFailed.selector;
    }

    function getHelpFriendNotEnoughEthErrorSelector() external pure returns (bytes4) {
        return HelpFriend__Not_Enough_ETH.selector;
    }

    function getHelpFriendNotEnoughBalanceToWithdrawErrorSelector() external pure returns (bytes4) {
        return HelpFriend__Not_Enough_Balance_To_Withdraw.selector;
    }
}

