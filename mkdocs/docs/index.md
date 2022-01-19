<div align="center">
<!-- <img src="circom-logo-black.png" width="460px" align="center"/> -->
</div>

<!-- [![Chat on Telegram][ico-telegram]][link-telegram] -->
<!-- [![Website][ico-website]][link-website] -->
<!-- [![GitHub repo][ico-github]][link-github] -->
<!-- ![Issues](https://img.shields.io/github/issues-raw/hermeznetwork/zkevmdoc?color=blue) -->
<!-- ![GitHub top language](https://img.shields.io/github/languages/top/hermeznetwork/zkevmdoc) -->
<!-- ![Contributors](https://img.shields.io/github/contributors-anon/hermeznetwork/zkevmdoc) -->

<!-- [ico-website]: https://img.shields.io/website?up_color=blue&up_message=circom&url=https%3A%2F%2Fiden3.io%2Fcircom -->
<!-- [ico-telegram]: https://img.shields.io/badge/@iden3-2CA5E0.svg?style=flat-square&logo=telegram&label=Telegram -->
<!-- [ico-github]: https://img.shields.io/github/last-commit/iden3/circom?color=blue -->

<!-- [link-website]: https://hermez.io -->
<!-- [link-telegram]: https://t.me/polygonhermez -->
<!-- [link-github]: https://github.com/hermeznetwork/zkevmdoc -->

---

# Hermez 1.0

## About Hermez
- [Ethereum Scalability and zk-Rollups](Hermez_1.0/about/scalability.md)
- [Hermez Value Proposition](Hermez_1.0/about/value-proposition.md)
- [Hermez Network Model](Hermez_1.0/about/model.md)
- [Security](Hermez_1.0/about/security.md)

## Users
- [Hermez Wallet](Hermez_1.0/users/hermez-wallet.md)
- [Hermez Mainnet](Hermez_1.0/users/mainnet.md)
- [Hermez Testnet](Hermez_1.0/users/testnet.md)
- [Exchanges](Hermez_1.0/users/exchanges.md)

## Developers
- [Developer Guide](Hermez_1.0/developers/dev-guide.md)
- [Protocol](Hermez_1.0/developers/)
- [Hermez zkRollup protocol](Hermez_1.0/developers/)
- [Smart contracts](Hermez_1.0/developers/)
- [Circuits](Hermez_1.0/developers/)
- [Forging consensus protocol](Hermez_1.0/developers/)
- [Withdrawal delayer protocol](Hermez_1.0/developers/)
- [Examples/SDK](Hermez_1.0/developers/sdk.md)
- [API](Hermez_1.0/developers/api.md)
- [Batch Explorer](Hermez_1.0/developers/batch-explorer.md)
- [Hermez NodePrice Updater](Hermez_1.0/developers/price-updater.md)
- [Glossary](Hermez_1.0/developers/glossary.md)

## FAQ
- [End-Users](Hermez_1.0/faq/end-users.md)
- [Integrators](Hermez_1.0/faq/integrators.md)
- [Coordinators](Hermez_1.0/faq/coordinators.md)
- [Proof of Donation](Hermez_1.0/faq/pod.md)
- [Other](Hermez_1.0/faq/other.md)

# Polygon Hermez 2.0 (zk Ethereum Virtual Machine)

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
