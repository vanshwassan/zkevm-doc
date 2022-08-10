# PIL: An Introduction
_Polynomial Identity Language (PIL)_ is a novel, domain-specific language useful for defining state machines. The aim of creating PIL is to provide developers with a holistic framework to both construct state machines through an easy-to-use interface and abstract the complexity of the proving mechanisms. One of the main peculiarities of PIL is its _modularity_, which allows programmers to define parametrizable state machines, called _namespaces_, which can be instantiated from the larger state machines. Building state machines in a modular manner makes it easier to test, review, audit and formally verify even large and complex state machines. In this regard, by using PIL, developers can create their own custom namespaces or instantiate namespaces from some public library.

Some of the keys features of PIL are:

- Provides $\texttt{namespaces}$ for naming the essential parts that constitute state machines.
- Denote whether the polynomials are $\texttt{committed}$ or $\texttt{constant}$.
- Express polynomial relations, including $\texttt{identities}$ and $\texttt{lookup arguments}$.
- Specify the type of a polynomial, such as $\texttt{bool}$ or $\texttt{u32}$.

## State Machines: The Computational Model Behind PIL

Many other domain-specific languages (DSL) or tool stacks, such as [Circom](https://docs.circom.io/) or [Halo2](https://zcash.github.io/halo2/), focus on the abstraction of a particular computational model, such as an arithmetic circuit.

Arithmetic circuits arise naturally in the context of the succinct interactive protocols and are, therefore, an appropriate representation in the context of PIL.

Arithmetic circuits are covered by developer tools generally in two ways: either in the vanilla PlonK Style or the PlonKish Style. See Figure 1 for a high-level description of these two types of styles and how they differ from each other.

![Vanilla Plonk vs PlonKish Circuit Representation Style](figures/fig1-plnk-plnkish.png)

<div align="center"><b> Figure 1: Vanilla PlonK vs PlonKish Circuit Representation Style </b></div>
<br>
However, recent proof systems such as STARKs have shown that arithmetic circuits might not be the best computational models in all use-cases. Given a complete programming language, computing a valid proof for a circuit satisfiability problem may result in long proving times due to the overhead of the re-used logic. Opting for the deployment of state machines, with their low-level programming, shorter proving times are attainable, especially with the advent of proof/verification-aiding languages such as PIL.

Figure 2 below, provides a high-level description of a state machine architecture. A typical state machine takes some input and produces the corresponding output according to the Arithmetic-Logic Unit (ALU). This ALU is the very core of the state machine as it determines the internal state of the state machine, as well as the values of its output.

![Architectural View of a State Machine](figures/fig2-alu-3states.png)

<div align="center"><b> Figure 2: Architectural View of a State Machine </b></div>
<br>
Figures 3 and 4 show the comparison between the design of the circuits and the state machines in different scenarios. The former makes a comparison in the case of a program with a looping nature, and the latter shows a program with a branching nature.

![Circuit and state machine comparison in a loop-based computation](figures/fig3-crct-sm.png)

<div align="center"><b> Figure 3: Circuit and State Machine Comparison in a Loop-based Computation </b></div>

![Circuit and State Machine Comparison in a Branch-based Computation](figures/fig4-arth-crct-sm.png)

<div align="center"><b> Figure 4: Circuit and State Machine Comparison in a Branch-based Computation </b></div>
