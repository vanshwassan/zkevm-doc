# Modular Multiplication Opcode Implementation


## The EVM MULMOD Opcode

The **MULMOD** opcode performs a modular multiplication of two numbers, that is, it performs the folowing operation $r = a \cdot b \ \mathit{mod} \ n$. For example, if $a = 11, b = 2$ and $n = 6$, then the result is $r = 4 = 11 \cdot 2 \ \mathit{mod} \ 6$. 

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

We want to check that the tuple $(a, b, k, n, r)$ fulfills the following equation:

$$
\begin{align}
&a \cdot b = k \cdot n + r \\
&\text{with } a, b, n, r \in \{ 0, 1, \dots, 2^{256} - 1 \}
\end{align}
$$

But notice that $k$ in the previous equation can be less than, equal to or bigger than $2^{256}$. In any case, $k < 2^{512}$ because $a, b < 2^{256}$. To do the check, we split $k$ in its unique limbs of $256$ bits:

$$
\begin{align}
&a \cdot b = (k_h \cdot 2^{256} + k_l) \cdot n + r \\
&a \cdot b = (k_h \cdot n) \cdot 2^{256} + (k_l \cdot n + r) \\
& \text{where } (k_h \cdot n) < 2^{256}.
\end{align}
$$

Regarding $k_l \cdot n + r$, it can be less than, equal to or bigger than $2^{256}$. So, we express $k_l \cdot n + r$ with its unique $256$-bit limbs:

$$
k_l \cdot n + r = d_1 \cdot 2^{256} + e.
$$

Replacing in our previous equation

$$
\begin{align}
&a \cdot b = (k_h \cdot n + d_1) \cdot 2^{256} + e \\
&\text{where } k_h \cdot n + d_1, e < 2^{256}.
\end{align}
$$

On the other hand

$$
\begin{align}
& a \cdot b = d \cdot 2^{256} + e \\
& \text{where } d, e < 2^{256},
\end{align}
$$

so we have

$$
\begin{align}
& a \cdot b = (k_h \cdot n + d_1) \cdot 2^{256} + e \\
& \text{where } k_h \cdot n + d_1, e < 2^{256}.
\end{align}
$$

Therefore, we get the equality $d = k_h \cdot n + d_1$.


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

## Memory State Machine Summary

In first place, the Polygon zkEVM architecture incorporates a memory SM that can check memory operations (reads and writes). The memory operates with addresses of 32 bits and words of 32 Bytes:
  
  - This provides a maximum total size of $2^{32} \cdot 32$ Bytes $=128$ Gigabytes. 
  - However, we can have different memory contexts during a transaction execution. 
  - We limit the memory per context to $\mathtt{0x200000}$ which corresponds to $64$ Megabytes (which is a memory expansion of $8.5$M gas).
  
The assembly for using the memory SM provides two instructions, one for read from memory and another to write to memory: 

- $\texttt{MLOAD(address)}$.
- $\texttt{MSTORE(address)}$.

In the assembly, we can also use memory labels for the address. For example:

```
A               :MSTORE(arithA)
```

stores the value of registry $\texttt{A}$ at the address pointed by the memory label $\texttt{arithA}$. The concrete addresses for memory labels are defined in a configuration file. 

Since the EVM is a stack-based virtual machine, we 
reserve an address space to create a stack within the memory of the zkEVM. The classical pointer called $\texttt{STACK POINTER} (\texttt{SP})$ contains the address 
of the **next free position of the** $\texttt{STACK}$. A $\texttt{POP}$ from the $\texttt{STACK}$ can be implemented as:

```
SP - 1 => SP
$ => A          :MLOAD(SP)
```

where we decrement $\texttt{SP}$ to position on the last element of the stack and then we load this element into registry $\texttt{A}$.

A $\texttt{PUSH}$ into the $\texttt{STACK}$ can be implemented as:
```
0               :MSTORE(SP++)
```

which saves a $\texttt{0}$ at the top of the stack and increments $\texttt{SP}$.

**Note**: The stack pointer and the memory are per context. 

## Binary State Machine Summary

