

[ToC]







# Polynomial Identity Language (PIL)







## Introduction



*Polynomial Identity Language* (PIL) is a novel domain-specific language useful for defining state machines. The aim for creating PIL is to provide developers a holistic framework for both constructing state machines through an easy-to-use interface, and abstracting the complexity of the proving mechanisms. One of the main peculiarities of PIL is its *modularity*, which allows programmers to define parametrizable state machines, called *namespaces*, which can be instantiated from larger state machines. Building state machines in a modular manner makes it easier to test, review, audit and formally verify even large and complex state machines. In this regard, by using PIL, developers can create their own custom namespaces or instantiate namespaces from some public library.

Some of the keys features of PIL are;

- Providing $\texttt{namespaces}$ for naming the essential parts that constitutes state machines.
- Denoting whether the polynomials are $\texttt{committed}$ or $\texttt{constant}$.
- Expressing polynomial relations, including $\texttt{identities}$ and $\texttt{lookup arguments}$. 
- Specifying the type of a polynomial, such as $\texttt{bool}$ or $\texttt{u32}$.





## State Machines: The Computational Model Behind PIL



Many other domain-specific languages (DSL) or toolstacks, such as [Circom](https://docs.circom.io/) or [Halo2](https://zcash.github.io/halo2/), focus on the abstraction of a particular computational model, such as an arithmetic circuit.

Arithmetic circuits arise naturally in the context of succinct interactive protocols and are therefore an appropriate representation in the context of PIL.

Arithmetic circuits are covered by developer tools generally in two ways, either in the vanilla PlonK Style or the PlonKish Style. See Figure 1 for a high-level description of these two styles and how they differ.


![Vanilla Plonk vs PlonKish Circuit Representation Style](fig1-plnk-plnkish.png)
<div align="center"><b> Figure 1: Vanilla PlonK vs PlonKish Circuit Representation Style </b></div>



However, recent proof systems such as STARKs have shown that arithmetic circuits might not be the best computational models in all use-cases. Given a complete programming language, computing a valid proof for a circuit satisfiability problem, may result in long proving times due to the overhead of re-used logic. Opting for deployment of state machines, with their low-level programming, shorter proving times are attainable especially with the advent of proof/verification-aiding languages such as PIL.

Figure 2 below, provides a high-level description of a state machine architecture. A typical state machine takes some input and produces the corresponding output, according to the Arithmetic-Logic Unit (ALU). This ALU is the very core of the state machine as it determines the internal state of the state machine, as well as the values of its output.



![Architectural view of a State Machine](fig2-alu-3states.png)
<div align="center"><b> Figure 2: Architectural view of a State Machine </b></div>



Figure 3 and 4 show the comparison between the design of circuits and state machines in various natural scenarios. The former makes a comparison in the case of a program with a looping nature, and the latter shows a program with a branching nature.



![Circuit and state machine comparison in a loop-based computation](fig3-crct-sm.png)
<div align="center"><b> Figure 3: Circuit and state machine comparison in a loop-based computation </b></div>







![Circuit and State Machine comparison in a branch-based computation](fig4-arth-crct-sm.png)
<div align="center"><b> Figure 4: Circuit and State Machine comparison in a branch-based computation </b></div>





## Hello World Examples



In this section, an exploration of some state machine examples is presented.



### State Machine that Multiplies Two Numbers



Consider a state machine that takes two input numbers $x$ and $y$, and multiplies them. Hence call the state machine, the *Multiplier* state machine, described by the function;
$$
f(x,y) = x \cdot y.
$$


Table 5 below, shows the computational trace on various inputs.

As it can be observed, the input to this computation is fed into the two *free input* polynomials, $\texttt{freeIn}_1$ and $\texttt{freeIn}_2$, and the output of this computation is set to the *output* polynomial $\texttt{out}$, which contains the product of the free input polynomials.



![Computational Trace for the Multiplier State Machine](fig5-tbl-mltpl-sm.png)
<div align="center"><b> Table 5: Computational Trace for the Multiplier State Machine </b></div>



The nature of the previous polynomials suggests the following classification,

-  $\textbf{Free Input Polynomials}$. These are polynomials which are in charge of introducing the various inputs to the computation.They are referred to as "free" because at every clocking of the computation their values do not strictly depend on any previous iteration. These are analogous to independent variables of the entire computation.
- $\textbf{State Variables}$. These are the polynomials that compose the *state* of the state machine. Here state refers to the set of values that represent the output of the state machine at each step and, if we are in the last step, the output of the entire computation.



Figure 6 below provides a diagram of this division.



![Multiplier State Machine with the distinct polynomials](fig6-dstnct-pols-mltpl-sm.png)
<div align="center"><b> Figure 6: Multiplier State Machine with the distinct polynomials </b></div>



In order to achieve correct behaviour of this state machine, one obvious constraint that must be satisfied is,
$$
\texttt{out} = \texttt{freeIn}_1 \cdot \texttt{freeIn}_2.
$$
In PIL, all the components (polynomials and identities) of this state machine are introduced as shown in the code snippet below:



![Components of PIL](fig7-cd-exrpt-1.png)
<div align="center"><b> Code Excerpt 1: Components of PIL </b></div>



The problem with this design is that the number of committed polynomials grows linearly with the number of multiplications; so that, if we would have to compute a huge number of (possibly distinct) operations, the number of free input polynomials would be unnecessarily big.

Reduction of the number of free input polynomials can be achieved by introducing *constant* polynomials. These are preprocessed inputs to the state machine. That is, polynomials known prior to the execution of the computation and used as selectors, latches or sequencers, among other roles. Figure 7 below, is an updated version of Figure 6 above. The difference being an addition of constants.



![Multiplier State Machine with the Constant Polynomials](fig8-cnstnt-pols-mltpl-sm.png)
<div align="center"><b> Figure 6: Multiplier State Machine with the Constant Polynomials </b></div>





Table 8 shows the computational trace for the optimized Multiplier state machine.



![State Machine with the Constant Polynomials](fig8-tbl-stp-mltpl-sm.png)
<div align="center"><b> Table 6: State Machine with the Constant Polynomials </b></div>



Now, the two inputs to this computation are sequentially fed into the *only* free input polynomial $\texttt{freeIn}$. In the first step, the first input $x=4$ is moved from $\texttt{freeIn}$ to $\texttt{out}$. In the second step, $x$ is multiplied by the second input $y=2$, and the result is set to be in $\texttt{out}$.

In order to achieve the correctness of this new version, the previous constraint is changed so that the constant polynomial $\texttt{SET}$ helps in achieving the desired behavior:
$$
\texttt{out}' = \texttt{SET} \cdot \texttt{freeIn} + (1 - \texttt{SET}) \cdot (\texttt{out} \cdot \texttt{freeIn}).
$$
Notice how the $\texttt{SET}$ polynomial helps out with the branching. On the one hand, whenever $\texttt{SET}$ is set to $1$, then $\texttt{freeIn}$ is moved to the next value of $\texttt{out}$. While on the other hand, when $\texttt{SET}$ is set to $0$, then the stored value in $\texttt{out}$ is multiplied by the actual value of $\texttt{freeIn}$, which corresponds to the second input to the computation.

Note that as a convention, a tick $'$ (which is read "prime") is used to denote the "next" iteration. 

In the case of polynomials defined over the roots of unity, this notation translates to,
$$
f'(X) := f(\omega X).
$$


In PIL, the optimized Multiplier is implemented as follows,



![Optimised Multiplier State Machine](fig8cd-optmsd-mltpl-sm.png)
<div align="center"><b> Code Excerpt 2: Optimised Multiplier State Machine </b></div>





### A State Machine that Generates $4$-Byte Numbers



Consider now building a state machine that takes two $2$-byte numbers and generates a $4$-byte number from them. Since the logic of this state machine is similar to the previous one, the number of polynomials (and its meaning) is also the same. In the first step, the first input $x$ is moved from $\texttt{freeIn}$ to $\texttt{out}$. In a second step, $x$ is concatenated to the second input $y$ and set to be in $\texttt{out}$.

Table 9 shows the computational trace for a Byte4 state machine.



![Computational Trace for the Byte4 State Machine](fig9-cmpt-trc-byte-sm.png)
<div align="center"><b> Table 9: Computational Trace for the Byte4 State Machine </b></div>



For the purpose of displaying PIL's new features, the Byte4 state machine is built in a modular manner as illustrated next.

First, deploy the configuration file, called config.pil, which is typically used to include some configuration-related components, shared among various state machines. In the example below, this configuration file will include the definition of a constant $N$ representing the upper bound for the number of rows to be used across various state machines.

![PIL Configuration File for the Byte4 State Machine](fig10cd-pil-config-byte-sm.png)
<div align="center"><b> Code Excerpt 3: PIL Configuration File for the Byte4 State Machine </b></div>



Second, use the Global state machine. This state machine is used to store various polynomials representing "small" lookup tables, to be used by other state machines. For instance, defining the Lagrange polynomial $L_1$ or the polynomial representing the set of $1$-byte numbers. As we have set this state machine to have size $N$, there are some polynomials that need to be accommodated in size.



![PIL Global File for the Byte4 State Machine](fig11-pil-glbl-byte-sm.png)
<div align="center"><b> Code Excerpt 4: PIL Global File for the Byte4 State Machine </b></div>



Third, and finally, the Byte4 state machine is completed. Similar to the previous example, the constraint that needs to be satisfied is the following:
$$
\texttt{out}' = \texttt{SET} \cdot \texttt{freeIn} + (1 - \texttt{SET}) \cdot (2^{16} \cdot \texttt{out} + \texttt{freeIn}).
$$


Note how the product $2^{16} \cdot \texttt{out}$ forces the state machine to allocate the value from $\texttt{out}$ at the upper part of the result, while the addition of $\texttt{freeIn}$ allocates them at the lower part of the result.

This state machine is implemented in PIL as follows:

![The Byte4 State Machine PIL File](fig12-pil-code-byte-sm.png)
<div align="center"><b> Code Excerpt 5: The Byte4 State Machine PIL File </b></div>







## PIL Components



The aim with this section is to explain most of the PIL components in-depth.



### Namespaces

![PIL Namespace File](fig13-pil-nmspc-prmtrs.png)
<div align="center"><b> Code Excerpt 6: PIL Namespace File </b></div>



State machines in PIL are organized in *namespaces*. Namespaces are written with the keyword $\texttt{namespace}$ followed by the name of the state machine, and they can optionally include other parameters. In the previous snippet, a state machine called $\texttt{Name}$ is created. 

The namespace keyword opens a workspace for the developer to englobe all the polynomials and identities of a single state machine. Every component of a state machine is included within its namespace. There is a one-to-one correspondence between state machine and namespaces.

The same name cannot be used twice between state machines that are directly or indirectly related, since this would cause an overlap in the lookup arguments and the compiler would not be able to decide. 

So, for instance the following two examples are not allowed,



![PIL No Common Names](fig14-pil-nmspc-unique.png)
<div align="center"><b> Code Excerpt 7: PIL No Common Names </b></div>





### Polynomials



![PIL Constant and Committed Polynomials](fig15-pil-cnst-pols.png)
<div align="center"><b> Code Excerpt 8: PIL Constant and Committed Polynomials </b></div>



*Polynomials* are the key component of PIL. Values of polynomials have to be compared with computational trace's columns. In fact, in PIL, the two are considered to be the same thing. More precisely, polynomials are just the interpolation of the columns over all the rows of the computational trace.

Every polynomial is prefixed with the keyword $\texttt{pol}$ and needs to be explicitly set to be either a constant (also known as *preprocessed*) or committed. Polynomials fall into these two categories depending on the origin of their creation or how they are going to be used. Consequently, in PIL there exist two keywords to denote the two types of polynomials: $\texttt{constant}$ and $\texttt{commit}$.



#### Constant Polynomials



![A Constant in PIL](fig16-pil-a-cnst.png)
<div align="center"><b> Code Excerpt 9: A Constant in PIL </b></div>



*Constant polynomials*, also known in the literature as *preprocessed polynomials*, are polynomials known prior to the execution of the state machine. They correspond to polynomials that do not change during the execution, and are known to both the prover $\mathcal{P}$ and the verifier $\mathcal{V}$ prior to execution. They can be thought of as the preprocessed polynomials of an arithmetic circuit.

A typical use of these polynomials is in the inclusion of selectors, latches and sequencers. A constant polynomial is created or initialize as a polynomial with the keyword $\texttt{constant}$. And it is typically written in uppercase. This is good practice as it helps to differentiate them from the committed ones.



#### Committed Polynomials



![A Constant in PIL](fig16-pil-a-cnst.png)
<div align="center"><b> Code Excerpt 9: A Constant in PIL </b></div>



Committed polynomials are *not* known prior to the execution of the state machine. They are analogous to variables because their values change during execution, and are *only* known to the prover $\mathcal{P}$. In order to create a committed polynomial, simply prefix the polynomial in question with the keyword $\texttt{committed}$ (in the same way a variable-type is declared in standard programming languages).

These polynomials are typically divided between *input polynomials* and *state variables*. Although they are instantiated in the usual way, their purpose is completely different in the PIL context.



**Free Input Polynomials**

Free input polynomials are used to introduce data to the state machines. Each individual state machine applies its specific logic over the data introduced by these polynomials when executing computations. The data is considered the output of some state transition (or the output of the state machine, if it is the last transition). Also, free input polynomials are introduced by the prover, yet they are unknown to the verifier. They are therefore labelled, and prefixed, as $\texttt{committed}$.



**State Variables**

State variables are a set of values considered to be the state of the state machine. These polynomials play a pivotal role in the state machines, which is to help the prover focus on the correct evolution of the state variables during the generation of a proof. 

The output of the computation in each state transition is included in the state variables. The state of the state variables in the last transition is the $\textit{output}$ of the computation.

State variables depend on the input and the constant polynomials. They are also therefore labelled as committed.





### Polynomial Element Types



![Types of Polynomial Element](fig17-pol-elmt-types.png)
<div align="center"><b> Code Excerpt 10: Types of Polynomial Element </b></div>



A polynomial definition can also contain a keyword indicating the type of elements a polynomial is composed of. Types include, for instance, $\texttt{bool}$, $\texttt{u16}$, $\texttt{field}$.

The type is strictly informative. This means that to enforce the elements of some polynomial to be restricted over some smaller domain, one should include a constraint reflecting the bounds.





### Constraints



The set of *constraints* is one of the most important part of a PIL code. The constraints are defined to be the set of relations between polynomials that dictate the correct evolution of the state machine at every step. A state machine does what it does because the set of constraints enforces such a behavior.



![Polynomial Constraints](fig18-pol-constrnts-PIL.png)
<div align="center"><b> Code Excerpt 11: Polynomial Constraints </b></div>



Constraints can generally be of the following types (to be changed),

![The Main Polynomial Constraints](fig19-pol-constrnts-four.png)
<div align="center"><b> Code Excerpt 12: The Main Polynomial Constraints </b></div>







## The Cyclic Nature Of State Machines



There is one implicit complexity in the design of state machines:
$$
\textbf{State machines should have a cyclical nature.}
$$
This means the description (in terms of constraints) of a state machine is not correct if the appropriate constraints are not satisfied in every row transition. In particular, this should remain true in the transition from the last row to the first row. This is an important aspect that has to be taken care of when designing the set of constraints of a state machine.



![Cyclic Nature of State Machines](fig10-cycl-ntr-sms.png)
<div align="center"><b> Figure 10: Cyclic Nature of State Machines </b></div>



If there is some constraint that is not satisfied in the last transition, one normally overcomes this problem by adding artificial values in latter evaluations of some polynomials.

For example, consider the following state machine with its respective computational trace.



![State Machine Example](fig11-sm-eg-cmpt-trc.png)
<div align="center"><b> Code Excerpt 13: State Machine Example </b></div>



Clearly, the constraint $b' = b+a$ is not satisfied in the last transition: $(a,b) = (1,2)$ to $(a,b) = (1,1)$.

This can be solved by appending two extra rows. Figure 11 shows how this can be performed in the previous example.



![Inducing a Cyclic Nature](fig11-indc-cycl-ntr.png)
<div align="center"><b> Figure 11: Inducing a Cyclic Nature </b></div>



Another option would be the introduction of a selector:



![State Machine Example](fig12-sel-eg-cyclc-sm.png)
<div align="center"><b> Code Excerpt 14: State Machine Example </b></div>



As it can be seen in the above code excerpt, now the cost of adding extra rows has been substituted by the addition of the selector $\texttt{SEL}$.

A third option (when possible) is taking advantage of some existing selectors to accommodate latter values.







## Modularity





Although several polynomials could be added to the above state machine so as to express more operations, it would only make the design hard to test, audit or formally verify. 

In order to avoid this complication, PIL lets one use a divide and conquer technique:

(a)	Instead of developing one (big) state machine, a typical architecture consists of different state machines.

(b)	Each state machine is devoted to proving the execution of a specific task, each with its own set of constraints.

(c)	Then, relevant polynomials on different state machines are related and compared using lookup tables or permutation arguments.

(d)	This guarantees consistency as if it would have been a single state machine.

PIL is therefore best suited for a modular design of state machines.



Figure 12 depicts a connection between the polynomials $[a,b,c]$ and $[d,e,f]$.



![Polynomial Connections Across State Machines](fig12-pol-cnnct-sms.png)
<div align="center"><b> Figure 12: Polynomial Connections Across State Machines </b></div>



To illustrate this process,

1. First, design a state machine to manage arithmetic operations over $2$-byte elements.
2. Then, connect this state machine with another state machine (that needs to perform arithmetic operations) via a lookup argument.







### The Arithmetic State Machine



The *Arithmetic State Machine* is in charge of checking that some arithmetic operations like additions and multiplications are correctly performed over $2$-byte elements. For this, the polynomials; $\texttt{a}$, $\texttt{b}$, $\texttt{c}$, $\texttt{d}$, and $\texttt{e}$; must satisfy the identity:
$$
\texttt{a}(X) \cdot \texttt{b}(X) + \texttt{c}(X) = 2^{16} \cdot \texttt{d}(X) + \texttt{e}(X).
$$


Notice the following,

(a)	The multiplication between $\texttt{a}$ and $\texttt{b}$, which are $2$-byte elements, can be expressed with $\texttt{e}$ and $\texttt{d}$, where these are also $2$-byte elements.

(b)	Enforce that all the evaluations of $\texttt{a}$, $\texttt{b}$, $\texttt{c}$, $\texttt{d}$ and $\texttt{e}$ are $2$-byte elements.



![Architecture of the Arithmetic State Machine](fig13-arth-sm-arch.png)
<div align="center"><b> Figure 13: Architecture of the Arithmetic State Machine </b></div>



Figure 13 shows how the Arithmetic State Machine is designed. And, Tableb14 displays an example of how the computational trace looks like.



![Computational Trace of the Arithmetic State Machine](fig14-arth-sm-arch.png)
<div align="center"><b> Table 14: Computational Trace of the Arithmetic State Machine </b></div>



The Arithmetic state machine works as follows. $\texttt{LATCH}$ is used to flag when the operation is ready. Note that $\texttt{SET}[A]$, $\texttt{SET}[B]$, $\texttt{SET}[C]$, $\texttt{SET}[D]$, $\texttt{SET}[E]$ and $\texttt{LATCH}$ are constant polynomials. $\texttt{freeIn}$ is committed, and contains the values on which arithmetic operations are performed. Polynomials $\texttt{a}$, $\texttt{b}$, $\texttt{c}$, $\texttt{d}$ and $\texttt{e}$ compose the state variables.

The polynomial identities that define the Arithmetic State Machine are as follows:


$$
\begin{aligned}
&\texttt{freeIn} \subset [0,2^{16} - 1], \\
\texttt{a}' &= \texttt{SET}[A]\cdot(\texttt{freeIn} - \texttt{a}) + \texttt{a}, \\
\texttt{b}' &= \texttt{SET}[B]\cdot(\texttt{freeIn} - \texttt{b}) + \texttt{b}, \\
\texttt{c}' &= \texttt{SET}[C]\cdot(\texttt{freeIn} - \texttt{c}) + \texttt{c}, \\
\texttt{d}' &= \texttt{SET}[D]\cdot(\texttt{freeIn} - \texttt{d}) + \texttt{d}, \\
\texttt{e}' &= \texttt{SET}[E]\cdot(\texttt{freeIn} - \texttt{e}) + \texttt{e}, \\
0 &= [ \texttt{a} \cdot \texttt{b} + \texttt{c} - (2^{16} \cdot \texttt{d} + \texttt{e}) ] \cdot \texttt{LATCH}.
\end{aligned}
$$


These are included in PIL as shown in the code excerpt below.



![PIL Example](fig13-pil-eg-arth-sm.png)
<div align="center"><b> Code Excerpt 15: PIL Example </b></div>







### The Main State Machine



The *Main State Machine* is in charge of some (major) tasks, but will specifically use the Arithmetic SM when Arithmetic operations needs to be performed over certain values.



![The Main State Machine Architecture](fig15-main-sm-arch.png)
<div align="center"><b> Figure 15: The Main State Machine Architecture </b></div>



Hence, the first task in PIL is to introduce the various polynomials. It looks as follows,



![Arithmetic State Machine PIL Example](fig15-pil-eg-main-sm.png)
<div align="center"><b> Code Excerpt 15: Arithmetic State Machine PIL Example </b></div>


![xt, proceed with the]( That is, check whether all the input polynomials (whenever necessary) are of the )if some polynomial is intended to be boolean, then a constraint that reflects so must be added.



![PIL Example with Added Constraint](fig16-pil-eg-addd-cnstrnt.png)
<div align="center"><b> Code Excerpt 16: PIL Example with Added Constraint </b></div>



Now, add various constraints regarding the evolution of the "main" state variables $a$, $b$, $c$, $d$ and $e$, so that any kind of linear combination between the main state variables, the free input and any constant is subject to be moved in the next iteration of some (or all) the state variables. Figure 16 shows a diagram of the desired behavior.



![Boolean Polynommials in the Main State Machine](fig16-main-sm-bool-pols.png)
<div align="center"><b> Figure 16: Boolean Polynommials in the Main State Machine </b></div>



In PIL, it translates to the following:



![Verification of Basic Registry Operations](fig17-pil-vrfctn-reg-op.png)
<div align="center"><b> Code Excerpt 17: Verification of Basic Registry Operations </b></div>



Finally, the constraints reflecting the relationship between the Main and the Arithmetic SMs can be checked.



![PIL Example Connect Main and Arithmetic SMs](fig18-pil-eg-cnnct-main-arth.png)
<div align="center"><b> Code Excerpt 18: PIL Example Connect Main and Arithmetic SMs </b></div>



The connections can be depicted in terms of tables, as Figure 17 below,



![Connecting Arithmetic and Main State Machines](fig18-main-cnnct-Arth-Main.png)
<div align="center"><b> Figure 17: Connecting Arithmetic and Main State Machines </b></div>



On the one side, the $\texttt{arith}$ selector is used in the Main SM to point to this state machine when an arithmetic lookup have to be performed. On the other side, the $\texttt{LATCH}$ selector, which also works as a selector for which rows should be added in the lookup argument is used. And, as illustrated in Figure 17 above, this proves that,

\begin{array}{c}
\texttt{Main.arith} \cdot [\texttt{Main.a} , \texttt{Main.b} , \texttt{Main.c} , \texttt{Main.d}, \texttt{Main.e}] \\ \subset \\ \texttt{Arith.LATCH} \cdot [\texttt{Arith.a}, \texttt{Arith.b}, \texttt{Arith.c}, \texttt{Arith.d}, \texttt{Arith.e}].
\end{array}







## Advanced Features



This last section wraps the document by introducing some advanced features that PIL supports, such as permutation checks over multiple (possibly distinct) domains.



### Public Inputs



Public inputs are values of a polynomial that are known prior to the execution of a state machine. In the following example, the public input $\texttt{publicInput}$ is set to be the first element of the polynomial $\texttt{a}$ and a colon "$:$" is used to indicate this to the compiler (see line 12 in the code excerpt below).



![Public Inputs PIL Example](fig19-pil-eg-pub-inpts.png)
<div align="center"><b> Code Excerpt 19: Public Inputs PIL Example </b></div>



Note here, the use of the Lagrange polynomial $L_1$ to create a constraint,
$$
L_1 \cdot (\texttt{a} - :\texttt{publicInput}) = 0.
$$
Whenever relevant, the constraint enforces the value of $\texttt{a}$ to be equal to $\texttt{publicInput}$.





### Permutation Check



In this example we use the $\texttt{is}$ keyword to denote that the vectors $[\texttt{sm1.a},\texttt{sm1.b},\texttt{sm1.c}]$ and $[\texttt{sm2.a}, \texttt{sm2.b}, \texttt{sm2.c}]$ are a permutation of each other, seen as evaluations over the designated domain.



![Permutation Check PIL Example](fig20-pil-eg-prm-chck.png)
<div align="center"><b> Code Excerpt 20: Permutation Check PIL Example </b></div>



This constraint becomes useful to connect distinct state machines, since it is forcing that polynomials belonging to different state machines are the same (up to permutation).



### Two Special Functionalities 



Here are some vectors for which the $\texttt{in}$ and $\texttt{is}$ functionalities are designed for:

\begin{array}{ccc}
(3,2) & \text{in} & (1,2,3,4)\\
(1,5,5,5,8,1,1,2) & \text{in} & (1,2,4,5,8)\\
(3,2,3,1) & \text{is} & (1,2,3,3)\\
(5,5,6,9,0) & \text{is} & (6,5,9,0,5).
\end{array}




### The Connect Keyword



The $\texttt{connect}$ keyword is introduced to denote that the copy constraint argument is applied to $[\texttt{a},\texttt{b},\texttt{c}]$ using the permutation induced by $[\texttt{SA}, \texttt{SB}, \texttt{SC}]$.



![Connect Keywords PIL Example](fig21-pil-eg-cnnct-kwrds.png)
<div align="center"><b> Code Excerpt 21: Connect Keywords PIL Example </b></div>



Naturally, the previous feature can be used to describe the correctness of an entire PlonK circuit in PIL:



![Plonk Circuit in PIL](fig22-pil-eg-plnk-crct.png)
<div align="center"><b> Code Excerpt 22: Plonk Circuit in PIL </b></div>





### Permutation Check with Multiple Domain



Another important feature is the possibility to prove that polynomials of distinct state machines are the same (up to permutation) in a subset of its elements. This helps to improve efficiency when state machines are defined over subgroups of distinct size, since without this permutation argument one would need to equal the size of both polynomials.

PIL introduces this possibility by the introducing selectors that choose the subset of elements to be included in the permutation argument.



![Permutation Argument in PIL](fig23-pil-eg-prm-argmnt.png)
<div align="center"><b> Code Excerpt 23: Permutation Argument in PIL </b></div>



Any combination of $\texttt{sel}$,  $\texttt{not sel}$ and $\texttt{in}$, $\texttt{is}$ are available as permutation arguments. This leads to a total of $4$ possibilities.



Figure 18 depicts an example of the permutation multi-domain protocol, with one selector per table, that is, we prove that:
$$
\text{sel } \cdot [a,b,c] = \sigma\left(\text{sel' } \cdot [d,e,f]\right).
$$


![Permutation Multi-Domain Protocol](fig18-prm-mlt-dom-prtcl.png)
<div align="center"><b> Figure 18: Permutation Multi-Domain Protocol </b></div>

