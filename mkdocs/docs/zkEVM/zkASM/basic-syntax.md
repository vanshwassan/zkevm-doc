
# zkASM: The Basic Syntax
This section is dedicated to explaining the basic syntax of zkASM from a high-level point of view. The advanced syntax is totally dependent of the use case (e.g., the design of a zkEVM) and will be explained in more detail with examples in a later section.

It is important to remark that each instruction of the zkASM is executed sequentially (the exception being the execution of a jump): one after the other. Instructions are depicted line-by-line and are divided into two parts. The left side part includes the part of the code that actually gets executed in the corresponding file, while the right part is related to the execution of opcodes, jumps and subroutines and is indicated by the colon "$:$" symbol.

## Comments and Modules

Comments are made with the semicolon "$;$" symbol.

```
; This is an example comment.
```

At this moment, only one-line comments are available.

One can subdivide the zkASM code into multiple files and import code with the `INCLUDE` keyword. This is what we refer to as the **modularity** of the zkASM.

```
; File: main.zkasm

INCLUDE "utils.zkasm"
INCLUDE "constants.zkasm"
; -- code --
```

## Storing Values on Registers

There are many ways by which values can be stored in registers:

1. Assign a constant to one or more registers by using the arrow operator "=>":

        0 => A,B

2. Similarly, we can store the value of a register in the other registers:

        A => B,C

    More generally, we can store the value of a function $f$ of registers:

        f(A,B) => C,D

3. We can also store a global variable in a register:

        %GLOBAL_VAR => A,B

4. The result of executing an Executor Method can also be stored in one or more registers. The indication of such execution is with the dollar "$" sign, which should be treated as a free input:


        ${ExecutorMethod(params)} => A,B


    Notice that the method `Executor Method` does not necessarily depend on the registers. A good example of such a method is `SHA256`.

5. If a method gets executed (with the dollar sign) on its own, its main purpose is to generate the log information.

        ${ExecutorMethod(params)}

6. Apart from the Executor Methods, one can also use inline functions. These functions, which are also instantiated by the Executor, are simply 'short' and 'non-reused' Executor Methods:

        ${A >> 2} => B
        ${A & 0x03} => C

## Introducing Opcodes

Up to this point, every instruction is a direct interaction with the registers. Now, we move one step ahead and get interaction with other parts of the ROM, thanks to the introduction of the zkEVM opcodes.

To assign the output of a zkEVM opcode in a register, we use the following syntax:

```
$ => A,B    :OPCODE(param)
```

A clear example of such a situation is when we use the memory load opcode:

```
$ => A,B    :MLOAD(param)
```

When a register is written on the left side of an opcode, as in the following example, it is typically used to indicate that the value of the register, say `A`, is the input of the memory store opcode:

```
A   :MSTORE(param)
```

Similarly, we can assign a free input to a register and later on execute several zkEVM opcodes using the following syntax:

```
${ExecutorMethod(params)} => A      :OPCODE1
                                    :OPCODE2
                                    :OPCODE3
                                    ...
```

When an Executor Method (along with a register to store its result) is combined with a jump opcode, it is typically for handling an unexpected situation, such as running out of gas:

```
${ExecutorMethod(params)} => A :JMP(param)
```

It is also typical to encounter negative jumps to check appropriate situations in which carry on forthcoming operations:  <!-- this line is not clear-->

```
SP - 2  :JMPN(stackUnderflow)
```

## Code Injection

Inline javascript-based instruction can be injected in the plain by using the doble dollar "$" symbol:

```
$${CODE}
```

The main difference between the single dollar sign and the double dollar sign is that while the methods inside the single dollar sign originate from the Executor, those with double dollar do not; it, in that case, is the plain javascript code that is executed by the ROM.

## Asserts

Asserts work by comparing what is being asserted with what is the value on register `A`. So, for instance, the following instruction compares the value inside register `B` with the value inside register `A`:<!-- not clear-->

```
B    :ASSERT
```
