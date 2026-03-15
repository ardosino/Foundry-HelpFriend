-include .env

help:
	@echo ""
	@echo "->To deploy:"
	@echo "    make deploy-[NETWORK] --> example: make deploy-SEPOLIA"
	@echo ""
	@echo "->To interact:"
	@echo "    make interact-[NETWORK]-[FUNCTION NAME] --> example: make interact-SEPOLIA-DONATE"
	@echo ""

# DEPLOY TO NETWORKS:
deploy-ANVIL:
	forge script script/DeployHelpFriend.s.sol:DeployHelpFriend --rpc-url $(ANVIL_RPC_URL) --account AnvilAccount1 --broadcast

deploy-SEPOLIA:
	forge script script/DeployHelpFriend.s.sol:DeployHelpFriend --rpc-url $(SEPOLIA_RPC_URL) --account SepoliaTest1 --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-ZKSYNC-SEPOLIA:
	forge script script/DeployHelpFriend.s.sol:DeployHelpFriend --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account zksyncAccount1 --verifier zksync --verifier-url https://explorer.sepolia.era.zksync.dev/contract_verification --verify --broadcast --zksync --legacy

deploy-MAINNET:
	forge script script/DeployHelpFriend.s.sol:DeployHelpFriend --rpc-url $(MAINNET-RPC_URL) --account SepoliaTest1 --broadcast

# INTERACT WITH THE CONTRACT:
interact-ANVIL-DONATE:
	forge script script/Interactions.s.sol:DonateHelpFriend --rpc-url $(ANVIL_RPC_URL) --account AnvilAccount1 --broadcast

interact-ANVIL-WITHDRAW:
	forge script script/Interactions.s.sol:WithdrawHelpFriend --rpc-url $(ANVIL_RPC_URL) --account AnvilAccount1 --broadcast

interact-SEPOLIA-DONATE:
	forge script script/Interactions.s.sol:DonateHelpFriend --rpc-url $(SEPOLIA_RPC_URL) --account SepoliaTest1 --broadcast

interact-SEPOLIA-WITHDRAW:
	forge script script/Interactions.s.sol:WithdrawHelpFriend --rpc-url $(SEPOLIA_RPC_URL) --account SepoliaTest1 --broadcast

interact-ZKSYNC-SEPOLIA-DONATE:
	forge script script/Interactions.s.sol:DonateHelpFriend --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account zksyncAccount1 --broadcast

interact-ZKSYNC-SEPOLIA-WITHDRAW:
	forge script script/Interactions.s.sol:WithdrawHelpFriend --rpc-url $(ZKSYNC_SEPOLIA_RPC_URL) --account zksyncAccount1 --broadcast
