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

The condition $R < N$ guarantees that, for a given $(A, B, N)$, the tuple $(K, N)$ is unique. In our example,

$$
(A, B, N) = (11, 2, 6) \to (3, 4) = (K, N) \Rightarrow 11 \cdot 2 = 3 \cdot 6 + 4. 
$$

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

Thus, to implement the **MULMOD** opcode using **Arith**, we have to express the modular multiplication as a set of equations with the previous form. But notice that $K$ in the previous equation can be less than, equal to or bigger than $2^{256}$. In any case, $K < 2^{512}$ because $A, B < 2^{256}$. To do the check, we split $K$ in its unique limbs of $256$ bits:

$$
\begin{align}
&A \cdot B = (K_h \cdot 2^{256} + K_l) \cdot N + R \\
&A \cdot B = (K_h \cdot N) \cdot 2^{256} + (K_l \cdot N + R) \\
& \text{where } (K_h \cdot N) < 2^{256}.
\end{align}
$$

Regarding $K_l \cdot N + R$, it can be less than, equal to or bigger than $2^{256}$. So, we express $K_l \cdot N + R$ with its unique $256$-bit limbs:

$$
K_l \cdot N + R = D_1 \cdot 2^{256} + E.
$$

Replacing in our previous equation

$$
\begin{align}
&A \cdot B = (K_h \cdot N + D_1) \cdot 2^{256} + E \\
&\text{where } K_h \cdot N + D_1, E < 2^{256}.
\end{align}
$$

On the other hand

$$
\begin{align}
& A \cdot B = D \cdot 2^{256} + E \\
& \text{where } D, E < 2^{256},
\end{align}
$$

so we have

$$
\begin{align}
& A \cdot B = (K_h \cdot N + D_1) \cdot 2^{256} + E \\
& \text{where } K_h \cdot N + D_1, E < 2^{256}.
\end{align}
$$

Therefore, we get the equality $D = K_h \cdot N + D_1$.


## Implementation Summary 

Packing all the conditions, if we provide a tuple $(A, B, N, D, E, K_h, K_l, D_1, R)$ that fulfills the following equations

- $A \cdot B + 0 = D \cdot 2^{256} + E$.
- $K_l \cdot N + R = D_1 \cdot 2^{256} + E$.
- $K_h \cdot N + D_1 = 0 \cdot 2^{256} + D$.
- $R < N$.
- $A, B, N, D, E, K_h, K_l, D_1, R \in \{0, 1, \dots, 2^{256} - 1 \}.$

Then $R = A \cdot B \ \mathit{mod} \ N$. 

The previous equations will be checked with the $256$-bit arithmetic state machine. Finally, we need to take into account the special cases where $N = 0$ and $N =1$. In this case, $R = 0$. Moreover, we will distinguish the special case in which $K_h = 0$. In this case, $D_1 = D$ and we can reduce the checks to provide the tuple $(A, B, N, D, E, K_l, R)$ that fulfills the following equations

- $A \cdot B + 0 = D \cdot 2^{256} + E$.
- $K_l \cdot N + R = D \cdot 2^{256} + E$.
- $R < N$.
- $A, B, N, D, E, K_l, R \in \{0, 1, \dots, 2^{256} - 1 \}.$


## Memory State Machine Summary

In first place, the Polygon zkEVM architecture incorporates a memory SM that can check memory operations (reads and writes). The memory operates with addresses of 32 bits and words of 32 Bytes (which provides a maximum theoretical size of $2^{32}*32$ Bytes $=128$ Gigabytes). The assembly for using the memory SM provides two instructions, one for read from memory and another to write to memory: 

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

## Binary State Machine Summary

The Polygon zkEVM architecture incorporates also a binary SM that can 
check binary operations. More specifically, the binary state machine implements $\textbf{additions}, \textbf{subtractions}$, comparators ($\textbf{less than for signed and unsigned integers}$ and $\textbf{equality checks}$) and bitwise operations ($\textbf{AND}, \textbf{OR}$ and $\textbf{XOR}$).

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
- $\texttt{JMPC}$ jumps to a label in the program if the preceding binary operation is true (in the example, a Less Than).
- $\texttt{JMPN}$ jumps to a label in the program if the $\texttt{op}$ registry is negative (in the example, the value of $\texttt{A}$ registry).


## Basic Usage of the Arithmetic State Machine

We use the $\textbf{Arith}$ SM with the \texttt{:ARITH} instruction. The $\textbf{Arith}$ uses the $\texttt{A, B, C, D}$ and $\texttt{E}$ 256-bit registries to check the following expression:

