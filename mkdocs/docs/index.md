<div align="center">
<img src="circom-logo-black.png" width="460px" align="center"/>
</div>

[![Chat on Telegram][ico-telegram]][link-telegram]
[![Website][ico-website]][link-website]
[![GitHub repo][ico-github]][link-github]
![Issues](https://img.shields.io/github/issues-raw/iden3/circom?color=blue)
![GitHub top language](https://img.shields.io/github/languages/top/iden3/circom)
![Contributors](https://img.shields.io/github/contributors-anon/iden3/circom?color=blue)

[ico-website]: https://img.shields.io/website?up_color=blue&up_message=circom&url=https%3A%2F%2Fiden3.io%2Fcircom
[ico-telegram]: https://img.shields.io/badge/@iden3-2CA5E0.svg?style=flat-square&logo=telegram&label=Telegram
[ico-github]: https://img.shields.io/github/last-commit/iden3/circom?color=blue

[link-website]: https://iden3.io/circom
[link-telegram]: https://t.me/iden3io
[link-github]: https://github.com/hermeznetwork/zkevmdoc

---

# zk Ethereum Virtual Machine

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

## [Polynomial Indentity Language (PIL)](zkEVM/PIL/introduction.md)
- Introduction
- State Machines

## zkROM (Ethereum assembly program)

## Prover Workflow
- PIL Compiler
- PIL 2 Circom
- zkASM Compiler
- zkExecutor
- Witness Calculator
- STARK Generator
- SNARK Generator
- SNARK Verifier (Solidity)

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