The Polygon zkEVM architecture incorporates also a binary SM that can 
check binary operations. More specifically, the binary state machine implements $\textbf{additions}, \textbf{subtractions}$, comparators ($\textbf{less than for signed and unsigned integers}$ and $\textbf{equality checks}$) and bitwise operations ($\textbf{AND}, \textbf{OR}$ and $\textbf{XOR}$).

The binary uses a $\mathtt{carry}$ column for the carries of additions and subtractions, and for returning the binary results of comparisons. 

Example:
```
; C=1 if A < B, else C=0
$   => C     :LT
```

The previous instruction stores a $\texttt{1}$ in registry $\texttt{C}$ if the value in registry $\texttt{A}$ is less than the value in registry $\texttt{B}$ or stores a $\texttt{0}$ in registry $\texttt{C}$ otherwise.
  
## Jumps in the Main

The main SM has three assembly instructions for jumps: $\texttt{JMP, JMPC}$ and $\texttt{JMPN}$.

```
; Unconditionally jumps to label myLabel
       :JMP(myLabel)

; Jumps to label myLabel if A < B
$       :LT, JMPC(myLabel)

; Jumps to label myLabel if A is negative
A       :JMPN(myLabel)
```

- $\texttt{JMP}$ jumps unconditionally to a label in the program.
- $\texttt{JMPC}$ jumps to a label in the program if $\mathtt{carry} \neq 1$. In the example, carry is $1$ if the registry $\mathtt{A}$ is **Less Than (LT)** registry $\mathtt{B}$. 
- $\texttt{JMPN}$ jumps to a label in the program if $\mathtt{op0}$ is a negative value. In the example, the value of registry $\mathtt{A}$. Negative values go from $-1$ to $-2^{32}$. 


## Basic Usage of the Arithmetic State Machine

We use the $\textbf{Arith}$ SM with the $\texttt{:ARITH}$ instruction. The $\textbf{Arith}$ uses the $\mathtt{x_1, y_1, x_2, y_2}$ and $\mathtt{y_3}$ 256-bit registries to check the following expression:

$x_1 \cdot y_1 + x_2 = y_2 \cdot 2^{256} + y_3$

In the **Main** SM, we use registry $\mathtt{A}$ as $\mathtt{x_1}$, $\mathtt{B}$ as $\mathtt{y_1}$, $\mathtt{C}$ as $\mathtt{x_2}$, $\mathtt{D}$ as $\mathtt{y_2}$ and $\mathtt{op}$ as $\mathtt{y_3}$ to verify the arithmetic operation. 

```linenums="1"
$${var _valArith = A * B + C}
${_valArith >> 256} => D
${_valArith} => E :ARITH
```

In the example, at line 1, we instruct the executor into computing 
the big number $\mathtt{A} \cdot \mathtt{B}+\mathtt{C}$ and store this value in an executor variable arbitrarily called $\texttt{_valArith}$. 

At line 2, the executor computes the $\mathtt{y_2}$ value by shifting 256 bits $\texttt{_valArith}$ and stores the result in the $\texttt{D}$ registry.

Finally, at line $3$, the executor computes $\mathtt{op}$ (value of $\mathtt{y_3}$) as free input, stores $\mathtt{op}$ in registry $\mathtt{E}$ and also the **Arith** SM verifies the arithmetic expression. 

Another way of using the $\textbf{Arith}$ SM is to use an assembly 

  - Subroutines are invoked with $\texttt{CALL(label)}$.
  - When a $\texttt{CALL}$ is performed, the execution jumps into 
  the specified label in the program.
  - When the label's associated code finishes, the program execution continues at the line after the initial $\texttt{CALL}$ invocation.


```linenums="1"
; calling the Arith
   A         :MSTORE(arithA)
   B         :MSTORE(arithB)
             :CALL(mulARITH)

; continues here after the assembly subroutine
   A         :MLOAD(arithOverflow) 
   B         :MLOAD(arithRes1)
```

