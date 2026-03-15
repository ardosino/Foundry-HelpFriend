//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/* ERROR */
error HelperConfig__InvalidChainId();

contract HelperConfig is Script {
    //If we are on a local anvil, we deploy mocks
    //otherwise, grab the price feed address from the live network

    /* INPUT PARAMATERS */
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    /*//////////////////////////////////////////////////////////////
                               CHAIN IDS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant ZKSYNC_CHAIN_ID = 324;
    uint256 public constant MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_ANVIL_CHAIN_ID = 31337;

    /*//////////////////////////////////////////////////////////////
                          ETH/USD PRICE FEEDS
    //////////////////////////////////////////////////////////////*/

    address public constant ETH_USD_MAINNET_PRICE_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant ETH_USD_SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public constant ETH_USD_ZKSYNC_SEPOLIA_PRICE_FEED = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF;
    address public constant ETH_USD_ZKSYNC_MAINNET_PRICE_FEED = 0x6D41d1dc818112880b40e26BD6FD347E41008eDA;

    /*//////////////////////////////////////////////////////////////
                        TYPES AND STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed
    }

    NetworkConfig public activeNetworkConfig;
    address public constant friendAddress = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    /*//////////////////////////////////////////////////////////////
                               SETTING UP
    //////////////////////////////////////////////////////////////*/

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainNetEthConfig();
        } else if (block.chainid == ZKSYNC_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getZkSyncSepoliaEthConfig();
        } else if (block.chainid == ZKSYNC_CHAIN_ID) {
            activeNetworkConfig = getZkSyncEthConfig();
        } else if (block.chainid == LOCAL_ANVIL_CHAIN_ID) {
            activeNetworkConfig = getAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({priceFeed: ETH_USD_MAINNET_PRICE_FEED});
        return sepoliaEthConfig;
    }

    function getMainNetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory MainNetEthConfig = NetworkConfig({priceFeed: ETH_USD_MAINNET_PRICE_FEED});
        return MainNetEthConfig;
    }

    function getZkSyncSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ZkSyncSepoliaEthConfig = NetworkConfig({priceFeed: ETH_USD_ZKSYNC_SEPOLIA_PRICE_FEED});
        return ZkSyncSepoliaEthConfig;
    }

    function getZkSyncEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ZkSyncEthConfig = NetworkConfig({priceFeed: ETH_USD_ZKSYNC_MAINNET_PRICE_FEED});
        return ZkSyncEthConfig;
    }

    /*//////////////////////////////////////////////////////////////
                             LOCAL CONFIGS
    //////////////////////////////////////////////////////////////*/

    //Deploy a mock and return it's address
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory AnvilEthConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return AnvilEthConfig;
    }
}
