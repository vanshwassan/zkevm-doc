# Modular Multiplication Opcode Implementation


## The EVM MULMOD Opcode

The **MULMOD** opcode performs a modular multiplication of two numbers, that is, it performs the following operation $R = A \cdot B \ \mathit{mod} \ N$. For example, if $A = 11, B = 2$ and $N = 6$, then the result is $R = 4 = 11 \cdot 2 \ \mathit{mod} \ 6$. 

This can also be expressed as 

$$
\begin{align}
&a \cdot b = k \cdot n + r \\
&\text{with } r < n
\end{align}
$$

The condition $r < n$ guarantees that, for a given $(a, b, n)$, the tuple $(k, r)$ is unique. In our example,

$$
(a, b, n) = (11, 2, 6) \to (3, 4) \Rightarrow 11 \cdot 2 = 3 \cdot 6 + 4. 
$$

In the case of the EVM, it must be taken into account it uses a $256$-bits arithmetic

$$
a, b, n, r \in \{ 0, 1, \dots, 2^{256} - 1 \}.
$$


## Reducing the Implementation to Arithmetic State Machine checks

In our zkEVM architecture, we have a state machine called **Arith** that can verify $256$-bit arithmetic operations. In particular, a combination with a sum and a multiplication. In more detail, providing the tuple $(x_1, y_1, x_2, y_2, y_3)$ **Arith** can verify that the tuple fulfills the following expression

$$
\begin{align}
&x_1 \cdot y_1 + x_2 = y_2 \cdot 2^{256} + y_3 \\
&\text{with } x_1, y_1, x_2, y_2, y_3 \in \{ 0, 1, \dots, 2^{256} - 1 \}
\end{align}
$$

Thus, to implement the **MULMOD** opcode using **Arith**, we have to express the modular multiplication as a set of equations with the previous form.


## Implementation Summary 

Packing all the conditions, if we provide a tuple $(a, b, n, d, e, k_h, k_l, d_1, r)$ that fulfills the following equations

- $a \cdot b + 0 = d \cdot 2^{256} + e$.
- $k_l \cdot n + r = d_1 \cdot 2^{256} + e$.
- $k_h \cdot n + d_1 = 0 \cdot 2^{256} + d$.
- $r < n$.
- $a, b, n, d, e, k_h, k_l, d_1, r \in \{0, 1, \dots, 2^{256} - 1 \}.$

Then $r = a \cdot b \ \mathit{mod} \ n$. 

The previous equations will be checked with the $256$-bit arithmetic state machine. Finally, we need to take into account the special cases where $n = 0$ and $n =1$. In this case, $r = 0$. Moreover, we will distinguish the special case in which $k_h = 0$. In this case, $d_1 = d$ and we can reduce the checks to provide the tuple $(a, b, n, d, e, k_l, r)$ that fulfills the following equations

- $a \cdot b + 0 = d \cdot 2^{256} + e$.
- $k_l \cdot n + r = d \cdot 2^{256} + e$.
- $r < n$.
- $a, b, n, d, e, k_l, r \in \{0, 1, \dots, 2^{256} - 1 \}.$


## Exceptions 

Several exceptions can occur meanwhile checking the modular multiplication opcode. Below, we list all possible exceptions:

- **Out of Gas Exception**: 

    If current $\mathtt{GAS} < 8$, then, there is a user error. We log this and revert all state changes. 

- **Out of Counters Exception**: 

    The maximum number of steps of the main we can take for the opcode is $150$:
        ```linenums="1"
        %MAX_CNT_STEPS - STEP - 150 :JMPN(outOfCounters)
        ```
    We can invoke a maximum of $2$ times the **Binary** (two $\texttt{:LT}$ instructions) and $3$ times the **Arith** (three $\texttt{:ARITH}$ instructions). Hence, we will add the following code at the beginning of the opcode
        ```linenums="1"
        %MAX_CNT_ARITH - CNT_ARITH - 3 :JMPN(outOfCounters)                 
        %MAX_CNT_BINARY - CNT_BINARY - 3 :JMPN(outOfCounters)
        ```
    Here $\texttt{%MAX_CNT_ARITH}, \texttt{%MAX_CNT_BINARY}$ and $\texttt{%MAX_CNT_STEPS}$ are constants that define the maximum steps can take each of these state machines. 
    
    If we go out of counters, then, there is an error in the processing of the batch (it is not an error of the user). We log this and restore the SR to the state root previous to the batch.

- **Stack Underflow Exception**:

    If current $\mathtt{SP} < 3$ (which means that there are not enough elements stored in the stack in order to be able to perform the opcode) then, there is a user error. We log this and revert all state changes. 