In particular, the $\texttt{mulARITH}$ subroutine computes pure 
multiplications using the $\textbf{Arith}$ SM: $A \cdot B+0 = D \cdot 2^{256}+E$. The $\texttt{mulARITH}$ subroutine uses memory to read the operands and leave the results. In this regard, observe that before jumping into $\texttt{mulARITH}$, we provide the operands to the $\textbf{Arith}$ SM under the memory labels $\texttt{arithA}$ and $\texttt{arithB}$. When the invocation of $\texttt{mulArith}$ finishes, the values $D$ and $E$ are stored in memory under the memory labels $\texttt{arithOverflow}$ and $\texttt{arithRes1}$, respectively. 

```linenums="1"
; zkevm-rom:main/utils.zkasm

mulARITH: ; assembly subroutine for multiplication
    RR              :MSTORE(tmpZkPC)
    zkPC+1 => RR    :JMP(storeTmp)
    $ => A          :MLOAD(arithA)
    $ => B          :MLOAD(arithB)
    0 => C
    $${var _mulArith = A * B}
    ${_mulArith >> 256} => D
    ${_mulArith} => E :ARITH
    E               :MSTORE(arithRes1)
    D               :MSTORE(arithOverflow)
    zkPC+1 => RR    :JMP(loadTmp)
    $ => RR         :MLOAD(tmpZkPC)
                    :JMP(RR)
```

The $\texttt{RR}$ registry contains the code return address. The value of $\texttt{RR}$ is set when invoking the subroutine. In the subroutine, at line 4, we store the current value of the $\texttt{RR}$ registry at the memory label $\texttt{tmpZkPC}$. This is because in line 6 we will jump to another subroutine. In line 5, we set the value of $\texttt{RR}$ to the next line for correctly coming from the $\texttt{tmpZkPC}$ subroutine.

```linenums="1"
storeTmp:
    A                   :MSTORE(tmpVarA)
    B                   :MSTORE(tmpVarB)
    C                   :MSTORE(tmpVarC)
    D                   :MSTORE(tmpVarD)
    E                   :MSTORE(tmpVarE)
                        :JMP(RR)

loadTmp:
    $ => A                  :MLOAD(tmpVarA)
    $ => B                  :MLOAD(tmpVarB)
    $ => C                  :MLOAD(tmpVarC)
    $ => D                  :MLOAD(tmpVarD)
    $ => E                  :MLOAD(tmpVarE)
                            :JMP(RR)
```

The $\texttt{storeTmp}$ subroutine stores the values of the registries $\texttt{A, B, C, D}$ and $\texttt{E}$ in temporary memory labels and then jumps back to the return address at $\texttt{RR}$. The $\texttt{loadTmp}$ subroutine does the opposite.


```linenums="1"
; zkevm-rom:main/utils.zkasm

mulARITH: ; assembly subroutine for multiplication
    RR              :MSTORE(tmpZkPC)
    zkPC+1 => RR    :JMP(storeTmp)
    $ => A          :MLOAD(arithA)
    $ => B          :MLOAD(arithB)
    0 => C
    $${var _mulArith = A * B}
    ${_mulArith >> 256} => D
    ${_mulArith} => E :ARITH
    E               :MSTORE(arithRes1)
    D               :MSTORE(arithOverflow)
    zkPC+1 => RR    :JMP(loadTmp)
    $ => RR         :MLOAD(tmpZkPC)
                    :JMP(RR)
```

In lines 6 and 7, the multiplicands are loaded from the associated memory labels. 

This subroutine is for pure multiplications, so in line 8, the $\texttt{C}$ registry is set to 0. Then, the executor is instructed to compute the proper $\mathtt{y_2}$ and $\mathtt{y_3}$ values.

For computing these values, at line 9, the executor is instructed 
to compute the big number $A \cdot B$ and to store the result in an 
executor variable called $\texttt{_mulArith}$. Notice that we can specify pure executor functions inline using the syntax $\texttt{\$\$\{...\}}$. These pure executor functions do not directly contribute to the
execution trace.


```linenums="1"
; zkevm-rom:main/utils.zkasm

mulARITH: ; assembly subroutine for multiplication
    RR              :MSTORE(tmpZkPC)
    zkPC+1 => RR    :JMP(storeTmp)
    $ => A          :MLOAD(arithA)
    $ => B          :MLOAD(arithB)
    0 => C
    $${var _mulArith = A * B}
    ${_mulArith >> 256} => D
    ${_mulArith} => E :ARITH
    E               :MSTORE(arithRes1)
    D               :MSTORE(arithOverflow)
    zkPC+1 => RR    :JMP(loadTmp)
    $ => RR         :MLOAD(tmpZkPC)
                    :JMP(RR)
```