$A \cdot B + C = D \cdot 2^{256} + E$

```linenums="1"
$${var _valArith = A * B + C}
${_valArith >> 256} => D
${_valArith} => E :ARITH
```

In the example, at line 1, we instruct the executor into computing 
the big number $A \cdot B+C$ and store this value in an executor variable arbitrarily called $\texttt{_valArith}$. 

At line 2, the executor computes the $D$ value by shifting 256 bits $\texttt{_valArith}$ and stores the result in the $\texttt{D}$ registry.

Finally, at line 3, the executor stores the value $E$ in 
the $\texttt{E}$ registry (observe that the modulo operation 
is automatically performed following the 256-bit arithmetic).

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

This subroutine is for pure multiplications, so in line 8, the $\texttt{C}$ registry is set to 0. Then, the executor is instructed to compute the proper $D$ and $E$ values.

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

At line 10, $D$ is computed by taking the bits 256 to 511 of $\texttt{_mulArith}$ and stored at the $\texttt{D}$ registry.

A line 11, $E$ is computed by taking the bits 0 to 255 of \texttt{\_mulArith}. At this line, the $E$ value is at $\texttt{op}$, $\texttt{:ARITH}$ checks the operation and the $E$ value is stored at the $\texttt{E}$ registry. 

At lines 12 and 13 the result of the operation is stored in memory:
$E$ in $\texttt{arithRes1}$ and $D$ in $\texttt{arithOverflow}$.

Finally, in line 14 we restore the previous values of registries, in line 15 we read the return code address and finally jump to this address in line 16.




## MULMOD Opcode Assembly 

We are under the situation where the top of the stack looks like
$\mathtt{STACK} = [A, B, N, ... ]$. The assembly code for the MULMOD opcode is the following:

```linenums="1"
  ; zkevm-rom:main/opcodes.zkasm
  ; Stack checks
  SP - 3         :JMPN(stackUnderflow)
  SP - 1 => SP
  GAS-8 => GAS   :JMPN(outOfGas)

  ; Load multiplicands
  $ => A         :MLOAD(SP--)    ; (A=A)
  $ => B         :MLOAD(SP--)    ; (B=B)
  A              :MSTORE(arithA) ; [arithA=A]
  B              :MSTORE(arithB) ; [arithB=B]
  ${var _mulAB = A * B}          ; FIX with $$

  ; Check (e): if(N<0,1) R=0
  $ => A         :MLOAD(SP)      ; (A=N)
  2 => B                         ; (B=2)
  $              :LT, JMPC(zeroOneMod)

  ; Check (a): A*B = D*2**256 + E
        :CALL(mulARITH) ; [arithRes1=E, arithOverflow=D]

  ; Check Kh == 0
  ${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
  ${cond(B == 0)} :JMPN(mulModNoKH)

  ; Check (b): Kl*N+R = D1*2**256+E
  ${(_mulAB / A) % (2 << 256)} => B ; (B=Kl) Kl = b0-255 A*B/N
  ${_mulAB % A} => C                ; (C=R)  R = A*B%N
  ${(B * A + C) >> 256} => D        ; (D=D1) D1 = b256-511 B*A+C
  $              :MLOAD(arithRes1), ARITH ; (op=E)

  ; Check (c): Kh*N+D1 = 0*2**256+D
  ${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
  D => C   ; (C=D1)
  0 => E   ; (E=0)
  $             :MLOAD(arithOverflow), ARITH ; (op=D)

  ; Check (d): assert R<N
  A => B        ; (B=N)
  C => A        ; (A=R)
  $ => A         :LT
  1              :ASSERT

  ; PUSH R
  C              :MSTORE(SP++)
                 :JMP(readCode)

mulModNoKH:
  ; Check (b): Kl*N+R = D1*2**256+E (D1=D)
  ${(_mulAB / A)} => B ; (B=Kl)  Kl = A*B/N where Kh=0
  ${_mulAB % A} => C   ; (C=R)   R = A*B % N
  $ => D         :MLOAD(arithOverflow)     ; (D=D)
  $              :MLOAD(arithRes1), ARITH  ; (op=E)

  ; Check (d): assert R<N
  A => B         ; (B=N)
  C => A         ; (A=R)
  $ => A          :LT
  1               :ASSERT

  ; PUSH R
  C               :MSTORE(SP++)
                  :JMP(readCode)

zeroOneMod:
    0             :MSTORE(SP++)
                  :JMP(readCode)
```


