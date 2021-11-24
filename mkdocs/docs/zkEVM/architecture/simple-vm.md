Simple Virtual Machine
======================

Main State Machine of a Simplified Virtual Machine

![image](\zkevmdir/architecture/figures/main-state-machine-simplified-overview){width="65%"}

Example Program: Moving & Jumping

-   Let's assume we have the following program: $$\begin{array}{|c|l|c|}
    \hline
    \mathbf{Position} & \multicolumn{2}{|c|}{\mathbf{Instruction}} \\ \hline
    0 & \mathbf{MOV} & A, 7 \\ \hline
    1 & \mathbf{JMP}~(if~A = 0) & 5 \\ \hline
    2 & \mathbf{MOV} & B, 3 \\ \hline
    3 & \mathbf{MOV} & A, 0 \\ \hline
    4 & \mathbf{JMP} & 1 \\ \hline
    5 & \mathbf{STOP} & \emptyset \\ \hline
    \end{array}$$

-   This program has the following trace:
    $$\begin{array}{|c|l|c|c|c|c|c|c|c|}
    \hline
    \mathbf{Position} & \multicolumn{2}{|c|}{\mathbf{Instruction}} & \mathbf{PC_i} & \mathbf{A_i} & \mathbf{B_i} & \mathbf{PC_{i+1}} & \mathbf{A_{i+1}} & \mathbf{B_{i+1}} \\ \hline
    0 & \mathbf{MOV} & A, 7 & 0 & 0 & 0 & 1 & 7 & 0 \\ \hline
    1 & \mathbf{JMP}~(if~A = 0) & 5 & 1 & 7 & 0 & 2 & 7 & 0 \\ \hline
    2 & \mathbf{MOV} & B, 3 & 2 & 7 & 0 & 3 & 7 & 3 \\ \hline
    3 & \mathbf{MOV} & A, 0 & 3 & 7 & 3 & 4 & 0 & 3 \\ \hline
    4 & \mathbf{JMP} & 1 & 4 & 0 & 3 & 1 & 0 & 3 \\ \hline
    5 & \mathbf{JMP}~(if~A = 0) & 5 & 1 & 0 & 3 & 5 & 0 & 3 \\ \hline
    6 & \mathbf{STOP} & \emptyset & 5 & 0 & 3 & 5 & 0 & 3 \\ \hline
    \end{array}$$

Expressing the Relations between the States

![image](\zkevmdir/architecture/figures/main-state-machine-2registres){width="80%"}

-   Here, we use the following notation:

    a)  $\mathbf{inX_i}$: $1$ or $0$ depending if the state $X_i$ is
        included in the sum or not.

    b)  $\mathbf{op_i}$: The resulting operation between the included
        states.

    c)  $\mathbf{setX_i}$: $1$ or $0$ depending if $\op_i$ will be moved
        into $X_{i+1}$.

-   The relations between the states of the registries can be expressed
    as follows: $$\begin{aligned}
    \op_i &= A_i \cdot \inp A_i + B_i \cdot \inp B_i + FREE_i \cdot \inp FREE_i, \\
    A_{i+1} &= \set A_i \cdot (\op_i - A_i) %+ freeload_i \cdot (value - A_i) 
    + A_i, \\
    B_{i+1} &= \set B_i \cdot (\op_i - B_i) %+ freeload_i \cdot (value - B_i) 
    + B_i, \\
    PC_{i+1} &= PC_i + 1 + (isJMP_i + isJMPC_i \cdot isSatisfied_i) \cdot (dest - PC_i - 1).\end{aligned}$$

-   Here:

    1.  $FREE$ is the second input passed to the **MOV** instruction.

    2.  $dest$ is the input passed to the **JMP** or the **JMPC**
        (conditioned) instructions.

How to Encode the Move State Machine

-   Let's now explain how to encode the instructions included in the
    program: $$\begin{aligned}
    \mathbf{MOV}~A, 7 \quad \mathbf{JMP}~(if~A = 0)~5 \quad \mathbf{MOV}~B,3 \quad \mathbf{MOV}~A,0 \quad \mathbf{JMP}~1 \quad \mathbf{STOP}\end{aligned}$$

$$\scriptsize
\begin{array}{|c|c|}
\hline
\multicolumn{2}{|c|}{\mathbf{Instruction}} \\ \hline
\mathbf{MOV} & A, 7 \\ \hline
\mathbf{JMP}~(if~A = 0) & 5 \\ \hline
\mathbf{MOV} & B,3 \\ \hline
\mathbf{JMP} & 1 \\ \hline
\mathbf{STOP} & \emptyset \\ \hline
\end{array}
\hspace{0.1cm}
\begin{array}{|c|c|c|c|c|c|c|c|}
\hline
\textbf{inA} & \textbf{inB} & \textbf{inFREE} & \textbf{setA} & \textbf{setB} & \textbf{isJMP} & \textbf{isJMPC} \\ \hline
1 & 0 & 1 & 1 & 0 & 0 & 0 \\ \hline
0 & 0 & 0 & 0 & 0 & 0 & 1 \\ \hline
0 & 1 & 1 & 1 & 0 & 0 & 0 \\ \hline
0 & 0 & 0 & 0 & 0 & 0 & 1  \\ \hline
0 & 0 & 0 & 0 & 0 & 0 & 0 \\ \hline
\end{array}
\hspace{0.1cm}
\begin{array}{|c|c|}
\hline
\mathbf{FREE} & \mathbf{dest} \\ \hline
7 & 0 \\ \hline
0 & 5 \\ \hline
3 & 0 \\ \hline
0 & 1 \\ \hline
0 & 0 \\ \hline
\end{array}
\hspace{0.1cm}
\begin{array}{|c|}
\hline
\mathbf{Inst.~Value} \\ \hline
0000.0111.0001101 \\ \hline
0101.0000.1000000 \\ \hline
0000.0011.0001110 \\ \hline
0001.0000.1000000 \\ \hline
0000.0000.0000000 \\ \hline
\end{array}$$