- At line 10, $D$ is computed by taking the bits 256 to 511 of $\texttt{_mulArith}$ and stored at the $\texttt{D}$ registry.

- A line 11, $E$ is computed by taking the bits 0 to 255 of $\texttt{_mulArith}$. At this line, the $E$ value is at $\texttt{op}$, $\texttt{:ARITH}$ checks the operation and the $E$ value is stored at the $\texttt{E}$ registry. 

- At lines 12 and 13 the result of the operation is stored in memory:
$E$ in $\texttt{arithRes1}$ and $D$ in $\texttt{arithOverflow}$.

- Finally, in line 14 we restore the previous values of registries, in line 15 we read the return code address and finally jump to this address in line 16.




## MULMOD Opcode Assembly 

We are under the situation where the top of the stack looks like
$\mathtt{STACK} = [a, b, n, ... ]$.

The assembly code for the MULMOD opcode can be found at :

```linenums="1"
  ; Stack and gas checks
  SP - 3         :JMPN(stackUnderflow)
  SP - 1 => SP
  GAS-8 => GAS   :JMPN(outOfGas)

  ; Load multiplicands
  $ => A         :MLOAD(SP--)    ; (A<=a,B,C,D,E)
  $ => B         :MLOAD(SP--)    ; (A=a,B<=b,C,D,E)
  A              :MSTORE(arithA) ; [arithA<=a]
  B              :MSTORE(arithB) ; [arithA=a,arithB<=b]
  ${var _mulab = A * B}          ; FIX with $$

  ; Check (e): if(n is 0 or 1) {r=0}
  $ => A         :MLOAD(SP)      ; (A<=n,B=b,C,D,E)
  2 => B                         ; (A=n,B<=2,C,D,E)
  $              :LT, JMPC(zeroOneMod)

  ; Check (a): a*b = d*2^256 + e
        :CALL(mulARITH) ; [arithA=a, arithB=b, arithOverflow<=d, arithRes1<=e]

  $${var _k = _mulab/A}
  ; Check kh == 0
  ${_k >> 256} => B ; (A=n,B<=kh,C,D,E) kh=k_b256-511
  ${cond(B == 0)} :JMPN(mulModNoKH)

    ; Check (b): kl*n+r = d1*2^256+e
  ${_k % (2 << 256)} => B                   ; (A=n,B<=kl,C,D,E)      op=kl=k_b0-255
  ${_mulab % A} => C                        ; (A=n,B=kl,C<=r,D,E)    op=r=A*B%n
  ${(B * A + C) >> 256} => D                ; (A=n,B=kl,C=r,D<=d1,E) op=d1=(B*A+C)_b256-511
  $              :MLOAD(arithRes1), ARITH   ; (A=n,B=kl,C=r,D=d1,E)  op=[arithRes1]=e

  ; Check (d): assert r<n
  A => B              ; (A=n,B<=n,C=r,D=d1,E)
  C => A              ; (A<=r,B=n,C=r,D=d1,E)
  $ => A         :LT
  1              :ASSERT

  ; Check (c): kh*n+d1 = 0*2**256+d
  ${_k >> 256} => A                           ; (A<=kh,B=n,C=r,D=d1,E)  op=kh=k_b256-511
  D => C                                      ; (A=kh,B=n,C<=d1,D=d1,E)
  0 => D                                      ; (A=kh,B=n,C=d1,D<=0,E)
  $             :MLOAD(arithOverflow), ARITH  ; (A=kh,B=n,C=d1,D=0,E)   op=[arithOverflow]=d 

  ; PUSH r
  C              :MSTORE(SP++)
                 :JMP(readCode)

  mulModNoKH:
  ; Check (b): kl*n+r = d1*2^256+e where d1=d
  ${_k} => B                               ; (A=n,B<=kl,C,D,E)     op=kl=k since kh=0
  ${_mulAB % A} => C                       ; (A=n,B=kl,C<=r,D,E)   op=r=a*b%n
  $ => D         :MLOAD(arithOverflow)     ; (A=n,B=kl,C=r,D<=d,E) op=[arithOverflow]=d
  $              :MLOAD(arithRes1), ARITH  ; (A=n,B=kl,C=r,D=d,E)  op=[arithRes1]=e

  ; Check (d): assert r<n
  A => B              ; (A=n,B<=n,C=r,D=d,E)
  C => A              ; (A<=r,B=n,C=r,D=d,E)
  $ => A          :LT
  1               :ASSERT

  ; PUSH r
  C               :MSTORE(SP++)
                  :JMP(readCode)

  zeroOneMod:
    0             :MSTORE(SP++)
                  :JMP(readCode)
```

