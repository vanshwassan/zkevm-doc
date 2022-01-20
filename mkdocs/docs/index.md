<div align="center">
<img src="logo192.png" align="center"/>
<br /><br />
</div>

[![Chat on Twitter][ico-twitter]][link-twitter]
[![Chat on Telegram][ico-telegram]][link-telegram]
[![Website][ico-website]][link-website]
<!-- [![GitHub repo][ico-github]][link-github] -->
<!-- ![Issues](https://img.shields.io/github/issues-raw/hermeznetwork/zkevmdoc?color=blue) -->
<!-- ![GitHub top language](https://img.shields.io/github/languages/top/hermeznetwork/zkevmdoc) -->
<!-- ![Contributors](https://img.shields.io/github/contributors-anon/hermeznetwork/zkevmdoc) -->

[ico-twitter]: https://img.shields.io/twitter/url?color=blueviolet&label=Polygon%20Hermez&logoColor=blueviolet&style=social&url=https%3A%2F%2Ftwitter.com%2F0xPolygonHermez
[ico-telegram]: https://img.shields.io/badge/telegram-telegram-blueviolet
[ico-website]: https://img.shields.io/website?up_color=blueviolet&up_message=hermez.io&url=https%3A%2F%2Fhermez.io
<!-- [ico-github]: https://img.shields.io/github/last-commit/iden3/circom?color=blue -->

[link-twitter]: https://twitter.com/0xPolygonHermez
[link-telegram]: https://t.me/polygonhermez
[link-website]: https://hermez.io
<!-- [link-github]: https://github.com/hermeznetwork/zkevmdoc -->

---

# Polygon Hermez Docs

Polygon Hermez is Ethereum Layer 2 solution based on succinct validity proofs (aka zero-knowledge proofs) that get periodically submitted and verified on Ethereum.

Polygon Hermez 2.0 is built upon the foundations laid by Hermez.  The main development goal is to launch a zero-knowledge Ethereum Virtual Machine, or zkEVM. This is a revolutionary approach that will recreate all the EVM opcodes using zero-knowledge technology, enabling smart contracts to be deployed on the ZK-Rollup.

Getting the best of two ZK technologies to combine efficiency and speed. While STARK technology will be used for main state validation in the future zkEVM, they are expensive proofs to validate on chain. The solution is to create a Groth16 or PLONK SNARK circuit using circom libraries that will validate the STARK proof.

<br /><br />
# <div align="center"><b>Start [here](zkEVM/architecture/introduction.md) for Polygon Hermez 2.0 docs.</b></div>
<br /><br />

<!-- # Polygon Hermez 2.0 (zk Ethereum Virtual Machine

## [Architecture](zkEVM/architecture/introduction.md)
- Introduction
- Simple State Machine
- Prover Architecture
- MicroVM Architecture (divide and conquer, plookup, permutations)

## zkVMs
- Main (assembly)
- Memory
- Storage (include poseidon hash)
- Arithmetics
- Shifts (left, right)
- Keccack
- Ecrecover
- Comparators
- Binary functions

## [Polynomial Indentity Language (PIL)](zkEVM/PIL/tutorial.md)
- Tutorial
- State Machines

## zkROM (Ethereum assembly program)

## Prover Workflow
- PIL Compiler
- PIL to Circom
- zkASM Compiler
- zkExecutor
- Witness Calculator
- STARK Generator
- SNARK Generator
- SNARK Verifier (Solidity)
- zk-prover server (mock)

## Structures and Protocols
- Proof of Efficiency
- Bridge
- Smart Contracts

## Node

## [Tools & Optimizations](zkEVM/tools-optimizations/merkle-tree.md)
- Merkle Tree
- DFTs

## Related Cryptography
- Groth16
- PLONK
- Plookup
- STARKS

## [References](zkEVM/references.md)

# Hermez 1.0

## [About Hermez 1.0](Hermez_1.0/about/scalability.md)
- [Ethereum Scalability and zk-Rollups](Hermez_1.0/about/scalability.md)
- [Hermez Value Proposition](Hermez_1.0/about/value-proposition.md)
- [Hermez Network Model](Hermez_1.0/about/model.md)
- [Security](Hermez_1.0/about/security.md)

## [Users](Hermez_1.0/users/hermez-wallet.md)
- [Hermez Wallet](Hermez_1.0/users/hermez-wallet.md)
- [Hermez Mainnet](Hermez_1.0/users/mainnet.md)
- [Hermez Testnet](Hermez_1.0/users/testnet.md)
- [Exchanges](Hermez_1.0/users/exchanges.md)

## [Developers](Hermez_1.0/developers/dev-guide.md)
- [Developer Guide](Hermez_1.0/developers/dev-guide.md)
- Protocol
    - [Hermez zkRollup protocol](Hermez_1.0/developers/protocol/hermez-protocol/protocol.md)
        - [Smart contracts](Hermez_1.0/developers/protocol/hermez-protocol/contracts/contracts.md)
        - [Circuits](Hermez_1.0/developers/protocol/hermez-protocol/circuits/circuits.md)
    - [Forging consensus protocol](Hermez_1.0/developers/protocol/consensus/consensus.md)
    - [Withdrawal delayer protocol](Hermez_1.0/developers/protocol/withdrawal-delayer/withdrawal-delayer.md)
- [Examples/SDK](Hermez_1.0/developers/sdk.md)
- [API](Hermez_1.0/developers/api.md)
- [Batch Explorer](Hermez_1.0/developers/batch-explorer.md)
- [Hermez NodePrice Updater](Hermez_1.0/developers/price-updater.md)
- [Glossary](Hermez_1.0/developers/glossary.md)

## [FAQ](Hermez_1.0/faq/end-users.md)
- [End-Users](Hermez_1.0/faq/end-users.md)
- [Integrators](Hermez_1.0/faq/integrators.md)
- [Coordinators](Hermez_1.0/faq/coordinators.md)
- [Proof of Donation](Hermez_1.0/faq/pod.md)
- [Other](Hermez_1.0/faq/other.md) -->