## Goal

Polygon zkEVM is a zero-knowledge virtual machine (zkEVM), which is a layer 2 execution layer that can process a batch of EVM transactions and generate a zero knowledge proof for the correctness of the execution.

The core component of the zkEVM is the **zkProver** 

But before delving deep into the state machines, note that the zkProver is but a component in the Polygon Hermez zkEVM, and the only one responsible for proving.

In order to lay the context for the state machines, recall that the zkProver mainly interacts with two other components, the Node and the Database (DB).



<p align="center"><img src="fig1-zkprv-and-node.png" width="600" /></p>
<div align="center"><b> Figure 1: zkProver and the Node </b></div>



As depicted in Figure 1 above; 

Firstly, the Node sends the content of Merkle trees to the DB, to be stored there. 

Secondly, the Node sends the input transactions to the zkProver. 

Thirdly, the zkProver accesses the DB, fetching the information it needs to produce verifiable proofs of the transactions sent by the Node. This information consists of, among others, the Merkle roots, the keys and hashes of relevant siblings. 

Fourthly, the zkProver generates the proofs of transactions, and sends these proofs back to the Node. 


Our goal is to prove the correctness of the execution of a batch of transactions can be proved.

To illustrate the process of building a state machine like the EVM, whose execution correctness can be proved, 
we need to explain the process of arithmetization o 

 arithmetize the execution of EVM transactions so that


The previous program written in an assembly language that is
read by a program called "the executor".
The executior generates an execution trace according to each instruction of 
the assembly program.