Next, we describe the previous assembly code step by step.

First of all, we will comment the error handling machinery. When we have errors, we call a function at the executor to log the error and then, we jump to the $\texttt{handleError}$ code label.

```linenums="1"
; Stack and gas checks
SP - 3         :JMPN(stackUnderflow)
SP - 1 => SP
GAS-8 => GAS   :JMPN(outOfGas)

stackOverflow:
    ${eventLog(onError, overflow)}
                    :JMP(handleError)
outOfGas:
    ${eventLog(onError, OOG)}
                    :JMP(handleError)

handleError:
    ; revert all state changes
    $ => SR         :MLOAD(initSR)
```

- Line 2 checks that we have 3 elements at the top of the stack to
do the MULMOD operation.
- Line 3 positions the $\texttt{SP}$ at the address of the top element.
- Line 4 checks that there is enough gas remaining for doing the operation.

When there's this type of error ($\texttt{outOfGas}$, $\texttt{stackOverFlow}$) the behavior is very similar to process an invalid OPcode: 

  - All the gas is consumed of the current Context (current call).
  - We return to the last context pushing a 0 to the stack.
  - Also we recover the $\texttt{initSR}$ of the current context, meaning that all the changes will be reverted (in storage, nonce, bytecode, etc.) except for the gas consumption. 
  - Also the $\texttt{gasRefund}$ will not be modified.


The first step of the MULMOD implementation is to POP the $A$ and $B$ 
values and load them into the proper memory labels:

```linenums="1"
; Load multiplicands
$ => A         :MLOAD(SP--)    ; (A<=a,B,C,D,E)
$ => B         :MLOAD(SP--)    ; (A=a,B<=b,C,D,E)
A              :MSTORE(arithA) ; [arithA<=a]
B              :MSTORE(arithB) ; [arithA=a,arithB<=b]
${var _mulab = A * B}          ; FIX with $$
```

- Line 2 loads multiplicand $a$ and stores it in the registry $\texttt{A}$.
- This is denoted in comments as $\texttt{(Registry=Value, ...)}$. 
- Line 3 does the same for multiplicand $b$.
- Line 4 stores the value in registry $\texttt{A}$ into memory at label $\texttt{arithA}$.
- This is denoted in comments as $\texttt{[mem_label=Value, ...]}$.
- Line 5 stores the value in registry $\texttt{B}$ into memory at label $\texttt{arithB}$.
- Finally, at line 6, we instruct the executor to compute the big number $A \cdot B$ 
and store the result in the executor variable called $\texttt{_mulab}$.

$\textbf{Note.}$ Ideally $\texttt{\$\$}$ should be used at line 6 because it is a pure executor function but currently, $\texttt{\$}$ has to be used which uses a row of the execution trace (this might be fixed in the future).


Next, we check expression $\textbf{(e)}$,
$N \in \{0,1\}$?

```linenums="1"
  ; Check (e): if(n is 0 or 1) {r=0}
  $ => A         :MLOAD(SP)      ; (A<=n,B=b,C,D,E)
  2 => B                         ; (A=n,B<=2,C,D,E)
  $              :LT, JMPC(zeroOneMod)

zeroOneMod:
    0               :MSTORE(SP++)
                    :JMP(readCode)
```