Next, we describe the previous assembly code step by step.

The first step of the MULMOD implementation is to POP the $A$ and $B$ 
values and load them into the proper memory labels:

```linenums="1"
  SP - 3         :JMPN(stackUnderflow)
  SP - 1 => SP
  GAS-8 => GAS   :JMPN(outOfGas)

  ; Load multiplicands
  $ => A         :MLOAD(SP--)    ; (A=A)
  $ => B         :MLOAD(SP--)    ; (B=B)
  A              :MSTORE(arithA) ; [arithA=A]
  B              :MSTORE(arithB) ; [arithB=B]
  ${var _mulAB = A * B}          ; FIX with $$
```
- Line 1 checks that we have 3 elements at the top of the stack to
do the MULMOD operation.
- Line 2 positions the $\texttt{SP}$ at the address of the top element.
- Line 3 checks that there is enough gas remaining for doing the operation.
- Line 6 loads multiplicand $A$ and stores it in the $\texttt{A}$ registry. This is denoted in comments as $\texttt{(Registry=Value)}$, in this case, $\texttt{(A=A)}$. 
- Line 7 does the same for multiplicand $B$.
- Line 8 stores the value in A registry into memory at label arithA. This is denoted in comments as $\texttt{[mem_label=Value]}$.
- Finally, at line 10, we instruct the executor to compute the big number $A \cdot B$ and store the result in the executor variable called $\texttt{_mulAB}$.

$\textbf{Note.}$ Ideally $\texttt{\$\$}$ should be used at line 10 because it is a pure executor function but currently, $\texttt{\$}$ has to be used which uses a row of the execution trace (this might be fixed in the future).

```linenums="1"
stackOverflow:
    ${eventLog(onError, overflow)}
                    :JMP(handleError)
outOfGas:
    ${eventLog(onError, OOG)}
                    :JMP(handleError)

handleError:
    ;revert all state changes
    ;initSR --> balance = balance - gas, nonce + 1
    $ => SR         :MLOAD(initSR)
```

When we have errors, we call a function at the executor to log the error and then, we jump to the $\texttt{handleError}$ code label. When there is an error, we revert all the state changes by charging again the initial state root at the $\texttt{SR}$ registry. The initSR is the root the hash with the same state except that:
 
<center>
$\texttt{balance = balance - gas}$ and that 
$\texttt{nonce = nonce + 1}$.
</center>


Next, we check expression $\textbf{(e)}$,
$N \in \{0,1\}$?

```linenums="1"
  ; Check (e): if(N<0,1) R=0
  $ => A         :MLOAD(SP)      ; (A=N)
  2 => B                         ; (B=2)
  $              :LT, JMPC(zeroOneMod)

zeroOneMod:
    0               :MSTORE(SP++)
                    :JMP(readCode)
```

The $\texttt{LT}$ is an operation verified by the $\textbf{Binary}$ 
state machine. LT must be 1 if the value of the $\texttt{A}$ registry is lower than the value of the $\texttt{B}$ registry and, 0 otherwise.

The result of LT is introduced as a free input in the execution trace of 
the $\textbf{Main}$ SM and verified by the $\textbf{Binary}$ SM. $\texttt{JMPC}$ jumps if $\texttt{op}>0$. In this code, if $A<B$ the executor introduces a $1$ as the free input ($\texttt{op}=1$) and, $\texttt{JMPC}$ jumps to $\texttt{zeroOneMod}$. At $\texttt{zeroOneMod}$, we store a 0 at the top of the stack as the result of the $\texttt{MULMOD}$ operation and, finally, we jump to read the next opcode.


```linenums="1"
  ; Check (a): A*B = D*2**256 + E
            :CALL(mulARITH) ; [arithRes1=E, arithOverflow=D]
```

If $N$ is not a special case, we do not jump but we compute $\textbf{(a)}$, the decomposition of $A \cdot B$:

$$A \cdot B + 0 = D \cdot 2^{256} + E $$

Recall that the values $A$ and $B$ are stored at memory, at the memory labels $\texttt{arithA}$ and $\texttt{arithB}$. The decomposition values $D$ and $E$, are also stored at memory after calling the subroutine, in particular, at the memory labels $\texttt{arithOverflow}$ ($D$) and $\texttt{arithRes1}$ ($E$), respectively. This is denoted in the comment as $\texttt{[arithRes1=E, arithOverflow=D]}$.


Next, we compute $K_h$ and store it in the register $B$:

