[ToC]





# zkProver State Machines - An Overview





Core to the integrity of the Polygon zkEVM is its zero-knowledge Prover, also called **zkProver**.

This document seeks to provide a detailed architectural description of the zkProver without delving deep into its technical complexities. It also serves to introduce the zkProver's state machines in a cursory manner. It is, therefore, a prelude to the state machines' documentation. 


## Introduction

The design paradigm at Polygon Hermez has shifted towards developing a zero-knowledge virtual machine (zkEVM) that emulates the Ethereum Virtual Machine (EVM).

Proving and verification of the transactions in Hermez 2.0 are handled by a zero-knowledge prover component called zkProver.

Before we go deeper into explaining the state machines, note that the zkProver is nothing but a component in the Polygon Hermez zkEVM architecture and the only one responsible for proving.

In order to lay the context for the state machines, recall that the zkProver mainly interacts with two other components, the Node and the Database (DB).



<p align="center"><img src="figures/fig1-zkprv-and-node.png" width="600" /></p>
<div align="center"><b> Figure 1: zkProver, Database, and Node </b></div>

<br>

As depicted in Figure 1 above: 

1. The Node first sends the content of the Merkle trees to the DB (to be stored there). 
2. The Node then sends the input transactions to the zkProver. 
3. The zkProver accesses the DB, thereby fetching the information it needs to produce verifiable proofs of the transactions that were sent by the Node. This information consists of, among other data, the Merkle tree roots, the keys and the hashes of the relevant siblings. 
4. The zkProver then generates the proofs of the transactions, and sends these proofs back to the Node. 

But this only scratches the surface of what all a zkProver can do. There are a lot more details involved in how the zkProver actually creates these verifiable proofs of transactions. And it is where the state machines come into the picture.





## State Machines



The zkProver follows modularity of design to the extend that, except for a few components, it is mainly a cluster of state machines. It has a total of fourteen state machines:

- The Main State Machine (SM) 
- Secondary State Machines: 
    - Binary SM
    - Storage SM 
    - Memory SM
    - Arithmetic SM
    - Keccak Function SM
    - PoseidonG SM
- Auxiliary State Machines: 
    - Padding-PG SM
    - Padding-KK SM
    - Nine2One SM
    - Memory Align SM
    - Norm Gate SM
    - Byte4 SM
    - ROM SM


The modular design of the zkProver allows the Main SM to delegate as many of its duties as possible to other specialist state machines. Thus, efficiency is achieved through delegation.



### Secondary State Machines



The Main SM Executor directly instructs each of the secondary state machines by sending appropriate instructions called ***Actions***, as depicted in Figure 2 below.

The grey boxes shown in the figure indicate ***Actions***, which are specific instructions from the Main SM to the relevant secondary SM.

These instructions dictate how a state should transition in a State Machine. However, every Action, whether from the generic Main SM or the specific SM, must be supported with a proof that it was correctly executed.



<p align="center"><img src="figures/fig2-actions-sec-sm.png" width="800" /></p>
<div align="center"><b> Figure 2: The Main SM Executor's Instructions </b></div>



There are some natural dependencies such as between:

- the Storage State Machine, which uses Merkle trees and the POSEIDON State Machine, which is needed for computing hash values of all the nodes in the storage's Merkle trees.
- Each of the hashing state machines, i.e. the Keccak Function SM and the PoseidonG SM, and their respective padding SMs, i.e. the Padding-KK SM and the Padding-PG SM.





## Two Novel Languages for the zkProver



The Polygon Hermez team has created two novel languages especially for the zkProver: The Zero-Knowledge Assembly (zkASM) language and the Polynomial Identity Language (PIL). 

Since adopting the state machines paradigm means switching from high-level programming to low-level programming, it is not suprising for the zkProver to employ a specially- designed language for the firmware and another for the hardware.



### The Zero-Knowledge Assembly



As an assembly language, the zero-knowledge Assembly is specially designed to map instructions from the zkProver's Main SM to the other state machines. In the case of state machines with the firmware, zkASM is, therefore, the interpreter for the firmware. 

zkASM codes take instructions from the Main SM and generate prescriptive assembly codes for how the specific SM Executor has to execute computations. The Executor's strict adherence to the rules and logic of the zkASM codes enables easy verification of the computations.



### The Polynomial Identities Language 



The Polynomial Identity Language (or PIL) is especially designed for zkProver because almost all the state machines express their computations in terms of polynomials. State transitions in state machines must, therefore, satisfy the computation-specific polynomial identities.