The $\texttt{LT}$ is an operation verified by the $\textbf{Binary}$ 
state machine. **LT** must be 1 if the value of the $\texttt{A}$ registry is lower than the value of the $\texttt{B}$ registry and, 0 otherwise.

The result of LT is introduced as a free input in the execution trace of 
the $\textbf{Main}$ SM and verified by the $\textbf{Binary}$ SM. $\texttt{JMPC}$ jumps if the binary operation is $1$. In this code, if $A<B$ the executor introduces $\mathtt{carry} = 1$ as the free input and, $\texttt{JMPC}$ jumps to $\texttt{zeroOneMod}$. At $\texttt{zeroOneMod}$, we store a 0 at the top of the stack as the result of the $\texttt{MULMOD}$ operation and, finally, we jump to read the next opcode.


```linenums="1"
  ; Check (a): a*b = d*2^256 + e
        :CALL(mulARITH) ; [arithA=a, arithB=b, arithOverflow<=d, arithRes1<=e]
```

If $n$ is not a special case, we do not jump but we compute $\textbf{(a)}$, the decomposition of $a \cdot b$:

$$a \cdot b + 0 = d \cdot 2^{256} + e$$

Recall that the values $a$ and $b$ are stored at memory, at the memory labels $\texttt{arithA}$ and $\texttt{arithB}$. The decomposition values $d$ and $e$, are also stored at memory after calling the subroutine, in particular, at the memory labels $\texttt{arithOverflow}$ ($d$) and $\texttt{arithRes1}$ ($e$), respectively. 

Next, we compute $k_h$ and store it in the register $\mathtt{B}$:

```linenums="1"
  $${var _k = _mulab/A}
  ; Check kh == 0
  ${_k >> 256} => B ; (A=n,B<=kh,C,D,E) kh=k_b256-511
  ${cond(B == 0)} :JMPN(mulModNoKH)
```

Observe that we treat the case where $k_h = 0$ separately because 
this case needs one check less. If $k_h = 0$ we jump into the code label $\texttt{mulModNoKH}$. Notice that we jump using a condition checked by the executor: $\texttt{cond(B==0)}$ and introduced as a free input. This is a correct way of implementing the verification because the $\textbf{Arith}$ SM will check all the expressions that enforce that $r$ is the correct result of the $\texttt{MULMOD}$ operation.

```linenums="1"
mulModNoKH:
  ; Check (b): kl*n+r = d1*2^256+e where d1=d
  ${_k} => B                               ; (A=n,B<=kl,C,D,E)     op=kl=k since kh=0
  ${_mulAB % A} => C                       ; (A=n,B=kl,C<=r,D,E)   op=r=a*b%n
  $ => D         :MLOAD(arithOverflow)     ; (A=n,B=kl,C=r,D<=d,E) op=[arithOverflow]=d
  $              :MLOAD(arithRes1), ARITH  ; (A=n,B=kl,C=r,D=d,E)  op=[arithRes1]=e

  ; Check (d): assert r<n
  A => B              ; (A=n,B<=n,C=r,D=d,E)
  C => A              ; (A<=r,B=n,C=r,D=d,E)
  $ => A          :LT
  1               :ASSERT

  ; PUSH r
  C               :MSTORE(SP++)
                  :JMP(readCode)
```

Recall that we already checked (a).

When $k_h$ is 0, we just need to check (b) and (d):

$$
\begin{align}
\textbf{(a)}  &a \cdot b + 0 = d \cdot 2^{256} + e \ \text{ (CHECKED) }\\
\textbf{(b)}  &k_l \cdot n+r = d \cdot 2^{256}+e \\
\textbf{(d)}  &r < n
\end{align}
$$

- Line 4 loads $R$ in $\texttt{C}$.
- Line 5 loads the previously computed $d$. 
- Line 6 loads the previously computed $e$ into $\texttt{op}$ and triggers the Arith check using the $\texttt{:ARITH}$ instruction.
- Lines 9, 10, 11 and 12 check $\textbf{(d)}$. 

If $r$ is not less than $n$, we abort the execution using the $\texttt{ASSERT}$ instruction. The $\texttt{ASSERT}$ instruction makes sure that the value at the register $\texttt{A}$ is the same as the value $\texttt{op}$. If this is not fulfilled, the proof cannot be generated. 

