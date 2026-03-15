# Project Fund Me

#About

This is a smart contract written in Solidity and tested using the Foundry framework. It is a minimal project that allows users to fund the contract through donations.
The contract accepts ETH donations denominated in USD, and contributions below a minimum USD value are rejected. There is also a minimum total amount in USD that must be reached before the owner can withdraw the contract’s balance.
When the owner withdraws the funds, they are sent directly to a friend’s address specified by the owner during the contract’s deployment.
The value is priced using a Chainlink price feed, and the smart contract keepes tracks of doners and the amount donated in case they are to be rewarded in the future.

-[Project Fund Me](#project-fund-me)
-[Getting Started](#getting-started)
	-[Requirements](#requirements)
	-[Quickstart](#quickstart)
-[Usage](#usage)
	-[Deploy](#deploy)
	-[Testing](#testing)
		-[Test Coverage](#test-coverage)
	-[ZkSync](#Zksync)
		-[(Additional) Requirements](#additional-requirements)
-[Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
	-[Scripts](#scripts)
		-[Withdraw](#withdraw)
	-[Estimate gas](#estimate-gas)
-[Formatting](#formatting)
-[Thank you!](#thank-you)

# Getting Started

## Requirements

-[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
	-You’ll know you did it right if you can run ‘git --version’ and you see a response like ‘git version x.x.x’
-[foundry]((https://getfoundry.sh/)
	-You’ll know you did it right if you can run ‘forge --version’ and you see a response like `forge Version: 1.3.0-dev`	

## Quickstart

‘’’
git clone xxxx
cd xxx
make
‘’’

# Usage

## Deploy
‘’’
forge script script/DeployFundMe.s.sol
‘’’

## Testing

‘’’
forge test
‘’’

or

‘’’
//Only run test functions matching the specified regex pattern

forge test --mt <testFunctionName>
‘’’

or

‘’’
forge test --fork-url $SEPOLIA_RPC_URL
‘’’

### Test Coverage

‘’’
forge coverage
‘’’

## ZkSync

The instructions here will allow you to work with this repo on zkSync network

### (Additional) Requirements

In addition to the requiremets above, you’ll need:
-[foundry-zksync](https://github.com/matter-labs/foundry-zksync?tab=readme-ov-file)
	-You’ll know if you did it right if you can run “forge –version” and you see a response like ‘forge Version: 1.0.0-foundry-zksync-v0.0.25’

# Deployment to a testnet or mainnet

1. Setup environment variables

You’l want to set yor ‘SEPOLIA_RPC_URL’ as environment variables. You can add it to a ‘.env’ file.

- ‘SEPOLIA_RPC_URL’ : This is URLof the sepolia testnet node you are working with. You can get setup with one for free from [Alchemy](https://www.alchemy.com/)

You’ll also need to import a wallet to deploy and interact with the contract. You can do it by using ‘cast wallet import’. You can [learn it here](https://getfoundry.sh/cast/reference/wallet/import#cast-wallet-import)

Optionally, add your ‘ETHERSCAN_API_KEY’ if you want to verify your contract on [Etherscan](https://etherscan.io/)

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your Metamask.

3. Deploy

‘’’
forge script script/DeployFundMe.s.sol –rpc-url $SEPOLIA_RPC_URL --account <YOUR ACCOUNT NAME> --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
‘’’

## Scripts

After deploying to a testnet or local node, you can run the the scripts.

Using cast deployed locally example:

‘’’
cast send <FUNDME_CONTRACT_ADDRESS> “fund()” --value 0.1ether --account <YOUR ACCOUNT NAME>
‘’’

or

‘’’
forge script script/Interactions.s.sol:FundFundMe --rpc-url $SEPOLIA_RPC_URL  --account <YOUR ACCOUNT NAME>  --broadcast
forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $SEPOLIA_RPC_URL  --account <YOUR ACCOUNT NAME>  --broadcast
‘’’

### Withdraw 

‘’’
cast send <FUNDME_CONTRACT_ADDRESS> “withdraw()” --account <YOUR ACCOUNT NAME>
‘’’

## Estimate gas 

You can estimate how much gas things cost by running:

‘’’
forge snapshot
‘’’

And you’ll see an output file called ‘.gas-snapshot’

# Formatting

To run code formatting:

‘’’
forge fmt
‘’’

# Thank you

If you appreciated this, feel free to follow me or give me any feedbacks. 

[![ardosino Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://x.com/ardosino)