All PIL codes in the zkProver's state machines form the DNA of the Verifier code. 

Recall that the aim of this project is to create the most effective solution for the Blockchain Trilemma: Privacy, Security and Scalablity. And its context is that of an efficient zero-knowledge commitment scheme. Since the most secure and efficient commitment schemes are the Polynomial Commitment Schemes, it was expedient to translate computations into a polynomial language, where verification boils down to testing whether execution satisfies certain polynomial identities or not.



These two languages, zkASM and PIL, were designed keeping in mind the prospects for the broader adoption outside Polygon Hermez.





## The Microprocessor Context



There are two microprocessor-type state machines: the Main SM and the Storage SM. This implies that both these SMs have the firmware and the hardware part.

The firmware part runs the zkASM language to set up the logic and rules, which are expressed in the JSON format and stored in a ROM. The JSON file is then parsed to the specific SM Executor, which then executes Storage Actions in compliance with the rules and logic in the JSON file.

The hardware part, which speaks the Polynomial Identity Language (PIL), defines constraints (or polynomial identities), expresses them in the JSON format, and stores them in the corresponding JSON file. As in the firmware case, these constraints are also parsed to the specific SM Executor because all the computations must be executed in conformance to the polynomial identities.



<p align="center"><img src="figures/fig-micro-pro-pic.png" width="800" /></p>
<div align="center"><b> Figure 3 : Microprocessor State Machine </b></div>



Although these two microprocessor SMs (the Main and the Storage) have the same look and feel, they differ considerably.

For instance, the Storage SM specialises in the execution of the Storage Actions (also called SMT Actions), whilst the Main SM is responsible for a wider range of `Actions`. Nevertheless, the Main SM delegates most of these `Actions` to the specialist state machines. The Storage SM remains secondary in that it also receives instructions from the Main SM, and not the vice-versa.

It is worth noting that each of these microprocessor SMs has its own ROM.





## Hashing in the zkProver



There are two secondary state machines specialising with hashing:
 The Keccak State Machine and the POSEIDON State Machine, where each is an 'automised' version of its standard cryptographic hash function.



### The Keccak State Machine



The deployment of the Keccak hash function is not surprising given the fact that it is deployed on Ethereum  and Polygon Hermez is a zk-rollup, an L2 scaling solution for Ethereum.

The Keccak state machine is a gates state machine, and thus has a set of logic gates (the hardware) along with a set of connections among the gates (the logic). It is a secondary state machine composed of the Keccak SM Hash Generator and the Keccak PIL code, where the latter is for the validation purposes.

A full description of the Keccak SM can be found in its individual document.



### The POSEIDON State Machine