**Note:** The only way that an assert fails is because the executor has tried to manipulate the free input and they do not fulfill the assert condition. 

If everything is OK, we push the result to the top of the stack and tread the next opcode (lines 15 and 16).

Let us now proceed with the case where $k_h \neq 0$.

```linenums="1"
  ; Check (b): kl*n+r = d1*2^256+e
  ${_k % (2 << 256)} => B                   ; (A=n,B<=kl,C,D,E)      op=kl=k_b0-255
  ${_mulab % A} => C                        ; (A=n,B=kl,C<=r,D,E)    op=r=A*B%n
  ${(B * A + C) >> 256} => D                ; (A=n,B=kl,C=r,D<=d1,E) op=d1=(B*A+C)_b256-511
  $              :MLOAD(arithRes1), ARITH   ; (A=n,B=kl,C=r,D=d1,E)  op=[arithRes1]=e

  ; Check (d): assert r<n
  A => B              ; (A=n,B<=n,C=r,D=d1,E)
  C => A              ; (A<=r,B=n,C=r,D=d1,E)
  $ => A         :LT
  1              :ASSERT

  ; Check (c): kh*n+d1 = 0*2**256+d
  ${_k >> 256} => A                           ; (A<=kh,B=n,C=r,D=d1,E)  op=kh=k_b256-511
  D => C                                      ; (A=kh,B=n,C<=d1,D=d1,E)
  0 => D                                      ; (A=kh,B=n,C=d1,D<=0,E)
  $             :MLOAD(arithOverflow), ARITH  ; (A=kh,B=n,C=d1,D=0,E)   op=[arithOverflow]=d

  ; PUSH r
  C              :MSTORE(SP++)
                 :JMP(readCode)

In this case, all the expressions (b), (c) and (d) have to be verified:

$$
\begin{align}
\textbf{(a)}  &a \cdot b + 0 = d \cdot 2^{256} + e\ \text{ (CHECKED) } \\
\textbf{(b)}  &k_l \cdot n+r = d_1 \cdot 2^{256}+e \\
\textbf{(c)}  &k_h \cdot n+d_1 = 0 \cdot 2^{256}+d \\
\textbf{(d)}  &r < n
\end{align}
$$

- Lines 13 to 21 do the same as for the case $k_h = 0$.
- Lines 1 to 5 check expression (b).
- Lines 7 to 11 check expression (c).

Notice how previously computed values in memory are used with free inputs.

- Line 2 instructs the executor to compute $k_l$ and 
introduces this value as a free input that is copied to the $\texttt{B}$ registry. $k_l$ is computed as the 256 least significant bits of the big number $a \cdot b/n$.

- Line 3 instructs the executor to compute $n$ and introduce this value as a free input that is copied to the $\texttt{C}$ registry.
- Line 4 does something similar for the $d_1$ value, which is copied to the $\texttt{D}$ registry.
- Line 7 starts the verification of (c) because recall that $k_h \neq 0$. 

For the check, we use $d$ previously stored at the memory label $\texttt{arithOverflow}$. The value $k_h$ is computed as the bits from $256$ to $511$ of $k$. Finally, observe that $k_h$ is introduced as a free input and copied to $\mathtt{B}$. 


$\textbf{Counters}$ are a way to control that the total number of steps do not exceed the maximum polynomial size.

Here, it is state that the maximum number of steps of the main we can take for the opcode is $150$:

```linenums="1"
%MAX_CNT_STEPS - STEP - 150 :JMPN(outOfCounters)
```
  
We can invoke a maximum of $2$ times the **Binary** (two $\texttt{:LT}$ instructions) and $3$ times the **Arith** (three $\texttt{:ARITH}$ instructions). Hence, we will add the following code at the beginning of the opcode

```linenums="1"
%MAX_CNT_ARITH - CNT_ARITH - 3 :JMPN(outOfCounters)
%MAX_CNT_BINARY - CNT_BINARY - 2 :JMPN(outOfCounters)
```

Here $\texttt{%MAX_CNT_ARITH}$ and $\texttt{%MAX_CNT_BINARY}$ are constants that define the maximum steps can take each of these state machines. If we go out of counters, then, there is an error in the processing of the batch (it is not an error of the user). We log this and restore the SR to the state root previous to the batch:

```linenums="1"
outOfCounters:
    ${eventLog(onError, OOC)}
                    :JMP(handleBatchError)

