# target: test - calls the "test" django command
lint:
	npm run lint:sol
compile:
	npx hardhat clean
	npx hardhat compile
console:
	npx hardhat console --network localhost
deploy_to_hardhat:
	npx hardhat run scripts/deploy_upgradeable_EmployeeAuthorityWorkerNFT.js --network hardhat
deploy_contracts_to_hardhat:
	npx hardhat run scripts/deploy_upgradeable_EmployeeAuthorityWorkerNFT.js --network localhost
launch_hardhat:
	npx hardhat node --hostname 0.0.0.0
unit_test:
	npx hardhat test test/EmployeeAuthorityWorkerNFT.js
unit_test_all:
	npx hardhat test
mit_to_goerli:
	npx hardhat run scripts/mint/mint_marsa_academy_nft.js --network goerli
