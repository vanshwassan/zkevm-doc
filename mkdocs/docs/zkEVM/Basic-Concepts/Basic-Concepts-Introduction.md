Polygon zkEVM is a zk-rollup that executes smart contracts transparently, by publishing zero-knowledge validity proofs, while maintaining opcode compatibility with the Ethereum Virtual Machine. Core to its integrity is the zero-knowledge prover, dubbed the **zkProver**. In this section of the documentation we provide an architectural description of the zkProver, highlighting the elements of the proving machinery, without delving into its technical complexities. It is therefore a prelude to the state machines' documentation.

Firstly, we recall briefly that the zkProver operates in the zk-rollup context, producing verifiable zero-knowledge proofs as validity proofs. Secondly, we present the zkProver's state machines in a cursory manner, highlighting their dependencies. And thirdly, we introduce two novel languages that are key to attaining an efficient zkProver. That is, what it takes to create validity proofs, as well as to enable easy verification of these proofs.

Since the zkProver is an algebraic processor, as opposed to an electronic processor, we delineate the arithmetization approach in subsections subsequent to this introduction.





## zkProver And The zkNode



Before delving into the state machines, note that the zkProver is but a component in the Polygon zkEVM, and the only component responsible for proving correctness of zkEVM computations.

In order to lay the context for the state machines, recall that the zkProver mainly interacts with two other components, the Node and the Database (DB).



![Figure 1: zkProver and the Node](figures/intro-zkprv-and-node.png)

<div align="center"><b> Figure 1: zkProver and the Node </b></div>



As depicted in Figure 1 above; 

Firstly, the Node sends the content of Merkle trees to the DB, to be stored there. 

Secondly, the Node sends the input transactions to the zkProver. 

Thirdly, the zkProver accesses the DB, fetching the information it needs to produce verifiable proofs of the transactions sent by the Node. This information consists of, among others, the Merkle roots, the keys and hashes of relevant siblings. 

Fourthly, the zkProver generates the proofs of transactions, and sends these proofs back to the Node. 

But this only scratches the surface of what the zkProver does. There is a lot more detail involved in how the zkProver actually creates these verifiable proofs of transactions. And, it is in these details that the state machines come into the picture.





## State Machines



The zkProver follows modularity of design to the extend that, except for a few components, it is mainly a cluster of state machines. It has a total of fourteen (14) state machines;

- The Main State Machine, 
- Secondary state machines; The Binary SM, the Storage SM, the Memory SM, the Arithmetic SM, the Keccak Function SM, and the PoseidonG SM,
- Auxiliary state machines; The Padding-PG SM, the Padding-KK SM, the Nine2One SM, the Memory Align SM, the Norm Gate SM, the Byte4 SM, and the ROM SM.

The modular design of the zkProver allows the Main SM to delegate as many of its duties as possible to other specialist state machines. As such, efficiency is achieved through delegation.



### Secondary State Machines



The Main SM Executor directly instructs each of the secondary state machines by sending appropriate instructions called ***Actions***, as depicted in Figure 2 below.

The grey boxes in Figure 2 below, do not represent state machines but ***Actions***, which are specific instructions from the Main SM to the relevant secondary SM.

These instructions dictate how a state should transition in a state machine. However, every "Action" performed, whether by the generic Main SM or the specific SM, must be supported with proof that it was correctly executed.