handleBatchError:
    $ => SR         :MLOAD(batchSR)
    ${eventLog(onFinishTx)}
    ${eventLog(onFinishBatch)}
                    :JMP(processTxsEnd)
```


## Running Integrations Tests

We are going perform integration tests with the prover for a contract
that uses the \texttt{MULMOD} Opcode.

First, download the needed repositories:

```
$ git clone git@github.com:0xPolygonHermez/zkevm-rom.git
$ git clone git@github.com:0xPolygonHermez/zkevm-proverjs.git
$ git clone git@github.com:0xPolygonHermez/zkevm-testvectors.git
```

Then, in each repository, install the dependencies with $\texttt{npm install}$. Next, we are going to create a smart contract that uses the desired Opcode(s), 
in this case, the $\texttt{MULMOD}$ Opcode.

In the $\texttt{zkevm-testvectors}$ repository, go to $\texttt{tools-calldata/evm/contracts}$. There, create a new contract with whatever you want to test. In this case, we create a new file called $\texttt{OpMulMod}$ with the following content:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract OpMuldMod {
  function Mulmod( uint256 a, uint256 b, uint256 n ) public view returns (uint256 result) {
    assembly {
      result := mulmod(a, b, n)
    }
  }
}
```


In the $\texttt{zkevm-testvectors}$ repository, go to the directory $\texttt{tools-calldata/evm/generate-test-vectors}$.

The easiest way to proceed is just copy one of the files and use it as template:

  - Copy one of the files to a new file called $\texttt{gen-test-mulmod.json}$.


Then, just edit the $\texttt{"txs"}$ and $\texttt{"contracts"}$ properties of the JSON file.

  - Any time you want to do a modification, e.g. changing the inputs, you just need to 
  modify these two properties (the rest is updated automatically).

```js
[
  { "contracts": [{"contractName": "OpMuldMod", "paramsDeploy": {} }]},
    "txs": [{
        "from": "0x4d5Cf5032B2a844602278b01199ED191A86c93ff",
        "to": "contract",
        "nonce": "0",
        "value": "0",
        "contractName": "OpMuldMod",
        "function": "MulMod",
        "params": [ 256, 100000, 256 ],
        "gasLimit": 100000,
        "gasPrice": "1000000000",
        "chainId": 1000
      }],
  }
]
```

Then, execute the following command for generating the inputs for the executor:

```
zkevm-testvectors/tools-calldata/evm$ ./gen-input.sh gen-test-mulmod.json
```

**Note:** the $\texttt{gen-input.sh}$ script will search for the file in $\texttt{tools-calldata/evm/generate-test-vectors/}$.

The previous command creates two files:

- $\texttt{zkevm-testvectors/state-transition/calldata/test-mulmod.json}$
  
  - This file contains data necessary for creating the inputs for the executor.
  - You don't have to do anything with this file.
  - It is useful only if you want to do executor debugging.
  
- $\texttt{zkevm-testvectors/inputs-executor/calldata/test-mulmod_0.json}$
  
  - This is the actual executor input.
  - The 0 in the name of the file is because we only add one test case in our example.
  - If we add several tests then, multiple inputs (with more sequential numbers) would be created.



Now we can create the execution trace with the input. To do so, go to the $\texttt{zkevm-proverjs}$ repository and in project root, execute the following command:

```js
$ node --max-old-space-size=4096 src/main_executor.js /path/to/test-mulmod_0.json -r /path/to/zkevm-rom/build/rom.json -d -s
```

When the command finishes, you can take a look at the traces at:

$\texttt{zkevm-proverjs/src/sm/sm_main/logs-full-trace/test-mulmod_0__full_trace_0.json}$

Search at this file for $\texttt{"opcode": "MULMOD"}$. Remark that the test will check that the trace fulfills the associated PIL.