The POSEIDON hash function, although newer than the Keccak hash and still under the scrutiny of cryptoanalysts, has been publicised as a [zk-STARK-friendly hash function](https://starkware.co/hash-challenge/). As such, it is best-suited in the context of zkProver. 

The POSEIDON SM is the most straightforward especially if one is familiar with the internal mechanism of the original Poseidon hash function. 

The hash function's permutation process translates readily to the state transitions of the POSEIDON State Machine. The hash function's twelve input elements, the non-linear substitution layers (the S-boxes) and the linear diffusion layers (the MDS matrices), are directly implemented in the state machine.   

Although a secondary state machine, the POSEIDON SM receives instructions from both the Main SM and the Storage SM.

The POSEIDON SM has the executor part and an internal PIL code, which is a set of verification rules written in the PIL language.

A full description of the POSEIDON SM can be found in its individual document.





## Basic Approach Towards Proving Execution-Correctness



What follows is an outline of the basic approach that proves that the computations were correctly executed in each state machine.

The zkProver's state machines are designed to execute programs as well as to guarantee that these programs are correctly executed.

Each secondary state machine, therefore, consists of its own executor and a PIL program that can be used to check correct execution of all the instructions coming from the Main SM Executor.

Here is a step-by-step outline of how the system achieves proof/verification of transactions:

1. Represent a given computation as a state machine.
2. Express the state changes of the SM as polynomials.
3. Capture traces of the state changes, also called execution traces, as rows of a lookup table.
4. Form polynomial identities/constraints that these state transitions satisfy. 
5. Prover uses a specific polynomial commitment scheme to commit and prove knowledge of the committed polynomials,
[Plookup](https://eprint.iacr.org/2020/315.pdf) is one of the ways to check if the Prover's commited polynomials produce correct traces.

While the polynomial constraints are written in the PIL language, the instructions that are initially part of the zk-assembly are subsequently expressed and stored in JSON format.

The above outline of the proof/verification procedure is explained in the [blogpost] (https://blog.hermez.io/zkevm-documentation/) and is further detailed in the documentation [here](https://docs.hermez.io/zkEVM/architecture/introduction/). <!--this link is not working-->

Although not all verification involves a Plookup, the diagram below briefly illustrates the wide role that Plookup plays in zkProver:



<p align="center"><img src="figures/plook-ops-mainSM-copy.png" width="800" /></p>
<div align="center"><b> Figure 4: Plookup and the zkProver State Machines </b></div>








## Main Components of the zkProver





The zkProver has the following four components: 

- The Executor, which is the Main State Machine Executor
- The STARK Recursion Component
- The CIRCOM Library
- The zk-SNARK Prover



In the following paragraphs, you will get to now how the zkProver uses these components to generate verifiable proofs. Figure 5 towards the end of this document surmises this process. 





### The Executor



The Executor is, in fact, the Main SM Executor. It takes the transactions, the old and the new states, and the ChainID of the Sequencer as inputs (to mention a few).

The Executor also needs: 

- The PIL, which is the list of polynomials and registers
- The ROM, which stores the list of instructions about execution

So, with these inputs, the Executor executes the program on top of the hardware (i.e., the PIL) and generates the committed polynomials, which are the state machine cycles, or a list of all the states. It also generates some public data. The public data forms part of the inputs to the zk-SNARK Verifier.

A full description of the Executor can be found in the Main State Machine's document.





### The STARK Recursion Component



Once the Main SM Executor has converted transactions and the related data to the committed polynomials, the STARK Recursion Component takes the following as inputs to generate a zk-STARK proof:

- The Committed Polynomials
- The Constant Polynomials
- Scripts, which are the lists of the instructions



In an effort to facilitate fast zk-STARK proving, the STARK Recursion Component utilises Fast Reed-Solomon Interactive Oracle Proofs of Proximity (RS-IOPP), also referred to as FRI, for each zk-proof.

The component is referred to as the STARK Recursion because: 

- It actually produces several zk-STARK proofs.

- It collates them into bundles of a few zk-STARK proofs. 

- It produces a new zk-STARK proof for each bundle.

This way, hundreds of the zk-STARK proofs are represented and proved with only one zk-STARK proof.





### The CIRCOM Library



The zk-STARK proof produced by the STARK Recursion Component is the input to a CIRCOM component.

CIRCOM is a [circuits library](https://github.com/socathie/circomlib-ml) used in the zkProver to generate the **witness** for the zk-STARK proof produced by the STARK Recursion Component.

The original CIRCOM [paper](https://www.techrxiv.org/articles/preprint/CIRCOM_A_Robust_and_Scalable_Language_for_Building_Complex_Zero-Knowledge_Circuits/19374986/1) describes it both as a circuits programming language to define Arithmetic circuits and a compiler that generates: 

- A file containing a set of associated Rank-1 Constraints System (R1CS) constraints
- A program (written either in C++ or WebAssembly) to efficiently compute a valid assignment to all the wires of the Arithmetic circuit

Arithmetic circuits are mostly used as standard models for studying the complexity of the computations involving polynomials.

That being said, the CIRCOM component takes as inputs the zk-STARK proof from the Batch Machine Executor and the Verifier Data in order to produce a witness. This witness is in fact an Arithmetic circuit expressed in terms of its R1CS constraints.  





### The zk-SNARK Prover



The last component of the zkProver is the zk-SNARK Prover, in particular, Rapid SNARK. 

Rapid SNARK is a zk-SNARK proof generator, written in C++ and intel assembly, which is very fast in generating proofs of CIRCOM's outputs.

With regards to the zkProver, the Rapid SNARK takes as inputs: 

- The witness from CIRCOM
- The STARK Verifier data, which dictates how the Rapid SNARK must process the data and then generates a zk-SNARK proof.





<p align="center"><img src="figures/fig5-main-prts-zkpr.png" width="800" /></p>
<div align="center"><b> Figure 5: Simplified Data Flow in the zkProver </b></div>





zk-STARK proofs are used because of their speed, and that they require no trusted setup. They are, however, a lot more sizable compared to zk-SNARK proofs. It is for this reason and also the succinctness of the zk-SNARKs that the zkProver uses a zk-SNARK to attest to the correctness of the zk-STARK proofs. zk-SNARKs are, therefore, published as the validity proofs to state changes. This strategy has huge benefits as it causes gas costs to reduce from 5M to 350K.
