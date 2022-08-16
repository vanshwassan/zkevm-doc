


For the sake of simplicity, one can think of the zkProver as being composed of the following four components; 

1. The Executor, which is the Main State Machine Executor
2. The STARK Recursion Component
3. The CIRCOM Library
4. The zk-SNARK Prover

In the nutshell, the zkProver uses these four components to generates verifiable proofs. Figure 5 below surmises the process. 





![ Figure 5: Simplified Data Flow in the zkProver](figures/fig-main-prts-zkpr.png)

<div align="center"><b> Figure 1: Simplified Data Flow in the zkProver </b></div>





## The Executor



The Executor is in fact the Main SM Executor. It takes as inputs; the transactions, the old and the new states, the ChainID of the Sequencer, to mention a few.

The executor also needs; 

1. The PIL, which is the list of polynomials, the list of the registers, and
2. The ROM, which stores the list of instructions pertaining to execution.

So, with these inputs, the Executor executes all instructions on top of the PIL hardware and generates the committed polynomials; which are the state machine cycles, or a list of all the states. It also generates some public data, which forms part of the input to the zk-SNARK verifier.

A full description of the Executor can be found in the Main State Machine's individual document.





## The STARK Recursion Component



Once the Main SM Executor has converted transactions and related data to committed polynomials, the STARK Recursion Component takes as inputs;

1. The Committed Polynomials,
2. The Constant Polynomials,
3. Scripts, which are lists of instructions,

in order to generate a zk-STARK proof.

In an effort to facilitate fast zk-STARK proving, the STARK Recursion Component utilises Fast Reed-Solomon Interactive Oracle Proofs of Proximity (RS-IOPP), also referred to as FRI, for each zk-proof.

The component is referred to as the STARK Recursion, because;

​	(a)	It actually produces several zk-STARK proofs,

​	(b)	Collates them into bundles of a few zk-STARK proofs,

​	(c)	And produces a further zk-STARK proof of each bundle,

​	(d)	The resulting zk-STARK proofs of the bundle are also collated and proved with only one zk-STARK proof.

This way, hundreds of zk-STARK proofs are represented and proved with only one zk-STARK proof.





## The CIRCOM Library



The single zk-STARK proof produced by the STARK Recursion Component is the input to a CIRCOM component.

CIRCOM is a [circuits library](https://github.com/socathie/circomlib-ml) used in the zkProver to generate the *witness* for the zk-STARK proof produced by the STARK Recursion Component.

The original CIRCOM [paper](https://www.techrxiv.org/articles/preprint/CIRCOM_A_Robust_and_Scalable_Language_for_Building_Complex_Zero-Knowledge_Circuits/19374986/1) describes it as both a circuits programming language to define Arithmetic circuits, and a compiler that generates, 

1. A file containing a set of associated Rank-1 Constraints System (R1CS) constraints, and 
2. A program (written either in C++ or WebAssembly) to efficiently compute a valid assignment to all wires of the Arithmetic circuit.

Arithmetic circuits are mostly used as standard models for studying the complexity of computations involving polynomials.

That being said, the CIRCOM component takes as inputs; the zk-STARK proof from the STARK Recursion Component and the Verifier Data; in order to produce a *witness*. This witness is in fact an Arithmetic circuit expressed in terms of its R1CS constraints.  





## The zk-SNARK Prover



The last component of the zkProver is the zk-SNARK Prover, in particular, Rapid SNARK. 

Rapid SNARK is a zk-SNARK proof generator, written in C++ and intel assembly, which is very fast in generating proofs of CIRCOM's outputs.

With regards to the zkProver, the Rapid SNARK takes as inputs 

1. The witness from CIRCOM, and 
2. The STARK verifier data, which dictates how the Rapid SNARK must process the data,
   and then generate a zk-SNARK proof.



### A Strategy To Achieving Succinctness

zk-STARK proofs are used because of their speed, and they require no trusted setup. They are however a lot more sizable compared to zk-SNARK proofs. It is for this reason, and the succinctness of the zk-SNARKs, that the zkProver uses a zk-SNARK to attest to the correctness of the zk-STARK proofs. zk-SNARKs are therefore published as the validity proofs to state changes. This strategy has huge benefits as it results in gas costs reducing from 5M to 350K.