```linenums="1"
  ; Check Kh == 0
  ${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
  ${cond(B == 0)} :JMPN(mulModNoKH)
```

Observe that we treat the case where $K_h = 0$ separately because 
this case needs one check less. If $K_h = 0$ we jump into the code label $\texttt{mulModNoKH}$. Notice that we jump using a condition checked by the executor: $\texttt{cond(B==0)}$ and introduced as a free input. This is a correct way of implementing the verification because the $\textbf{Arith}$ SM will check all the expressions that enforce that $R$ is the correct result of the $\texttt{MULMOD}$ operation.

```linenums="1"
mulModNoKH:
  ; Check (b): Kl*N+R = D1*2**256+E (D1=D)
  ${(_mulAB / A)} => B ; (B=Kl)  Kl = A*B/N where Kh=0
  ${_mulAB % A} => C   ; (C=R)   R = A*B % N
  $ => D         :MLOAD(arithOverflow)     ; (D=D)
  $              :MLOAD(arithRes1), ARITH  ; (op=E)

  ; Check (d): assert R<N
  A => B         ; (B=N)
  C => A         ; (A=R)
  $ => A          :LT
  1               :ASSERT

  ; PUSH R
  C               :MSTORE(SP++)
                  :JMP(readCode)
```

Recall that we already checked (a).

When $K_h$ is 0, we just need to check (b) and (d):

$$
\begin{align}
\textbf{(a)}  &A \cdot B + 0 = D \cdot 2^{256} + E \ \text{ (CHECKED) }\\
\textbf{(b)}  &K_l \cdot N+R = D \cdot 2^{256}+E \\
\textbf{(d)}  &R < N
\end{align}
$$

Line 4 loads $R$ in $\texttt{C}$.
Line 5 loads the previously computed $D$. 
Line 6 loads the previously computed $E$ into $\texttt{op}$ and triggers the Arith check using the $\texttt{:ARITH}$ instruction, which always checks:

$$
A \cdot B + C = D \cdot 2^{256} + \texttt{op}.
$$

```linenums="1"
mulModNoKH:
  ; Check (b): Kl*N+R = D1*2**256+E (D1=D)
  ${(_mulAB / A)} => B ; (B=Kl)  Kl = A*B/N where Kh=0
  ${_mulAB % A} => C   ; (C=R)   R = A*B % N
  $ => D         :MLOAD(arithOverflow)     ; (D=D)
  $              :MLOAD(arithRes1), ARITH  ; (op=E)

  ; Check (d): assert R<N
  A => B         ; (B=N)
  C => A         ; (A=R)
  $ => A          :LT
  1               :ASSERT

  ; PUSH R
  C               :MSTORE(SP++)
                  :JMP(readCode)
```

Lines 9, 10, 11 and 12 check (d). If $R$ is not less than $N$, we abort the execution using the $\texttt{ASSERT}$ instruction. The ASSERT instruction makes sure that the value at the $\texttt{A}$ register is the same as the value of $\texttt{op}$. If this is not fulfilled, the proof cannot be generated. If everything is OK, we push the result to the top of the stack and read the next opcode (lines 15 and 16).

```linenums="1"
; Check (b): Kl*N+R = D1*2**256+E
${(_mulAB / A) % (2 << 256)} => B ; (B=Kl) Kl = b0-255 A*B/N
${_mulAB % A} => C                ; (C=R)  R = A*B%N
${(B * A + C) >> 256} => D        ; (D=D1) D1 = b256-511 B*A+C
$              :MLOAD(arithRes1), ARITH ; (op=E)

; Check (c): Kh*N+D1 = 0*2**256+D
${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
D => C   ; (C=D1)
0 => E   ; (E=0)
$             :MLOAD(arithOverflow), ARITH ; (op=D)

; Check (d): assert R<N
A => B        ; (B=N)
C => A        ; (A=R)
$ => A         :LT
1              :ASSERT

; PUSH R
C              :MSTORE(SP++)
               :JMP(readCode)
```

In this case, all the expressions (b), (c) and (d) have to be verified:

$$
\begin{align}
\textbf{(a)}  &A \cdot B + 0 = D \cdot 2^{256} + E\ \text{ (CHECKED) } \\
\textbf{(b)}  &K_l \cdot N+R = D_1 \cdot 2^{256}+E \\
\textbf{(c)}  &K_h \cdot N+D_1 = 0 \cdot 2^{256}+D \\
\textbf{(d)}  &R < N
\end{align}
$$

