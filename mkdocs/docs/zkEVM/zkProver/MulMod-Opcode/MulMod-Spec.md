# Modular Multiplication Opcode Specification

The **MULMOD** opcode performs a modular multiplication of two numbers. In the EVM, it uses $256$-bit operands: $a, b, n, r \in \{ 0, 1, \dots, 2^{256} - 1 \}.$


## Assumptions

The polygon zkEVM architecture has different state machines to prove specific parts of the computation. The verification of the MULMOD Opcode assumes the existence of three state machines: Arith, Binary and Memory.

- **Arith** can verify that a tuple $(x_1, y_1, x_2, y_2, y_3)$ with  $x_1, y_1, x_2, y_2, y_3 \in \{ 0, 1, \dots, 2^{256} - 1 \}$ fulfills the following expression:

$$
\begin{align}
&x_1 \cdot y_1 + x_2 = y_2 \cdot 2^{256} + y_3 \\
\end{align}
$$

- **Binary** can verify binary additions, binary subtractions, binary comparators (less than for signed and unsigned integers and equality checks) and bitwise operations (AND, OR and XOR).

- **Memory** can verify the correctness of the sequence of memory operations (reads and writes). The memory operates with addresses of 32 bits and words of 32 Bytes and it is used to build a stack as well as for allocatable memory.


## Input, Outputs and Exceptions

The inputs are three values $a, b$ and $n$ at the top of the stack.

The output is a value $r = a \cdot b \ \mathit{mod} \ n$ at the top of the stack while $a, b$ and $n$ have been removed from the stack. 

As output we can also have three exceptions:

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
        %MAX_CNT_BINARY - CNT_BINARY - 2 :JMPN(outOfCounters)
        ```
    Here $\texttt{%MAX_CNT_ARITH}, \texttt{%MAX_CNT_BINARY}$ and $\texttt{%MAX_CNT_STEPS}$ are constants that define the maximum steps can take each of these state machines. 
    
    If we go out of counters, then, there is an error in the processing of the batch (it is not an error of the user). We log this and restore the SR to the state root previous to the batch.

- **Stack Underflow Exception**:

    If current $\mathtt{SP} < 3$ (which means that there are not enough elements stored in the stack in order to be able to perform the opcode) then, there is a user error. We log this and revert all state changes. 

| Inputs | Expected Output |
| ------ | --------------- |
| **Stack**: $\mathtt{SP} > 2$, top of the stack with $a, b, n$. <br> $\mathtt{GAS} > 8$ <br> $\mathtt{MAX\_CNT\_STEPS} - \mathtt{STEP} - 150 > 0$ <br> $\mathtt{MAX\_CNT\_ARITH} - \mathtt{CNT\_ARITH} - 3 > 0$ <br> $\mathtt{MAX\_CNT\_BINARY} - \mathtt{CNT\_BINARY} - 2 > 0$ | **Stack**: pop $a, b, n$ and push $r$  <br>  $\mathtt{GAS}^* = \mathtt{GAS}-8$ <br> $\mathtt{MAX\_CNT\_STEPS} - \mathtt{STEP}^* > 0$ <br>  $\mathtt{CNT\_ARITH} - \mathtt{CNT\_ARITH}^* < 4$ <br>  $\mathtt{CNT\_BINARY} - \mathtt{CNT\_BINARY}^* < 3$ <br>  |
| **Stack**: $\mathtt{SP} < 3$ | Stack Underflow Exception |
| **Stack**: $\mathtt{GAS} < 8$ | Out of Gas Exception |
| $\mathtt{MAX\_CNT\_STEPS} - \mathtt{STEP} - 150 < 1$ | Out of Counters Exception |
| $\mathtt{MAX\_CNT\_ARITH} - \mathtt{CNT\_ARITH}  < 3$ | Out of Counters Exception |
| $\mathtt{MAX\_CNT\_BINARY} - \mathtt{CNT\_BINARY} < 2$ | Out of Counters Exception |

'*' means values after the execution.

## Annex: Implementation Details

If we provide a tuple $(a, b, n, d, e, k_h, k_l, d_1, r)$ that fulfills the following equations:

1. $a \cdot b + 0 = d \cdot 2^{256} + e$.
1. $k_l \cdot n + r = d_1 \cdot 2^{256} + e$.
1. $k_h \cdot n + d_1 = 0 \cdot 2^{256} + d$.
1. $r < n$.
   
Where $a, b, n, d, e, k_h, k_l, d_1, r \in \{0, 1, \dots, 2^{256} - 1 \}.$

Then $r = a \cdot b \ \mathit{mod} \ n$. 

We need to take into account the special cases where $n = 0$ and $n =1$. In this case, $r = 0$. Moreover, we will distinguish the special case in which $k_h = 0$. In this case, $d_1 = d$ and we can reduce the checks to provide the tuple $(a, b, n, d, e, k_l, r)$ that fulfills the following equations:

1. $a \cdot b + 0 = d \cdot 2^{256} + e$.
2. $k_l \cdot n + r = d \cdot 2^{256} + e$.
3. $r < n$.

Where $a, b, n, d, e, k_l, r \in \{0, 1, \dots, 2^{256} - 1 \}.$
