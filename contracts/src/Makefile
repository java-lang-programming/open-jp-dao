RULE_REGEX := ^[a-zA-Z_][a-zA-Z0-9_-]+:
RULE_AND_DESC_REGEX := $(RULE_REGEX).*?## .*$$
EXTRA_COMMENT_REGEX := ^## .* ##$$
.ONESHELL:
.DEFAULT_GOAL := help
.PHONY: help

# INFO: 参考サイト - https://postd.cc/auto-documented-makefile/ https://zenn.dev/loglass/articles/0016-make-makefile
help:
	@grep -E $(RULE_AND_DESC_REGEX) $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint:
	npm run lint:sol
fix:
	npm run lint:fix
compile:
	npx hardhat clean
	npx hardhat compile
console:
	npx hardhat console --network localhost
deploy_to_hardhat:
	npx hardhat run scripts/deploy_upgradeable_EmployeeAuthorityWorkerNFT.js --network hardhat
deploy_contracts_to_hardhat:
	npx hardhat run scripts/deploy_upgradeable_EmployeeAuthorityWorkerNFT.js --network localhost
	npx hardhat run scripts/deploy_ERC20VotesToken.js --network localhost
deploy_governor_to_hardhat:
	npx hardhat run scripts/deploy_OpenJpDaoGovernor.js --network localhost
deploy_jpycPayment_to_sepolia:
	npx hardhat run scripts/deploy_JpycPayment.js --network sepolia | tee deploy.log
deploy_jpycPayment_to_anvil:
	npx hardhat run scripts/deploy_JpycPayment.js --network sepolia_anvil | tee deploy_sepolia_anvil.log
launch_hardhat:
	npx hardhat node --hostname 0.0.0.0
unit_test:
	npx hardhat test test/EmployeeAuthorityWorkerNFT.js
	npx hardhat test test/EmployeeAuthorityHolderNFT.js
	npx hardhat test test/ERC20VotesToken.js
	npx hardhat test test/OpenJpDaoGovernor.js
	npx hardhat test test/JpycPayment.js
unit_test_all:
	npx hardhat test
mit_to_goerli:
	npx hardhat run scripts/mint/mint_marsa_academy_nft.js --network goerli
ci:
	npx hardhat test