Lines 13 to 21 do the same as for the case $K_h = 0$.
Lines 1 to 5 check expression (b).
Lines 7 to 11 check expression (c).

```linenums="1"
; Check (b): Kl*N+R = D1*2**256+E
${(_mulAB / A) % (2 << 256)} => B ; (B=Kl) Kl = b0-255 A*B/N
${_mulAB % A} => C                ; (C=R)  R = A*B%N
${(B * A + C) >> 256} => D        ; (D=D1) D1 = b256-511 B*A+C
$              :MLOAD(arithRes1), ARITH ; (op=E)

; Check (c): Kh*N+D1 = 0*2**256+D
${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
D => C   ; (C=D1)
0 => E   ; (E=0)
$             :MLOAD(arithOverflow), ARITH ; (op=D)

; Check (d): assert R<N
A => B        ; (B=N)
C => A        ; (A=R)
$ => A         :LT
1              :ASSERT

; PUSH R
C              :MSTORE(SP++)
               :JMP(readCode)
```

Notice how we introduce values using free inputs and from 
previously stored values in memory to do the checks.

Line 2 instructs the executor to compute $K_l$ and 
introduces this value as a free input that is copied to the $\texttt{B}$ registry. $K_l$ is computed as the 256 least significant bits of the big number $A \cdot B/N$.

```linenums="1"
; Check (b): Kl*N+R = D1*2**256+E
${(_mulAB / A) % (2 << 256)} => B ; (B=Kl) Kl = b0-255 A*B/N
${_mulAB % A} => C                ; (C=R)  R = A*B%N
${(B * A + C) >> 256} => D        ; (D=D1) D1 = b256-511 B*A+C
$              :MLOAD(arithRes1), ARITH ; (op=E)

; Check (c): Kh*N+D1 = 0*2**256+D
${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
D => C   ; (C=D1)
0 => E   ; (E=0)
$             :MLOAD(arithOverflow), ARITH ; (op=D)

; Check (d): assert R<N
A => B        ; (B=N)
C => A        ; (A=R)
$ => A         :LT
1              :ASSERT

; PUSH R
C              :MSTORE(SP++)
               :JMP(readCode)
```

Line 3 instructs the executor to compute $N$ and introduce this value as a free input that is copied to the $\texttt{C}$ registry.
Line 4 does something similar for the $D_1$ value, which is copied to the $\texttt{D}$ registry.
Line 7 starts the verification of (c) because recall that $K_h \neq 0$.


```linenums="1"
; Check (b): Kl*N+R = D1*2**256+E
${(_mulAB / A) % (2 << 256)} => B ; (B=Kl) Kl = b0-255 A*B/N
${_mulAB % A} => C                ; (C=R)  R = A*B%N
${(B * A + C) >> 256} => D        ; (D=D1) D1 = b256-511 B*A+C
$              :MLOAD(arithRes1), ARITH ; (op=E)

; Check (c): Kh*N+D1 = 0*2**256+D
${(_mulAB / A) >> 256} => B ; (B=Kh) Kh = b256-511 A*B/N 
D => C   ; (C=D1)
0 => E   ; (E=0)
$             :MLOAD(arithOverflow), ARITH ; (op=D)

; Check (d): assert R<N
A => B        ; (B=N)
C => A        ; (A=R)
$ => A         :LT
1              :ASSERT

; PUSH R
C              :MSTORE(SP++)
               :JMP(readCode)
```

Notice that when doing this check, we use the value $D$ previously stored at the memory label $\texttt{arithOverflow}$. Notice also that we compute the value $K_h$ as the bits from 256 to 511 of the big integer value $B \cdot A+C$. Finally, observe that the value $K_h$ is introduced as a free input and copied
to the $\texttt{B}$ registry.



$\textbf{Counters}$ are a way to control that the total number of steps do not exceed the maximum polynomial size.

Here, it is state that the maximum number of steps of the main we can take for the opcode is $150$:

```linenums="1"
%MAX_CNT_STEPS - STEP - 150 :JMPN(outOfCounters)
```
  
We can invoke a maximum of $3$ times the Binary (two $\texttt{:LT}$ and one $\texttt{:ADD}$ instructions) and $3$ times the Binary (three $\texttt{:ARITH}$ instructions). Hence, we will add the following code at the beginning of the opcode

```linenums="1"
%MAX_CNT_ARITH - CNT_ARITH - 3 :JMPN(outOfCounters)
%MAX_CNT_BINARY - CNT_BINARY - 3 :JMPN(outOfCounters)
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