![Figure 2: The Main SM Executor's Instructions](figures/fig2-actions-sec-sm.png)

<div align="center"><b> Figure 2: The Main SM Executor's Instructions </b></div>



There are some natural dependencies such as between; 

- the Storage State Machine which uses merkle Trees and the $\text{POSEIDON}$ State Machine, which is needed for computing hash values of all nodes in the Storage's Merkle Trees.
- Each of the hashing state machines, Keccak Function SM and the PoseidonG SM, and their respective padding state machines, the Padding-KK SM and the Padding-PG SM.





## Two Novel Languages For The zkProver



The Polygon Hermez team has created two novel languages especially for the zkProver; The Zero-Knowledge Assembly language and the Polynomial Identity Language. 

Since adopting the state machines paradigm means switching from highlevel programming to low-level programming, it is not suprising for the zkProver to employ an especially designed language for the firmware and another for the hardware.



### The Zero-Knowledge Assembly

As an Assembly language, the Zero-Knowledge Assembly (or zkASM) language is specially designed to map instructions from the zkProver's Main SM to other state machines. In the case of state machines with the firmware, zkASM is therefore the interpreter for the firmware. 

zkASM codes take instructions from the Main SM and generate prescriptive assembly codes for how the specific SM Executor has to execute computations. The Executor's strict adherence to the rules and logic of the zkASM codes, enables easy verification of computations.



### The Polynomial Identities Language

The Polynomial Identity Language (or PIL) is a domain-specific language for defining polynomial constraints of the executional trace in state machines. It was especially designed for the zkProver, because almost all state machines express computations in terms of polynomials. State transitions in state machines must therefore satisfy computation-specific polynomial identities or constraints.

Since the  context is that of an efficient Zero-Knowledge Commitment Scheme, and the most secure and efficient commitment schemes are the Polynomial Commitment Schemes, it was expedient to translate computations into some polynomial language, where verification boils down to testing whether execution satisfies certain polynomial constraints. All PIL codes, in the zkProver's state machines, therefore form the very DNA of the verifier code. 


These two languages, [zkASM](https://docs.hermez.io/zkEVM/zkASM/introduction/) and [PIL](https://docs.hermez.io/zkEVM/PIL/introduction/), were designed mindful of prospects for broader adoption outside Polygon zkEVM.





## The Micro-Processor Context



There are two micro-processor-type state machines; the Main SM and the Storage SM. This means these two SMs have the firmware part and the hardware part.

The firmware part runs the zkASM language to set up the logic and rules, which are expressed in JSON format and stored in a ROM. The JSON-file is then parsed to the specific SM Executor, which then executes Storage Actions in compliance with the rules and logic in the JSON-file.

The hardware part, which speaks the Polynomial Identity Language (PIL), defines constraints (or polynomial identities), expresses them in JSON format and stores them in the corresponding JSON-file. As in the firmware case, these constraints are also parsed to the specific SM Executor, because all computations must be executed in conformance to the polynomial identities.



![Figure 3 : Micro-Processor State Machine](figures/fig-micro-pro-pic.png)

<div align="center"><b> Figure 3 : Micro-Processor State Machine </b></div>



Although these two micro-processor SMs, the Main SM and the Storage SM, have the same look and feel, they differ considerably.

For instance, the Storage SM specialises with execution of Storage Actions (also called SMT Actions), whilst the Main SM is responsible for a wider range of Actions. Nevertheless, the Main SM delegates most of these Actions to specialist state machines. And, of course, the Storage SM remains secondary in that it also receives instructions from the Main SM, and not conversely.

It is worth noting that each of these micro-processor SMs has its own ROM. Specific details are covered in the respective documents for these state machines. The document for the Storage SM is found [here](https://docs.hermez.io/zkEVM/State-Machines/Storage/Storage-State-Machine-typ/).





## Hashing In The zkProver



There are two secondary state machines specialising with hashing; The Keccak State Machine and the $\text{POSEIDON}$ State Machine, where each is an 'automised' version of its standard cryptographic hash function.



### The Keccak State Machine

The deployment of the Keccak hash function is not surprising given the fact that it is deployed in Ethereum, and Polygon Hermez is a zk-rollup, an L2 scaling solution for Ethereum.

The Keccak state machine is a gates state machine, and thus has a set of logic gates (the hardware) and a set of connections between the gates (the logic). It is a secondary state machine composed of the Keccak SM Hash Generator and the Keccak PIL code, where the latter is for validation purposes.

A full description of the Keccak SM can be found in its individual document [here](https://docs.hermez.io/zkEVM/State-Machines/Hashing/Hashing-State-Machine-typ/#keccak-256).



### The $\text{POSEIDON}$ State Machine

The $\text{POSEIDON}$ hash function, although newer than the Keccak hash and thus still under the scritiny of cryptanalysts, it has been publicised as a [zk-STARK-friendly hash function](https://starkware.co/hash-challenge/). As such, it is best-suited for the zkProver context.

The $\text{POSEIDON}$ SM is the most straight forward especially if one is familiar with the internal mechanism of the original Poseidon hash function. 

The hash function's permutation process translates readily to the state transitions of the $\text{POSEIDON}$ State Machine. The hash function's twelve (12) input elements, the non-linear substitution layers (the S-boxes) and the linear diffusion layers (the MDS matrices), are directly implemented in the state machine.   

Although a secondary state machine, the $\text{POSEIDON}$ SM receives instructions from both the Main SM and the Storage SM.

The $\text{POSEIDON}$ SM has the executor part and an internal PIL code, which is a set of verification rules, written in the PIL language.

A full description of the $\text{POSEIDON}$ SM can be found in its individual document [here](https://docs.hermez.io/zkEVM/State-Machines/Hashing/Hashing-State-Machine-typ/#keccak-256).





## Basic Approach To Proving Execution-Correctness



What follows is an outline of the basic approach to proving that computations were correctly executed in each state machine.

The zkProver's state machines are designed to execute programs, as well as to guarantee that these programs are correctly executed.

Each secondary state machine therefore consists of its own executor and a PIL program that can be used to check correct execution of all the instructions coming from the Main SM Executor.

Here is a step-by-step outline of how the system achieves proof/verification of transactions,

- Represent a given computation as a state machine (SM),
- Express the state changes of the SM as polynomials,
- Capture traces of state changes, called execution traces, as rows of a lookup table, 
- Form polynomial identities/constraints that these state transitions satisfy, 
- 'Prover' uses a specific polynomial commitment scheme to commit and prove knowledge of the committed polynomials,
- [Plookup](https://eprint.iacr.org/2020/315.pdf) is one of the ways to check if the Prover's commited polynomials produce correct traces.

While the polynomial constraints are written in the PIL language, the instructions are initially written in zk-assembly but subsequently expressed and stored in JSON format.

The above outline of the proof/verification procedure was explained in this [blogpost](https://blog.hermez.io/zkevm-documentation/), and further detailed in the documentation [here](https://docs.hermez.io/zkEVM/Basic-Concepts/simple-state-machine/).

Although not all verification involves a Plookup, the diagram below, briefly illustrates the wide role Plookup plays in the zkProver.



![Figure 4: Plookup and the zkProver State Machines](figures/plook-ops-mainSM-copy.png)

<div align="center"><b> Figure 4: Plookup and the zkProver State Machines </b></div>





