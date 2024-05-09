# ERC-1155

## Necessary contracts to work with the ERC-1155 token

- ERC-1155Account.sol contract MyToken
- whitelist.sol
- PriceConverter.sol

**All the contracts aren't tested against real scenarious on testing tools like Foundry. The contracts are only tested on Remix to test whether the functions work.**

## PrcieConverter.sol

Just deploy the contract. There are no constructor commands to add.

- [] test PriceConverter library on real testnet -> sepolia

## Whitelist.sol

The contract has a constructor that uses a uint number to set up how many addresses are able to be on the whitelist.

constructor set up: uint8
Todo
**Todo**

- [] implement security who can whitelist addresses

### Current steps on Remix testing the functions

- [x] add current address to whitelist
- [] add other address to whitelist -> currently no function to add another address to the whitelist
- [] test whether only owner can add address to whitelist -> currently no function on the contract

## ERC-1155Account.sol contract MyToken

The contract has a constructor that uses an address to set up the address of the whitelist contract.

constructot set up: address

### Thoughts

Currently the contract uses `openzeppelin/contracts/access/AccessControl.sol`
Perhaps it's possible to use `@openzeppelin/contracts/access/Ownable.sol` instead.

Currently, if the account without whitelisted address and pays the necessarry ETH amount thy only get the ERC-20 tokens amount that they inserted but not the whole ERC-20 amount that the suer should get.

### Current steps on Remix testing the functions

- [x] test to mint ERC-20 token from whitelisted address
- [x] test to mint more than 1 ERC-721 token -> revert with error
- [x] test to mint ERC-721 token without enough ERC-20 tokens -> revert with error
- [x] test to mint ERC-721 token after all error testing gone through successfully
- [x] testing the balanceOf function -> success
- [x] test the URI on an ERC-20 token -> revert with error
- [x] test URI function on ERC-721 token -> gone through and shows the URI of the token -> success
- [x] test to mint ERC-20 token from a NOT whitelisted address and NOT paying ETH -> revert with error
- [x] test to mint ERC-20 token from a NOT whitelisted address and PAYING ETH -> success
- [x] test to withdraw the ETH amount on the contract -> address NOT owner / admin -> revert with error
- [x] test to withdraw the ETH amount on the contract -> address IS owner / admin -> success

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
