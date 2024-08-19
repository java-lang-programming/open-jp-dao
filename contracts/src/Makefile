# target: test - calls the "test" django command
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
launch_hardhat:
	npx hardhat node --hostname 0.0.0.0
unit_test:
	npx hardhat test test/EmployeeAuthorityWorkerNFT.js
	npx hardhat test test/EmployeeAuthorityHolderNFT.js
	npx hardhat test test/ERC20VotesToken.js
	npx hardhat test test/OpenJpDaoGovernor.js
unit_test_all:
	npx hardhat test
mit_to_goerli:
	npx hardhat run scripts/mint/mint_marsa_academy_nft.js --network goerli
ci:
	npx hardhat test