-   Here, we computed the instruction values as follows:
    $$\begin{aligned}
    \mathsf{inst}_i = &~\inp A_i + 2 \cdot \inp B_i + 2^2 \cdot \inp FREE_i + 2^3 \cdot \set A_i + 2^4 \cdot \set B_i + 2^5 \cdot isJMP_i + 2^6 \cdot isJMPC_i \\ 
    & + 2^{10} \cdot FREE_i + 2^{14} \cdot dest_i.\end{aligned}$$

-   We can write the previous table values as the following polynomial
    identity: $$\begin{aligned}
    \mathsf{inst}(x) = &~\inp A(x) + 2 \cdot \inp B(x) + 2^2 \cdot \inp FREE(x) + 2^3 \cdot \set A(x) + 2^4 \cdot \set B(x) + 2^5 \cdot isJMP(x) \\
    & + 2^6 \cdot isJMPC(x) + 2^{10} \cdot FREE(x) + 2^{14} \cdot dest(x).\end{aligned}$$

-   Now, to build the program, every instruction will be uniquely
    identified by its value and the position of the program in which it
    is executed.

-   We define the polynomial $\mathsf{rom}(x)$ which consists on an
    instruction value concatenated with its position:
    $$\mathsf{rom}(x) = \mathsf{inst}(x) + 2^{18} \cdot position(x)$$

Representing the State Machine

-   With the support of this encoding, now we can compute the whole
    trace of the execution of this program: $$\begin{array}{|c|l|c|c|}
    \hline
    \mathbf{Position} & \multicolumn{2}{|c|}{\mathbf{Instruction}} \\ \hline
    0 & \mathbf{MOV} & A, 7 \\ \hline
    1 & \mathbf{JMP}~(if~A = 0) & 5 \\ \hline
    2 & \mathbf{MOV} & B, 3 \\ \hline
    3 & \mathbf{MOV} & A, 0 \\ \hline
    4 & \mathbf{JMP} & 1 \\ \hline
    5 & \mathbf{STOP} & \emptyset \\ \hline
    \end{array}
    \hspace{0.1cm}
    \begin{array}{|c|c|}
    \hline
    \mathbf{Rom} = inst(x) + 2^{19} \cdot position(x) \\ \hline
    0000.0000.0111.0001101 \\ \hline
    0001.0101.0000.1000000 \\ \hline
    0010.0000.0011.0001110 \\ \hline
    0011.0000.0000.0001101 \\ \hline
    0100.0001.0000.1000000 \\ \hline
    0101.0000.0000.0000000 \\ \hline
    \end{array}$$

-   We can do the same with the trace of the program:
    $$\begin{array}{|c|l|c|c|c|c|}
    \hline
    \mathbf{Position} & \multicolumn{2}{|c|}{\mathbf{Instruction}} & \mathbf{PC_i} & \mathbf{A_i} & \mathbf{B_i} \\ \hline
    0 & \mathbf{MOV} & A, 7 & 0 & 0 & 0 \\ \hline
    1 & \mathbf{JMP}~(if~A = 0) & 5 & 1 & 7 & 0 \\ \hline
    2 & \mathbf{MOV} & B, 3 & 2 & 7 & 0 \\ \hline
    3 & \mathbf{MOV} & A, 0 & 3 & 7 & 3 \\ \hline
    4 & \mathbf{JMP} & 1 & 4 & 0 & 3 \\ \hline
    5 & \mathbf{JMP}~(if~A = 0) & 5 & 1 & 0 & 3 \\ \hline
    6 & \mathbf{STOP} & \emptyset & 5 & 0 & 3 \\ \hline
    \end{array}
    \hspace{0.1cm}
    \begin{array}{|c|c|}
    \hline
    \mathbf{instTrace} = inst(x) + 2^{19} \cdot PC(x) \\ \hline
    0000.0000.0111.0001101 \\ \hline
    0001.0101.0000.1000000 \\ \hline
    0010.0000.0011.0001110 \\ \hline
    0011.0000.0000.0001101 \\ \hline
    0100.0001.0000.1000000 \\ \hline
    0001.0101.0000.1000000 \\ \hline
    0000.0000.0000.0000000 \\ \hline
    \end{array}$$

Checking the Correct Program Execution

-   The question that arises now is:

    **How do we actually verify that we are executing the correct
    program?**

-   The solution seems obvious: Check that every row of the trace of the
    execution coincides with some row of the program.

-   Then, the question becomes to:

    **How do we actually verify that we are executing the correct
    program\
    in an efficient manner?**

-   We can do it with the Plookup protocol!

-   So, to check that the correct program is being executed, we simply
    have to use Plookup to determine if:
    $$\mathbf{instTrace} \subset \mathbf{Rom}$$

-   In simple words, the trace being executed is an execution of the
    actual program if the instruction trace is contained in the ROM of
    the program.

Strategy to Follow

-   The strategy to follow to check the correct execution of a program
    is:

    1.  Encode each distinct instruction of the program in a
        deterministic and efficient manner.

    2.  Represent each instruction in the program in a unique manner by
        appending the position in the program to it. We obtain the
        polynomial $rom(x)$.

    3.  Similarly, represent each instruction in the trace of the
        program by appending the program counter to it.We obtain the
        polynomial $instTrace(x)$.

    4.  Use Plookup to prove that the trace of the program is contained
        in the rom of the program, i.e., prove that
        $instTrace \subset rom$.
