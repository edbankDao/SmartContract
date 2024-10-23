## EdbankDao Smart Contract

MarkerDao Forked Project.

contract Address in educhain testnet is in below.

vat : 0x514066e1f24fDA9f2B379748f9C001C3475625cB  
gem : 0x345E902846aC3805719483d80D664ABa0B6aF40C  
gemJoin : 0xD40588c705B99d406B048629E4D8863a2434beF5  
ESD : 0xCef966528A867176BF3a575c9951f695e8eB77a3  
esdJoin : 0x42FfAe0648A84c0AC72D012402f380ab511AcBb1  
cdpManager : 0x0E492702CA0A2048e87A21CE3Ac7E11Be757af2b  
jug : 0x09Fd469b3036E45Dad077Df411134Fb85218678e  
spot : 0x92B7e50CE799e8E26dE7324b3a92e93Dbbdf554F

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
