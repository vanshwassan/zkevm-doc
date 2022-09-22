# Modular Multiplication Opcode Implementation


## The EVM MULMOD Opcode

The **MULMOD** opcode performs a modular multiplication of two numbers, that is, it performs the folowing operation $R = A \cdot B \ \mathit{mod} \ N$. For example, if $A = 11, B = 2$ and $N = 6$, then the result is $R = 4 = 11 \cdot 2 \ \mathit{mod} \ 6$. 

This can also be expressed as 

$$
\begin{align}
&A \cdot B = K \cdot N + R \\
&\text{with } R < N
\end{align}
$$

The condition $R < N$ guarantees that, for a given $(A, B, N)$, the tuple $(K, R)$ is unique. 

In the case of the EVM, it must be taken into account it uses a $256$-bits arithmetic

$$
A, B, N, R \in \{ 0, 1, \dots, 2^{256} - 1 \}.
$$


## Reducing the Implementation to Arithmetic State Machine checks

In our zkEVM architecture, we have a state machine called **Arith** that can verify $256$-bit arithmetic operations. In particular, a combination with a sum and a multiplication. In more detail, providing the tuple $(A, B, C, D, E)$ **Arith** can verify that the tuple fulfills the following expression

$$
\begin{align}
&A \cdot B + C = D \cdot 2^{256} + E \\
&\text{with } A, B, C, D, E \in \{ 0, 1, \dots, 2^{256} - 1 \}
\end{align}
$$

Thus, to implement the **MULMOD** opcode using **Arith**, we have to express the modular multiplication as a set of equations with the previous form.


## Implementation Summary 

It can be deduced that if we provide a tuple $(A, B, N, D, E, K_h, K_l, D_1, R)$ that fulfills the following equations

- $A \cdot B + 0 = D \cdot 2^{256} + E$.
- $K_l \cdot N + R = D_1 \cdot 2^{256} + E$.
- $K_h \cdot N + D_1 = 0 \cdot 2^{256} + D$.
- $R < N$.
- $A, B, N, D, E, K_h, K_l, D_1, R \in \{0, 1, \dots, 2^{256} - 1 \}.$

Then $R = A \cdot B \ \mathit{mod} \ N$. 

Observe that the previous constraints can be checked with the Arithmetic State Machine and the Binary State Machine. We need to take into account the special cases where $N = 0$ and $N =1$. In this case, $R = 0$. 


## Exceptions 

Several exceptions can occur meanwhile checking the modular multiplication opcode. Below, we list all possible exceptions:

- **Out of Gas Exception**: 

    If current $\mathtt{GAS} < 8$, then, there is a user error. We log this and revert all state changes. 

- **Out of Counters Exception**: 

    The maximum number of steps of the main we can take for the opcode is $150$:
        ```linenums="1"
        %MAX_CNT_STEPS - STEP - 150 :JMPN(outOfCounters)
        ```
    Moreover, we can invoke a maximum of $3$ times the Binary and $3$ times the Binary (three $\texttt{:ARITH}$ instructions). Hence, we add the following code at the beginning of the opcode
        ```linenums="1"
        %MAX_CNT_ARITH - CNT_ARITH - 3 :JMPN(outOfCounters)                 
        %MAX_CNT_BINARY - CNT_BINARY - 3 :JMPN(outOfCounters)
        ```
    Here $\texttt{%MAX_CNT_ARITH}, \texttt{%MAX_CNT_BINARY}$ and $\texttt{%MAX_CNT_STEPS}$ are constants that define the maximum steps can take each of these state machines. 
    
    If we go out of counters, then, there is an error in the processing of the batch (it is not an error of the user). We log this and restore the SR to the state root previous to the batch.

- **Stack Underflow Exception**:

    If current $\mathtt{SP} < 3$ (which means that there are not enough elements stored in the stack in order to be able to perform the opcode) then, there is a user error. We log this and revert all state changes. 

