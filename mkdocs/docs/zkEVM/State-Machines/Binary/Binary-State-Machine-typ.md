[ToC]





# Binary State Machine





The Binary State Machine (SM) is one of the six secondary state machines receiving instructions, called Binary Actions, from the Main State Machine Executor.

It is responsible for the execution of all binary operations in the zkProver.

As a secondary state machine, the Binary State Machine has the executor part (the Binary SM Executor) and an internal Binary PIL (program) which is a set of verification rules, written in the PIL language. The Binary SM Executor is written in two versions; Javascript and C/C++.



The Polygon Hermez Repo is here  [https://github.com/0xPolygonHermez](https://github.com/0xPolygonHermez)

**Binary SM Executor**: [sm_binary.js](https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/src/sm/sm_binary.js)

**Binary SM PIL**: [binary.pil](https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/pil/binary.pil) 

**Test Vectors**: [binary_test.js](https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/test/sm/sm_binary_test.js)







## Binary Operations on 256-bit Strings





The zkEVM (zero-knowledge Ethereum Virtual Machine) performs the following binary operations on 256-bit strings,

- $\text{ADD }$ ($+$), the addition operation adds two 256-bit numbers.
- $\text{SUB }$ ($-$), the subtraction operation computes the difference between two 256-bit numbers.
- $\text{LT }$ ($<$), the less-than operation checks if a 256-bit number is smaller than another 256-bit number, without considering the signs the numbers.
- $\text{SLT }$ ($<$), the signed less-than operation checks if a 256-bit number is smaller than another 256-bit number, but takes into consideration the respective signs of the numbers.
- $\text{EQ }$ ($=$), the 'equal' operation checks if two 256-bit numbers are equal.
- $\text{AND }$ ($\land$), the operation that computes the bit-wise "AND" of two numbers.
- $\text{OR }$ ($\lor$), the operation computes the bit-wise "OR" of two numbers.
- $\text{XOR }$  ($\oplus$), the operation computes the bit-wise "XOR" of two numbers.
- $\text{NOT }$ ($\neg$), the operation computes the bit-wise "NOT" of a binary number.



In order to understand how the $\text{ADD}$, $\text{SUB}$, $\text{LT}$ and $\text{SLT}$ operations work, one needs to first understand how the zkEVM codes 256-bit strings to signed and unsigned integers.

Figure 1 shows these codifications for 3-bit strings but the idea can be easily extended to 256-bit strings.



![Codifications of 3-bit strings for signed and unsigned integers as used by the EVM ](figures/fig-cdfctn-3bit-strngs.png)
<div align="center"><b> Figure 1: Codifications of 3-bit strings for signed and unsigned integers as used by the EVM </b></div>



Adding two strings is performed bit-by-bit using the corresponding carry.



For example, add the 3-bit strings $\mathtt{0b001}$ and $\mathtt{0b101}$, where $\mathtt{0b}$ means binary,

- Start with an initial $carry=0$ and add the least significant bits,

    $1+1+carry=1+1+0=0$, so the next carry becomes $carry'=1$.

- Next, add the the second least-significant bits using the previous carry, 

    $0+0+carry = 0+0+1 = 1$, this time the next carry is $carry'=0$.

- Finally, add the most significant bits,

    $0+1+carry=0+1+0=1$, with the final carry being $carry'=0$.

- As a result: $\mathtt{0b001}+\mathtt{0b101} = \mathtt{0b110}$ with $carry=0$.



The sum $\mathtt{0b001}+\mathtt{0b101} = \mathtt{0b110}$, for unsigned integers is $1+5=6$, while for signed integers encoded with complement to two, this sum is $1+(-3) =(-2)$.

In other words, the same binary sum can be done for both signed integers and for unsigned integers.



The operations $\text{LT}$ and $\text{SLT}$ are different however.

When comparing unsigned integers (using $\text{LT}$), the natural order for comparisons is applied. For example, $010 < 110$, i.e., $2 < 6$.

When comparing signed integers (using $\text{SLT}$), one must take into account the most significant bit that acts as the sign.

- If the most-significant bits of the two strings being compared is the same, the the natural order applies. For example, $101  < 110$. i.e., $-3 < -2$

- However, if the most significant bits of strings being compared are different, then the order must be flipped (bigger numbers start with 0). For example, $110 < 001$. i.e., $-2  <  1$.

Finally, notice that with unsigned integers, there is a caveat since 4 and -4 have the same codification.



On the other hand, the $\text{AND}$, $\text{OR}$, $\text{XOR}$ and $\text{NOT}$ operations are bit-wise operations, that is to say, the operation is done bit-by-bit. As a result, there is no carry to be considered when operating a pair of bits. This makes the checks easier to implement for bit-wise operations.

Table 1 depicts the truth tables of $\text{AND}$, $\text{OR}$ and $\text{XOR}$ operators, respectively.


![Truth Tables of bit-wise operations](figures/fig-trth-tbls-bitws.png)
<div align="center"><b> Table 1: Truth Tables of bit-wise operations </b></div>



Notice that we do not consider the $\text{NOT}$ operation. This is because the $\text{NOT}$ operation can be easily implemented with the $\text{XOR}$ operation, by taking an $\text{XOR}$ of the 256-bit string and $\texttt{0xff...ff}$.







## The Design Of The Binary SM 





The Executor of the Binary SM records the trace of each computation in the state machine, and this computational trace is used to prove correctness of computations.

The execution trace is typically in the form of 256-bit strings. And the polynomial constraints, that every correct execution trace must satisfy, are described in a PIL file (or 'code').

For the Binary SM, these computations refers to the aforementioned binary operations, and uses special codes for each of the operations.





### Codes for the Binary Operations



Each operation that the Binary SM checks has a code as shown in Table 2, below. 

In instances where none of the defined binary operations is carried out, the Binary SM's operation is considered to be a $\text{NOP}$ (No Operation), in which case any code not in the defined list of codes can be used.



<div align="center"><b> Table 2: All Operations Checked by the Binary SM </b></div>

<center>

| $\textbf{Operation Name}$ | $\textbf{Mnemonic}$ | $\textbf{Symbol}$ | $\textbf{BinOpCode}$ |
| :-----------------------: | :-----------------: | :---------------: | :------------------: |
|     $\text{Addition}$     |   $\mathrm{ADD}$    |        $+$        |         $0$          |
|   $\text{Subtraction}$    |   $\mathrm{SUB}$    |        $-$        |         $1$          |
|    $\text{Less Than}$     |    $\mathrm{LT}$    |        $<$        |         $2$          |
| $\text{Signed Less Than}$ |   $\mathrm{SLT}$    |        $<$        |         $3$          |
|     $\text{Equal To}$     |    $\mathrm{EQ}$    |        $=$        |         $4$          |
|   $\text{Bitwise AND}$    |   $\mathrm{AND}$    |      $\wedge$     |         $5$          |
|    $\text{Bitwise OR}$    |    $\mathrm{OR}$    |       $\vee$      |         $6$          |
|   $\text{Bitwise XOR}$    |   $\mathrm{XOR}$    |     $\oplus$      |         $7$          |
|   $\text{No Operation}$   |   $\mathrm{NOP}$    |  $\mathrm{NOP}$   |       $\star$        |

</center>





### Internal Byte Plookups



The Binary SM is internally designed to use plookups of bytes for all the binary operations. 

That is, it uses plookups that contain all the possible input bytes and output byte combinations,

$$
\text{byte}_{in_0} \star \text{byte}_{in_1} = \text{byte}_{out},
$$

where $\star$ is one of the possible operations.



When executing a binary operation between the 256-bit input strings, an execution trace is generated in cycles of $32$ steps per operation.

At each step, the corresponding byte-wise operation and any required extra information, such as 'carries' or auxiliary values, form part of the computation trace.

Additionally, each $256$-bit string (the two inputs and the output) are expressed using $8$ registers of $32$-bits.







### Connection with the Main SM



The constraint that connects the execution trace of the Main SM with the execution trace of the Binary SM is a Plookup, which is performed at each row of the Binary SM execution trace when the cycle is completed (this is when a register called $\texttt{RESET}$ is 1).

The Plookup checks the operation code, the registries for the input and output 256-bit strings, and the final carry.







## Operating At Byte-Level 



This section provides examples of how the byte-wise operations work. 



A $256$-bit integer $\mathbf{a}$ is herein denoted in vector form as $(a_{31}, \dots, a_1, a_0)$ to indicate that,
$$
\mathbf{a} = a_{31}\cdot (2^8)^{31} + a_{30}\cdot (2^8)^{30} + \cdots + a_1\cdot2^8 + a_0   =
\sum_{i = {31}}^{0} a_i \cdot (2^8)^i,
$$
where each $a_i$ is a byte that can take values between $0$ and $2^8 - 1$. 



**Example 1.**

If $\mathbf{a} = 29967$, its byte decomposition can be written as $\mathbf{a} = (\mathtt{0x75}, \mathtt{0x0F})$, because $\mathbf{a} = 29967 = 117 \cdot 2^8 + 15$, and in hexadecimal, $117 \mapsto \mathtt{0x75}$ and $15 \mapsto \mathtt{0x0F}$.





### Addition 




Here is how the addition operation on two $256$-bit numbers is reduced to a byte-by-byte addition, and thus ready to use the byte-wise Plookup table.



Observe that adding two bytes $a$ and $b$ (i.e., $a$ and $b$ are members of the set $[0, 2^8-1]$), may result in a sum $c$ which cannot be expressed as a single byte. 

For example, if $a = \mathtt{0xFF}$ and $b = \mathtt{0x01}$, then,
$$
a + b = \mathtt{0xFF} + \mathtt{0x01} = \mathtt{0x100}.
$$
In byte-form, $c=\mathtt{0x00}$ and with $carry'=1$. This carry has to be taken care of when dealing with bytes.



Consider now the process of adding two bytes. 



**Example 2.**

Take for instance, $\mathbf{a} = (a_1, a_0) = (\mathtt{0xFF}, \mathtt{0x01})$ and $\mathbf{b} = (b_1, b_0) = (\mathtt{0xF0}, \mathtt{0xFF})$.

- First add the less significant bytes:

$$
\begin{aligned}
a_1 + b_1 &= \mathtt{0x01} + \mathtt{0xFF} = c_1 = \mathtt{0x00}, \\
carry_1 &= 1.
\end{aligned}
$$

- Then, add the next significant byte,

$$
\begin{aligned}
a_2 + b_2 + carry_1 &= \mathtt{0xFF} + \mathtt{0xF0} = c_2 = \mathtt{0xF0}, \\
carry_2 &= 1.
\end{aligned}
$$

The previous example shows is scheme depicts several cases that need to be treated separately;



1. If $a_1 + b_1 < 2^8$ and $a_2 + b_2 < 2^8$, then the sum $\mathbf{a} + \mathbf{b}$ is simply,

      $$
      \mathbf{a} + \mathbf{b} = (a_2 + b_2, a_1 + b_1).
      $$

2. If $a_1 + b_1 < 2^8$ but $a_2 + b_2 \geq 2^8$, then $a_2 + b_2$ does not fit in a single byte. Hence, the sum of $a_2$ and $b_2$ has to be written as,

      $$
      a_2 + b_2 = 1 \cdot 2^8 + c_2,
      $$
      for some byte $c_2$. The addition $\mathbf{a} + \mathbf{b}$ is then computed as follows, 

      $$
      \mathbf{a} + \mathbf{b} = (1, c_2, a_1 + b_1).
      $$


3. If $a_1 + b_1 \geq 2^8$, then we have that:
      $$
      a_1 + b_1 = 1 \cdot 2^8 + c_1,
      $$
      for some byte $c_1$. Then we can write,
      $$
      \mathbf{a} + \mathbf{b} = (a_2 + b_2 + 1) \cdot 2^8 + c_1.
      $$

      Consider the following two scenarios:

      1. If $a_2 + b_2 + 1 \geq 2^8$, then the sum will take the form:
            $$
            a_2 + b_2 + 1 = 1 \cdot 2^8 + c_2.
            $$
            ​	
            Therefore, the byte decomposition of $\mathbf{a} + \mathbf{b}$ is,
            $$
            \mathbf{a} + \mathbf{b} = (1, c_2, c_1).
            $$

      2.	If $a_2 + b_2 + 1 < 2^8$, then the byte decomposition of $\mathbf{a} + \mathbf{b}$ is:
            $$
            \mathbf{a} + \mathbf{b} = (c_2, c_1).
            $$
      
Observe that addition of $256$-bit numbers can be reduced to additions at byte-level by operating through the previous cases in an iterative manner. 





### Subtraction 



Reducing Subtraction to byte-level turns out to be trickier than Addition case. 



Suppose $\mathbf{a} = \mathtt{0x0101}$ and $\mathbf{b} = \mathtt{0x00FF}$. 

Observe that $\mathtt{0xFF}$ cannot be subtracted from $\mathtt{0x01}$ because $\mathtt{0xFF} > \mathtt{0x01}$.

However, we know that the result is $\mathbf{a} - \mathbf{b} = \mathbf{c} = \mathtt{0x0002}$.

In order to get this result, notice that the operation can be described as follows,

$$
\begin{aligned}
\mathbf{a} - \mathbf{b} & = (\mathtt{0x01} - \mathtt{0x00}) \cdot 2^8 + (\mathtt{0x01} - \mathtt{0xFF}) \\
   & = (\mathtt{0x01} - \mathtt{0x00}) \cdot 2^8  - 2^8 + 2^8 + (\mathtt{0x01} - \mathtt{0xFF}) \\
   & = (\mathtt{0x01} - \mathtt{0x00 - 0x01}) \cdot 2^8  + \mathtt{0xFF + 0x01} + \mathtt{0x01} - \mathtt{0xFF} \\
   & = ( \mathtt{0x00} ) \cdot 2^8  + \mathtt{0x02}
\end{aligned}
$$

The output byte decomposition is $\mathbf{a} = (c_1, c_0)  = (\mathtt{0x00}, \mathtt{0x02})$. 



Nonetheless, it may be necessary to look at more examples so as to better understand how subtraction works at byte-level in a more general sense.



Consider now subtraction of numbers with $3$ bytes. Say, $a = \mathtt{0x0001FE}$ and $b = \mathtt{0xFEFFFF}$.

First analyse the first two bytes, as in the previous example,

$$
\begin{aligned}
(\mathtt{0x01} - \mathtt{0xFF}) \cdot 2^8 + (\mathtt{0xFE} - \mathtt{0xFF}) &= (\mathtt{0x01} - \mathtt{0xFF} - \mathtt{0x01} ) \cdot 2^8 + (\mathtt{2^8} + \mathtt{0xFE} - \mathtt{0xFF}) \\
& = (\mathtt{0x01} - \mathtt{0xFF - 0x01}) \cdot 2^8 + \mathtt{0xFF}
\end{aligned}
$$

But now observe that $\mathtt{0x01} - \mathtt{0xFF} - \mathtt{0x01}$ is also a negative value. Hence, there is a need to repeat the strategy and keep a carry to the next byte,

$$
\begin{aligned}
&(\mathtt{0x00} - \mathtt{0xFE}) \cdot 2^{16} + (\mathtt{0x01} - \mathtt{0xFF} - \mathtt{0x01}) \cdot 2^8 + \mathtt{0xFF} = \\
&(\mathtt{0x00} - \mathtt{0xFE} - \mathtt{0x01}) \cdot 2^{16} + (\mathtt{2^8} + \mathtt{0x01} - \mathtt{0xFF} - \mathtt{0x01}) \cdot 2^8 + \mathtt{0xFF} = \\
&(\mathtt{0x00} - \mathtt{0xFE} - \mathtt{0x01}) \cdot 2^{16} + \mathtt{0x01} \cdot 2^8 + \mathtt{0xFF}. 
\end{aligned}
$$


Observe that the previous example is included in this case. 



In general, let $a = (a_i)_i$ and $b = (b_i)_i$, with $a_i, b_i$ bytes, be the byte representations of $a$ and $b$. Instead of checking if we can perform the subtraction $a_i - b_i$ for some bytes $i$, we are checking if $a_i - b_i - \texttt{carry} \geq 0$. Equivalently, we are checking if $a_i - \texttt{carry} \geq b_i$. The previous case can be recovered by setting $\texttt{carry} = 1$ and the first case corresponds to setting $\mathtt{carry = 0}$. 



We have two possible cases,

- If $a_i - \texttt{carry} \geq b_i$, then $a_i - b_i - \texttt{carry}$ provides the corresponding $i$-th byte of the representation of $a - b$.

- If $a_i - \texttt{carry} < b_i$ then we should compute the corresponding $i$-th byte of the representation of $a - b$ as,

$$
2^8 - b_i + a_i - \texttt{carry} = 255 - b_i + a_i - \texttt{carry} + 1.
$$



However, we need to discuss the last step of our example. Observe that we can not perform the operation $\mathtt{0x00} - \mathtt{0xFE} - \mathtt{0x01}$ since it corresponds to a negative value. But as we are working with unsigned integers, we will do the two's complement and set the last byte to, 
$$
2^8 - \mathtt{0xFE} + \mathtt{0x00} - \mathtt{0x01} = 255 - \mathtt{0xFE} + \mathtt{0x00} - \mathtt{0x01} + 1 = 255 - b_3 + a_3 - \texttt{carry} + 1.
$$


Observe that this is also included in the case when $a_i - \texttt{carry} < b_i$, so we must not treat the last bit in a different manner. To end up with our example, we get the following byte representation of $a - b$,
$$
c = (\mathtt{0x01}, \mathtt{0x01}, \mathtt{0xFF}) = \mathtt{0x01} \cdot 2^{16} + \mathtt{0x01} \cdot 2^8 + \mathtt{0xFF}.
$$






### Less Than





We want to describe the less than comparator byte-wise. For $256$-bits integers, the operation $<$ will output $c = 1$ if $a < b$ and $c = 0$ otherwise. As we are working in the natural integers order, the most significant byte decide and, if they are equal, we should consider the previous one until we can decide. Let us propose the example with $a = \mathtt{0xFF AE 09}$ and $b = \mathtt{0x FF AE 02}$. We know that $a > b$. Why? We should start at the most significant byte. We know that
$$
a \mathtt{>> 16} = \mathtt{0x FF} = \mathtt{0x FF} = b \mathtt{>> 16}.
$$


Hence, we can not decide with this byte. An the same happens with the second byte, they are both equal to $\mathtt{0x AE}$. Hence, the less significant byte decides, 
$$
\mathtt{0x 09} > \mathtt{0x 02}.
$$


However, the problem with our set up is that we must start with the less significant byte and climb up to the most significant byte. The strategy will be to use some kind of a carry in order to "carry" the decisions from previous bytes. Let us do an example step by step, now with $a = \mathtt{0x FF AA 02}$ and $b = \mathtt{0x 01 AA 09}$. First of all, we will compare the less significant bytes. Since
$$
\mathtt{0x 02} < \mathtt{0x 09},
$$
we will set up $\mathtt{carry} = 1$. We will carry this decision until we finish to process all bytes or, alternatively, we should change to the complementary decision. Therefore, since the next two bytes are equal and we are not at the end, we maintain $\mathtt{carry}$ to $1$. The previous step is the last one. We compare the most significant bytes,
$$
\mathtt{0x FF} \not < \mathtt{0x 01}.
$$


Henceforth, we should output a $0$, independently to the previous carry decision. But, let us suppose now that $b = \mathtt{0x FF AA 09}$. Then, in this last step, we should output a $1$, since $a < b$. The idea is that, in the last step, if both bytes are equal, we should output the decision carry $\mathtt{carry}$. In general, in the step $i$, comparing bytes $a_i$ and $b_i$, we have $3$ cases,

- If $a_i < b_i$, we set $\mathtt{carry}$ to $1$. If we are at the most significant byte, we output $1$.

- If $a_i = b_i$, we let $\mathtt{carry}$ unchanged in order to maintain the previous decision. If we are at the most significant byte, we output $\mathtt{carry}$.

- If $a_i > b_i$, we set $\mathtt{carry}$ to $0$. If we are at the most significant byte, we output $0$. 







### Signed Less Than





In computer science, the most common method of representing signed integers on computers, is called \textbf{two's complement}. When the most significant bit is a one, the number is signed as negative. The way to express a negative integer $x$ into two's complement form is chosen so that, among integers of the same sign, the lexicographical order is maintained. That is, if $a < b$ are signed integers of the same sign, then its two's complement representations preserve the same order. This will not be true if the signs are different. For example, it is not surprising that
$$
000\dots0 > 111\dots1
$$
using the two's complement encoding, because $111\dots1$ is negative and $000\dots0$ is positive. The two's complement form of negative integer $x$ in a $N$-bits system is the binary representation of $2^N - x$. For example, let $x = -1$ and $N = 4$. Then,
$$
10000 - 0001 = 1111.
$$
Hence, $-1 = 1111$ in this representation. It is easy to see that $-2 = 1110$ because
$$
10000 - 0010 = 1110.
$$


Hence, observe that $-1 > -2$ because $1111 > 1110$ and conversely: the order is preserved for integers of the same sign. 



We will describe a method to compare signed integers byte-wise. First of all, let us analyze the order among all the signed bytes, in order to understand how to compare them. Once we achieve this, the strategy will be very similar to the previous Less Than. 



Let $a = (a_{31}, a_{30}, \dots, a_0)$ and $b = (b_{31}, b_{30}, \dots, b_0)$ be the byte-representation of the 256-bits unsigned integers $a$ and $b$. We will define $\texttt{sgn}(a) = a_{31, 7}$, where
$$
a_{31} = \sum_{i = 0}^7 a_{31, i} \cdot 2^i
$$
is the binary representation of $a_{31}$. That is, $\texttt{sgn}(a)$ is the most significant bit of $a$ or, equivalently, the "sign" of $a$. In a similar way, we define $\texttt{sgn}(b)$. Observe that it is easy to compare $a$ and $b$ if $\texttt{sgn}(a) \neq \texttt{sgn}(b)$. For example,
$$
a = \mathtt{0b11111111} = \mathtt{0xFF} < \mathtt{0x00} = \mathtt{0b00000000} = b
$$
because $\texttt{sgn}(a) > \texttt{sgn}(b)$ i.e. $a$ is negative and $b$ is positive. If $\texttt{sgn}(a) \neq \texttt{sgn}(b)$, we can simply compare $a$ and $b$ using the same strategy as before, because the natural lexicographic order is preserved in this case. Then, we have the following cases when comparing $a$ and $b$:

1. If $\texttt{sgn}(a) = 1$ and $\texttt{sgn}(b) = 0$, then $a < b$.

2. If $\texttt{sgn}(a) = 0$ and $\texttt{sgn}(b) = 1$, then $a > b$.

3. If $\texttt{sgn}(a) = \texttt{sgn}(b)$, the order is the usual one and hence, we already know how to compare $a$ and $b$. 

​	



Recall that we are processing the bytes of $a$ and $b$ from the less significant bytes to the most significant bytes. Hence, we need to adapt our strategy following this order. The strategy will be almost the same than in the unsigned operation. 


1. First of all, we start comparing $a_0$ and $b_0$.

      1. If $a_0 < b_0$, we set $\texttt{carry} = 1$. 

      2.	Otherwise we set $\texttt{carry} = 0$.	

2. For all $0 < i < 31$, we compare $a_i$ and $b_i$.

      1. If $a_i < b_i$, we set $\texttt{carry} = 1$.

      2. If $a_i = b_i$, we leave $\texttt{carry}$ unchanged from the previous step.

      3. Otherwise, we set $\texttt{carry} = 0$.

3. Now, we have to compare the last byte. We follow the described strategy of comparing the signs:

      1. If $\texttt{sgn}(a) > \texttt{sgn}(b)$, we output a $1$, so $a < b$.

      2. If $\texttt{sgn}(a) < \texttt{sgn}(b)$, we output a $0$, so $a < b$.

      3. If $\texttt{sgn}(a) = \texttt{sgn}(b)$, we compare the last bytes $a_{31}$ and $b_{31}$ in the same way we have compare the previous bytes. We output $0$ or $1$ accordingly:

         1. If $a_{31} < b_{31}$, we output a $1$, so $a < b$.

         2. If $a_{31} = b_{31}$, we output the previous $\texttt{carry}$, maintaining the last decision.

         3. Otherwise, we output a $0$, so $a \not < b$. 


Let us exemplify the previous procedure setting $a = \mathtt{0xFF FF FF 00}$ and $b = \mathtt{0x00 FF FF FF}$. We know that $a < b$, so we should output a $1$. Observe that the less significant byte of $a$ is leaser than the less significant byte of $b$. Hence, we should put $\texttt{carry}$ equal to $1$. The next two bytes of $a$ and $b$ are both equal to $\mathtt{0xFF FF}$, therefore we maintain $\texttt{carry}$ unchanged equal to $1$. However, since $a$ is negative and $b$ is positive, we should change the decision and output a $1$, independently of the $\texttt{carry}$. 





### Equality





We want to describe the equality comparator byte-wise. For unsigned $256$-bits integers, the operation $=$ will output $c = 1$ if $a = b$ and $c = 0$ otherwise. This operation is very simple to describe byte-wise, since $a = b$ if and only if all its bytes coincide. 



Let us compare $a = \mathtt{0xFF 00 a0 10}$ and $b = \mathtt{0xFF 00 00 10}$ byte-wise. Observe that the first byte is the same $\mathtt{0x10}$, however the next byte are different $\mathtt{0xa0} \neq \mathtt{0x00}$. Hence, we can finish here and state that $a \neq b$. 



We will describe an algorithm in order to proceed processing all the bytes. We will use a carry to mark up when a difference among bytes has $\textbf{not}$ been found (i.e. if $\texttt{carry}$ reach $0$, then $a$ and $b$ should differ). Hence, the algorithm to compare two $32$-bytes integers $a = (a_{31}, a_{30}, \dots, a_{0})$ and $b = (b_{31}, b_{30}, \dots, b_0)$ is the following:



1. First of all, since no differences have been found up to this point, set $\texttt{carry}$ equal to $1$.

2. Now, compare $a_0$ and $b_0$,

      1.	If $a_0$ and $b_0$ are equal, then leave $\texttt{carry}$ unchanged equal to $1$.

      2.	If $a_0 \neq b_0$, then set $\texttt{carry}$ equal to $0$, which will imply that $a \neq b$.

3. When comparing bytes $a_i$ and $b_i$ for $0 < i \leq 31$.

      1.	If $a_i = b_i \textbf{ and } \texttt{carry} = 1$, we should leave $\texttt{carry}$ unchanged and, if $i = 31$, we should output a $1$ because $a = b$. The reason of demanding $\texttt{carry} = 1$ in the enter condition is because we should ensure that, if $\texttt{carry} = 0$ in a previous step, we must never enter to this block and change the non-equality decision. This is because if $a_i \neq b_i$ for some $i$, then $a \neq b$.

      2.	Hence, if $a_i \neq b_i$, we should set $\texttt{carry} = 0$ and output a $0$ if $i = 31$. 

​	





### Bitwise Operations





We will describe all bitwise operations at once because they are the easiest 
ones, since we do not need to introduce carries. 



Now, the idea is to extend this operation bitwise. That is, if we have the
following binary representations of $a = (a_{31}, a_{30}, \dots, a_{0})$ and 
$a = (b_{31}, b_{30}, \dots, b_{0})$ where $a_i, b_i \in \{0, 1\}$, 
then we define,

$$
a \star b = (a_i \star b_i)_i = (a_{31} \star b_{31}, a_{30} \star b_{30}, \dots, a_0 \star b_0)
$$

for $\star$ being $\land, \lor$ or $\oplus$. 



For example, if $a = \mathtt{0xCB} = \mathtt{0b11001011}$ and $b = \mathtt{0xEA} = \mathtt{0b11101010}$ then,

$$
\begin{aligned}
a \land b &= \mathtt{0b11001010} = \mathtt{0xCA},\\
a \lor b &= \mathtt{0b11101011} = \mathtt{0xEB},\\
a \oplus b &= \mathtt{0b00100001} = \mathtt{0x21}.
\end{aligned}
$$


## Building the Preprocessed Polynomials

In this section we explain how the preprocessed polynomials, which are generated 
by the executor, are constructed. In what follows, when we refer to a ``cycle''
we refer to $32$ steps of computation.

In next table we show the global parameters that the executor take into account 
to generate the preprocessed polynomial throughout this section. In particular,
the table shows the (TODO: length) of the distinct preprocessed polynomials that
the executor have to take into account; so that they include all possible 
byte-to-byte combinations before reaching the limit $N = 2^{21}$.


$$
\begin{array}{|c|c|}
\hline
\textbf{N}                    &2^{21}  \\ \hline
\textbf{REGISTER_NUM}         &2^{3}   \\ \hline
\textbf{BYTES_PER_REGISTER}   &2^{2}   \\ \hline
\textbf{LATCH_SIZE}           &2^{5}   \\ \hline
\textbf{REG_SIZE}             &2^{8}   \\ \hline
\textbf{CIN_SIZE}             &2^{2}   \\ \hline
\textbf{P_LAST_SIZE}          &2       \\ \hline
\end{array}
$$

### Auxiliary Polynomials

Let's start with $\mathtt{FACTOR}$. This polynomial is in charge of introducing 
the factor that the input and the output registers have to be multiplied by, in 
order to charge them the corresponding bytes. More specifically, 
$\mathtt{FACTOR}$ will take values in the set $\{0,1,2^8,2^{16},2^{24}\}$ and 
the powers of two will indicate the distribution of bytes from least 
significant to most significant. 

For example, if $\mathtt{A} = \mathtt{0x1AFF2C}$, then $\mathtt{A}$ will be
constructed in $3$ steps byte-wise as follows:

$$
\begin{array}{|c|c|c|}
\hline
\textbf{Step} &\texttt{A} &\mathtt{FACTOR}                                   \\ \hline
1  &1 \cdot \mathtt{0x2C} &1                                                 \\ \hline
2  &2^8 \cdot \mathtt{0xFF} + \mathtt{0x2C}  &2^8                            \\ \hline
3  &2^{16} \cdot \mathtt{0x1A} + \mathtt{0xFF2C} = \mathtt{0x1AFF2C} &2^{16} \\ \hline
\end{array}
$$



Notice how $\mathtt{FACTOR}$ is a fundamental set of constants when positioning
bytes in their correct place.

Since registers $\mathtt{A}$, $\mathtt{B}$ and $\mathtt{C}$ are divided into
$8$ registers of $4$ bytes each, we need the corresponding $\mathtt{FACTOR}$ 
polynomial for each of these registers. Therefore, $\mathtt{FACTOR}$ have to be
seen as an array of $8$ positions. To be more explicit, we will use the 
polynomial $\mathtt{FACTOR}[i]$ in order to introduce the bytes of registers 
$\mathtt{A}[i]$, $\mathtt{B}[i]$ and $\mathtt{C}[i]$, for $0 \leq i < 8$. 
A bird-view of the values generated by $\mathtt{FACTOR}$ in each of its
positions can be seen in the following table.

$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\mathtt{STEP} & 1 & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9 & \dots & 29 & 30 & 31 & 32 \\ \hline
\mathtt{FACTOR}[0] & 1 & 2^8 & 2^{16} & 2^{24} & 0 & 0 & 0 & 0 & 0 & \dots & 0 & 0 & 0 & 0 \\ \hline
\mathtt{FACTOR}[1] & 0 & 0 & 0 & 0 & 1 & 2^8 & 2^{16} & 2^{24} & 0 & \dots & 0 & 0 & 0 & 0 \\ \hline
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \cdots & \vdots & \vdots & \vdots & \vdots \\ \hline
\mathtt{FACTOR}[7] & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & \dots & 1 & 2^8 & 2^{16} & 2^{24} \\ \hline
\end{array}
$$

Observe that this table will be repeated every $32$ steps, which conforms 
a cycle.

The code that generates $\mathtt{FACTOR}$ is the following:

```javascript
function buildFACTORS(FACTORS, N) {
  // The REGISTERS_NUM is equal to the number of factors
  for (let i = 0; i < REGISTERS_NUM; i++) {
    for (let j = 0; j < N; j += BYTES_PER_REGISTER) {
      for (let k = 0; k < BYTES_PER_REGISTER; k++) {
        let factor =
          BigInt((2 ** 8) ** k) *
          BigInt((j % (REGISTERS_NUM * BYTES_PER_REGISTER)) / BYTES_PER_REGISTER == i);
        FACTORS[i].push(factor);
      }
    }
  }
}
```


Next we have $\mathtt{RESET}$, which is used as a flag that is set to $1$ 
every time a cycle starts. This polynomial is used to appropriately reset the 
registers for a new pair of (inputs, output) i.e., every time an operation 
starts. A bird-view of the values generated by $\mathtt{RESET}$ can be seen
in following table.

$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\mathtt{STEP} & 1 & 2 & 3 & \dots & 32 \\ \hline
\mathtt{RESET} & 1 & 0 & 0 & \dots & 0 \\ \hline
\end{array}
$$

The code that generates $\mathtt{RESET}$ is the following:

```javascript
function buildRESET(pol, N) {
  for (let i = 0; i < N; i++) {
    pol.push(BigInt(i % (REGISTERS_NUM * BYTES_PER_REGISTER) == 0));
  }
}
```




### Auxiliary Polynomials 

In this subsection we explain the ``plookup polynomials'', i.e., polynomials 
that will be involved in at least one plookup check. For the binary state
machine, these can be divided into:


- **Independent**: These are plookup polynomials that do not depend on the any 
of the rest. They are $\mathtt{PA}, \mathtt{PB}, \mathtt{PCIN}, \mathtt{PLAST}$ 
and $\mathtt{POP}$. 

- **Dependent**: These are plookup polynomials that depend on at least one of 
the independent ones. In other words, a dependent polynomial is a polynomial 
that is tied to a particular opcode. They are $\mathtt{PC}, \mathtt{PCOUT}$
and $\mathtt{PUSECARRY}$. 




#### Independent Polynomials

Let's begin with $\mathtt{PA}$ and $\mathtt{PB}$. Since all the operations are 
performed at byte-level, $\mathtt{PA}$ and $\mathtt{PB}$ are polynomials 
that encode all possible combinations between two bytes. In total we have 
$2^8 \cdot 2^8 = 2^{16}$ possible combinations. The idea to 
generate all possible combinations is to fix one byte and change the other byte 
sequentially until having all combinations for the fixed byte. The next table 
shows this idea, where the first element correspond to the values of polynomial
$\mathtt{PA}$ and the second to the values of polynomial $\mathtt{PB}$.

$$
\begin{array}{|cccccc|}
\hline
(0, 0) & (1, 0) & (2, 0) & (3, 0) & \dots & (255, 0) \\
(0, 1) & (1, 1) & (2, 1) & (3, 1) & \dots & (255, 1) \\
(0, 2) & (1, 2) & (2, 2) & (3, 2) & \dots & (255, 2) \\
(0, 3) & (1, 3) & (2, 3) & (3, 3) & \dots & (255, 3) \\
\vdots& \vdots & \vdots & \vdots & \ddots & \vdots \\
(0, 255) & (1, 255) & (2, 255) & (3, 255) & \dots & (255, 255) \\
\hline
\end{array}
$$

Following the previous table, a bird-view of the values generated by 
$\mathtt{PA}$ and $\mathtt{PB}$ can be seen in the following table.

$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\mathtt{STEP} & 1 & 2 & \dots & 2^8 & 1 \cdot 2^8+1 & 1 \cdot 2^8+2 & \dots & 2 \cdot 2^8 & \dots & (2^8 - 1) \cdot 2^{8} + 1 & \dots & 2^8 \cdot 2^{8} \\ \hline
\mathtt{PA} & 0 & 0 & \dots & 0 & 1 & 1 & \dots & 1 & \dots & 255 & \dots & 255 \\ \hline
\mathtt{PB} & 0 & 1 & \dots & 255 & 0 & 1 & \dots & 255 & \dots & 0 & \dots & 255 \\ \hline
\end{array}
$$

We can generate $\mathtt{PA}$ and $\mathtt{PB}$ with the following code:

```javascript 
buildP_A(pols.P_A, REG_SIZE, N);
buildP_B(pols.P_B, REG_SIZE, N);

function buildP_A(pol, size, N) {
  for (let i = 0; i < N; i += size * size) {
    let value = 0;
    for (let j = 0; j < size; j++) {
      for (let k = 0; k < size; k++) {
        pol.push(BigInt(value));
      }
      value++;
    }
  }
}

function buildP_B(pol, size, N) {
  for (let i = 0; i < N; i = i + size * size) {
    for (let j = 0; j < size; j++) {
      let value = 0;
      for (let k = 0; k < size; k++) {
        pol.push(BigInt(value));
        value++;
      }
    }
  }
}
```

Next we have $\mathtt{PCIN}$. This polynomial is in charge of the input carry of
the operations. The nature of our operations restrict the input carry (also the 
output carry) to be $0$ or $1$. Therefore, $\mathtt{PCIN}$ handles this two 
possible cases. Since we have $2^{16}$ values from the previous polynomials and 
we should generate all possible combinations of them within a boolean register, 
we get a total length of $2 \cdot 2^{16} = 2^{17}$. The first $2^{16}$ steps 
will handle the case where $\mathtt{PCIN}$ is equal to $0$ and from step 
$2^{16} + 1$ to step $2^{17}$ will handle the case where $\mathtt{PCIN}$ is 
equal to $1$. A bird-view of the values generated by $\mathtt{PCIN}$ can be 
seen in the following table.

$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\mathtt{STEP} & 1 & 2 & \dots & 2^{16} & 1 \cdot 2^{16}+1 & 1 \cdot 2^{16}+2 & \dots & 2 \cdot 2^{16} \\ \hline
\mathtt{PCIN} & 0 & 0 & \dots & 0 & 1 & 1 & \dots & 1 \\ \hline
\end{array}
$$



The code that generates $\mathtt{PCIN}$ is the following:

```javascript
buildP_P_CIN(pols.P_CIN, CIN_SIZE, REG_SIZE * REG_SIZE, N);

function buildP_P_CIN(pol, pol_size, accumulated_size, N) {
  for (let i = 0; i < N; i += accumulated_size * pol_size) {
    let value = 0;
    for (let j = 0; j < pol_size; j++) {
      for (let k = 0; k < accumulated_size; k++) {
        pol.push(BigInt(value));
      }
      value++;
    }
  }
}
```

<!-- TODO: Need to explain PLAST more carefully -->



Next, we have $\mathtt{POP}$; which simply outputs all the possible opcodes in 
the machine. As we have $8$ operations, $\mathtt{POP}$ should output numbers in 
the set $\{0,1,2,3,4,5,6,7\}$. Combining all possible opcodes with our previous 
$2^{18}$ possible $4$-tuples 
$(\mathtt{PA}, \mathtt{PB}, \mathtt{PCIN}, \mathtt{PLAST})$, we get a total of 
$8 \cdot 2^{18} = 2^{21}$ possible combinations. We will do it in a natural 
way, increasing the $\mathtt{POP}$ value from $0$ to $7$. Hence, a bird-view of 
the values generated by $\mathtt{POP}$ can be seen in the following table:




$$
\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|c|c|}
\hline
\mathtt{STEP} & 1 & 2 & \dots & 2^{18} & 1 \cdot 2^{18}+1 & 1 \cdot 2^{18}+2 & \dots & 2 \cdot 2^{18} & \dots & 7\cdot2^{18} + 1 & \dots & 8 \cdot 2^{18} \\ \hline
\mathtt{OP} & 0 & 0 & \dots & 0 & 1 & 1 & \dots & 1 & \dots & 7 & \dots & 7 \\ \hline
\end{array}
$$

The code that generates $\mathtt{POP}$ is the following:
 
```javascript
buildP_OPCODE(pols.P_OPCODE, REG_SIZE * REG_SIZE * CIN_SIZE * P_LAST_SIZE, N);

function buildP_OPCODE(pol, current_size, N) {
  let value = 0;
  for (let i = 0; i < N; i = i + current_size) {
    for (let i = 0; i < current_size; i++) {
      pol.push(BigInt(value));
    }
    value++;
  }
}
```





#### Dependent Polynomials

After computing the previous preprocessed polynomials, we can proceed to the 
computation of the dependent ones: $\mathtt{PC}$, $\mathtt{PCOUT}$ and 
$\mathtt{PUSECARRY}$. Recall that these polynomials change mainly depending 
on the opcode of the operation. Therefore, we will do the discussion opcode 
by opcode, rather than polynomial by polynomial.

Let us start with addition. We use the carry strategy that we have described in
Section [Addition](#addition). The values of the polynomials $\mathtt{PC}$, 
$\mathtt{PCOUT}$ and $\mathtt{PUSECARRY}$ that are generated by $\mathtt{ADD}$ 
can be seen in Figure \ref{tab:DP-ADD}. Henceforth, we can generate 
$\mathtt{PC}$ and $\mathtt{PCOUT}$ using the following piece of code (observe 
that $\mathtt{PUSECARRY}$ is not used by $\mathtt{ADD}$, so we keep it at $0$):

```javascript
for (let i = 0; i < N; i++) {
    let sum = pol_cin[i] + pol_a[i] + pol_b[i];
    pol_c.push(sum & 255n);
    pol_cout(sum >> 8n);
    pol_use_carry.push(0n);
}
```

Observe that we avoid to invoke if-statements for all cases using logical
operators. The $\mathtt{sum \ \& \ 255}$ operation actually extracts the 
part of the sum that does not exceed the byte-length meanwhile 
$\mathtt{sum >> 8n}$ is actually extracting exceeding part i.e. the carry. 




For the subtraction operation we follow the strategy explained in Section 
[Subtraction](#subtraction). The values of the polynomials 
$\mathtt{PC}, \mathtt{PCOUT}$ and $\mathtt{PUSECARRY}$ that are generated 
by $\mathtt{SUB}$ can be seen in Figure \ref{tab:DP-SUB}. Henceforth, we 
can generate $\mathtt{PC}$ and $\mathtt{PCOUT}$ using the following piece 
of code (observe that $\mathtt{PUSECARRY}$ is also not used in 
$\mathtt{SUB}$, so we keep it at $0$):

```javascript
for (let i = 0; i < N; i++) {
    if (pol_a[i] - pol_cin[i] >= pol_b[i]) {
        pol_c.push(pol_a[i] - pol_cin[i] - pol_b[i]);
        pol_cout.push(0n);
    } else {
        pol_c.push(255n - pol_b[i] + pol_a[i] - pol_cin[i] + 1n);
        pol_cout.push(1n);
    }
    pol_use_carry.push(0n);
}
```



Let's jump now to the comparison operations. In all the opcodes of this part 
($\mathtt{LT}$, $\mathtt{SLT}$ and $\mathtt{EQ}$), the polynomial 
$\mathtt{PUSECARRY}$ becomes an important part of the process, so is not fixed 
to be $0$ as in the previous part.

We start  with $\mathtt{LT}$, in which we follow the same discussion as in 
Section [LT](#less-than). The values of the polynomials $\mathtt{PC}$, 
$\mathtt{PCOUT}$ and $\mathtt{PUSECARRY}$ that are generated by $\mathtt{LT}$ 
can be sen in Figure \ref{tab:DP-LT}. The following piece of code compute the
polynomials $\mathtt{PC}$, $\mathtt{PCOUT}$ and $\mathtt{PUSECARRY}$:


```javascript
for (let i = 0; i < N; i++) {
    if (pol_a[i] < pol_b[i]) {
        pol_cout.push(1n);
        pol_last[i] ? pol_c.push(1n) : pol_c.push(0n);
    } else if (pol_a[i] == pol_b[i]) {
        pol_cout.push(pol_cin[i]);
        pol_last[i] ? pol_c.push(pol_cin[i]) : pol_c.push(0n);
    } else {
        pol_cout.push(0n);
        pol_c.push(0n);
    }
    pol_last[i] ? pol_use_carry.push(1n) : pol_use_carry.push(0n);
}
```





For $\mathtt{SLT}$, we follow the same discussion as in Section 
[SLT](#signed-less-than). The values of the polynomials 
$\mathtt{PC}$, $\mathtt{PCOUT}$ and $\mathtt{PUSECARRY}$ that are generated by 
$\mathtt{SLT}$ can be sen in Figure \ref{tab:DP-SLT}. The following piece 
of code compute the polynomials $\mathtt{PC}$, $\mathtt{PCOUT}$ and
$\mathtt{PUSECARRY}$:

```javascript
for (let i = 0; i < N; i++) {
    if (!pol_last[i]) {
        if (pol_a[i] < pol_b[i]) {
            pol_cout.push(1n);
            pol_c.push(0n);
        } else if (pol_a[i] == pol_b[i]) {
            pol_cout.push(pol_cin[i]);
            pol_c.push(0n);
        } else {
            pol_cout.push(0n);
            pol_c.push(0n);
        }
    } else {
        let sig_a = pol_a[i] >> 7n;
        let sig_b = pol_b[i] >> 7n;
        // A Negative ; B Positive
        if (sig_a > sig_b) {
            pol_cout.push(1n);
            pol_c.push(1n);
        // A Positive ; B Negative
        } else if (sig_a < sig_b) {
            pol_cout.push(0n);
            pol_c.push(0n);
        // A and B equals
        } else {
            if (pol_a[i] < pol_b[i]) {
                pol_cout.push(1n);
                pol_c.push(1n);
            } else if (pol_a[i] == pol_b[i]) {
                pol_cout.push(pol_cin[i]);
                pol_c.push(pol_cin[i]);
            } else {
                pol_cout.push(0n);
                pol_c.push(0n);
            }
        }
    }
    pol_last[i] ? pol_use_carry.push(1n) : pol_use_carry.push(0n);
}
```

It's important to remark here that the $\mathtt{>>}$ operator is used to obtain
the sign of $\mathtt{A}$ and $\mathtt{B}$ accordingly and then a case analysis 
is performed over the signs to compute the polynomials.



The last comparison operation is $\mathtt{EQ}$, in which again we follow the 
same discussion as in Section [EQ](#equality). The values of the polynomials 
$\mathtt{PC}$, $\mathtt{PCOUT}$ and $\mathtt{USECARRY}$ that are generated by 
$\mathtt{EQ}$ can be sen in Figure \ref{tab:DP-EQ}. The following piece of code 
compute the polynomials $\mathtt{PC}$, $\mathtt{PCOUT}$ and $\mathtt{USECARRY}$:

```javascript
for (let i = 0; i < N; i++) {
    if (pol_a[i] == pol_b[i] && pol_cin[i] == 1n) {
        pol_cout.push(1n);
        pol_last[i] ? pol_c.push(1n) : pol_c.push(0n);
    } else {
        pol_cout.push(0n);
        pol_c.push(0n)
    }
    pol_last[i] ? pol_use_carry.push(1n) : pol_use_carry.push(0n);
}
```



Finally, we have the logical bit-wise operations. They are the easiest ones to 
describe, since they don't care about neither $\mathtt{PCOUT}$ nor 
$\mathtt{USECARRY}$. The values of the polynomials $\mathtt{PC}$, 
$\mathtt{PCOUT}$ and $\mathtt{USECARRY}$ that are generated by $\mathtt{AND}$, 
$\mathtt{OR}$ and $\mathtt{XOR}$ can be sen in 
Figures \ref{tab:DP-AND}, \ref{tab:DP-OR} and \ref{tab:DP-XOR}, respectively. 
The following pieces of code compute the polynomial $\mathtt{PC}$:

```javascript
// AND
for (let i = 0; i < N; i++) {
    pol_c.push(pol_a[i] & pol_b[i]);
    pol_cout.push(0n);
    pol_use_carry.push(0n);
}
```

```javascript
// OR
for (let i = 0; i < N; i++) {
    pol_c.push(pol_a[i] | pol_b[i]);
    pol_cout.push(0n);
    pol_use_carry.push(0n);
}
```

```javascript
// XOR
for (let i = 0; i < N; i++) {
    pol_c.push(pol_a[i] ^ pol_b[i]);
    pol_cout.push(0n);
    pol_use_carry.push(0n);
}
```

Here, the javascript operators $\mathtt{\&, \mid, \text{^}}$ represent and 
perform the logical operator that we want to apply. We have the following 
equivalence with our notation:

$$
\mathtt{\&} = \land = \mathtt{AND}, \quad \mid = \lor = \mathtt{OR}, \quad \mathtt{\text{^}} = \oplus = \mathtt{XOR}.
$$



## Constraints


This section is devoted to explain the set of constraints that restrict the 
behavior of the committed polynomials to be aligned with the binary state 
machines. We do not claim that our set of constraint is the optimal one to
represent binary operations. It could be the case that a distinct 
representation of the binary state machine could led to a more optimal set of 
constraints. We however are able claim that ours is not overconstraint, since 
we have divided the set constraints in a logical and complete manner.



###  Values Are of Correct Form

Let's start with some basic constraints:

$$
\begin{align}
\mathtt{opcode}' \cdot \left(1 - \mathtt{RESET}'\right) &= \mathtt{opcode} \cdot \left(1 - \mathtt{RESET}'\right), \\
\mathtt{cIn}' \cdot \left(1 - \mathtt{RESET}'\right) &= \mathtt{cOut} \cdot \left(1 - \mathtt{RESET}'\right).
\end{align}
$$

The previous constraints deal with the behavior os some particular polynomial 
within the same cycle. While the first constrain asserts that the opcode 
does not change, the second constrain asserts that the output carry from a
previous computation is equal to the input carry to the actual computation. 
This is the behavior that is expected from $\mathtt{opcode}$, $\mathtt{cIn}$ and
$\mathtt{cOut}$, apart from its correctness.



Next we have the "big plookup". This plookup is in charge of checking that
committed polynomials are well-formed. 

$$
\left(
\begin{array}{c}
\mathtt{freeInA}, \mathtt{freeInB}, \mathtt{cIn}, \mathtt{last}, \mathtt{opcode}, \\ \mathtt{freeInC}, \mathtt{cOut}, \mathtt{useCarry}.
\end{array}
\right) 
\subset
\left(
\begin{array}{c}
\mathtt{PA}, \mathtt{PB}, \mathtt{PCIN}, \mathtt{PLAST}, \mathtt{POP}, \\ \mathtt{PC}, \mathtt{PCOUT}, \mathtt{PUSECARRY}.
\end{array}
\right) 
$$


There are two kinds of checks that have to be performed to be able to say that 
the committed polynomials are of well form: 

- **Type**: This check takes care of the type of the polynomials. So, for 
instance, as we expect that $\mathtt{freeInA}$ is a byte, then its type check 
will verify that the values from $\mathtt{freeInA}$ are inside the set 
$[0, 2^8)$.

- **Feasibility**: This check takes care of the relations between polynomials. 
So, for instance, if $\mathtt{opcode} = 4$ (i.e. an equality operation) the 
feasibility check should detect that 
$(\mathtt{freeInA}, \mathtt{freeInB}, \mathtt{freeInC}) = (0,1,1)$ is not
correct.


Let's analyze if the previous plookup satisfies both the type and 
feasibility checks for all the polynomials involved within it. Type checks 
come "for free", since the polynomials in the right hand side of 
the plookup are of the claimed form. Hence, if we would introduce a 
value into $\mathtt{freeInA}$ not from the set $[0, 2^8)$, then use of the 
Schwartz-Zippel lemma within the plookup protocol would detect it.

A similar (but more sophisticated) approach has been followed to ensure 
feasibility checks. Here, as have been explained during Section 
***PLOOKUP POLYNOMIALS***, we construct the preprocessed polynomials in a way that 
the computational trace representing the values of such polynomials only display 
feasible cases. The complexity here resides in the construction of such 
polynomials, which has been carefully explained during Section 
***PLOOKUP POLYNOMIALS***.


### Updating Registers Accordingly

Let's continue with the behavior of the input and output registers:

$$
\begin{align}
\mathtt{A}'[0..7] &=  \mathtt{A}[0..7] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInA} \cdot \mathtt{FACTOR}[0..7], \\
\mathtt{B}'[0..7] &=  \mathtt{B}[0..7] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInB} \cdot \mathtt{FACTOR}[0..7].
\end{align}
$$

First, we have the input registers $\mathtt{A}$ and $\mathtt{B}$. Through this
subsection, we will use the acronym $\mathtt{satps}$ to denote "same as the 
previous step". This acronym is useful for describing the evolution of the 
input/output registers, since they are build in a constructive manner. So for 
instance, if we have a function $f(X)$ such that $f(x)' = f(x) + 1$ and 
$f(0) = 21$, then $f(1) = \mathtt{satps} + 1 = 21 + 1 = 22$, 
$f(2) = \mathtt{satps} + 1 = 22 + 1 = 23$, and so on.

According to the definition of $\mathtt{FACTOR}$, register $\mathtt{A}$ is 
updated during a cycle as depicted in the following table:

$$
\begin{array}{|c|c|c|c|}
\hline
\mathtt{A}[0] & \mathtt{A}[1] & \dots & \mathtt{A}[7] \\ \hline
\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\mathtt{satps} + 2^8\cdot\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\mathtt{satps} + 2^{16}\cdot\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\mathtt{satps} + 2^{24}\cdot\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\mathtt{satps} & \mathtt{freeInA} & \dots & 0  \\ \hline
\mathtt{satps} & \mathtt{satps} + 2^8\cdot\mathtt{freeInA} & \dots & 0  \\ \hline
\mathtt{satps} & \mathtt{satps} + 2^{16}\cdot\mathtt{freeInA} & \dots & 0  \\ \hline
\mathtt{satps} & \mathtt{satps} + 2^{24}\cdot\mathtt{freeInA} & \dots & 0  \\ \hline
\vdots & \vdots & \vdots & \vdots  \\ \hline
\mathtt{satps} & \mathtt{satps} & \dots & \mathtt{freeInA}  \\ \hline
\mathtt{satps} & \mathtt{satps} & \dots & \mathtt{satps} + 2^{8}\cdot\mathtt{freeInA}  \\ \hline
\mathtt{satps} & \mathtt{satps} & \dots & \mathtt{satps} + 2^{16}\cdot\mathtt{freeInA}  \\ \hline
\mathtt{satps} & \mathtt{satps} & \dots & \mathtt{satps} + 2^{24}\cdot\mathtt{freeInA}  \\ \hline\hline
\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\mathtt{satps} + 2^8\cdot\mathtt{freeInA} & 0 & \dots & 0  \\ \hline
\vdots & \vdots & \vdots & \vdots  \\ \hline
\end{array}
$$


As it can be seen, bytes are introduce into register $\mathtt{A}$
in an increment manner: the four first bytes go into $\mathtt{A}[0]$ in the 
first four steps, the next four bytes go to $\mathtt{A}[1]$, and so on until the
last four bytes go into $\mathtt{A}[7]$. This action consume $32$ steps of
computation that corresponds to the $32$ bytes that can fit into the $256$-bits 
register. At the same time that bytes are introduced into $\mathtt{A}$, the exact 
same process happens with register $\mathtt{B}$. Therefore, after $32$ steps we have fully
filled both register $\mathtt{A}$ and $\mathtt{B}$ correctly.




Register $\mathtt{C}$ has a different representation depending on the opcode. 
While $\mathtt{C}$ is a $256$-bit value for some operations (e.g., 
$\mathtt{ADD}$ or $\mathtt{AND}$), in some cases it is restricted to be a bit 
(true or false). For example, when the operation of interest is a comparison
(e.g., $\mathtt{SLT}$), the byte decomposition of $\mathtt{C}$ in this case 
consists on zeros except the least significant one, which is $\mathtt{0x00}$ or 
$\mathtt{0x01}$. Due to the latter case, we should add a constraint 
differentiating between the these two possible scenarios. In fact, this is the 
main reason of why we introduce the $\mathtt{useCarry}$ polynomial.

First, we define an auxiliary polynomial $\mathtt{cTempF}$:

$$
\begin{align*}
\mathtt{cTempF} :&= \mathtt{C}[0] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInC} \cdot \mathtt{FACTOR}[0].
\end{align*}
$$

Then we use this polynomial to constraint $\mathtt{C}[0]$:

$$
\begin{align}
\mathtt{C}[0]' &= \mathtt{useCarry} \cdot \left(\mathtt{cOut} - \mathtt{cTempF}\right) + \mathtt{cTempF}.
\end{align}
$$

Let's use case analysis to see how $\mathtt{cTempF}$ and the constraint
reflects what we have explained in the previous paragraph.


- If $\mathtt{useCarry} = 0$, then 
$\mathtt{C}[0] = \mathtt{C}[0] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInC} \cdot \mathtt{FACTOR}[0]$, which is equivalent to say that $\mathtt{C}[0]$ has the same behavior as $\mathtt{A}[0]$ or 
$\mathtt{B}[0]$. This case occurs whenever the operation of interest is not a 
comparison operation.

- If $\mathtt{useCarry} = 1$, then $\mathtt{C}[0]' = \mathtt{cOut}$. This case 
happens whenever the operation of interest is a $\mathtt{LT}$, $\mathtt{SLT}$
or an $\mathtt{EQ}$.

Following the previous discussion, the behavior of $\mathtt{C}[1..6]$ is
analogous to $\mathtt{A}[1..6]$ and hence we must have that:

$$
\mathtt{C}'[1..6] =  \mathtt{C}[1..6] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInC} \cdot \mathtt{FACTOR}[1..6].
$$


Finally, as it will be explained in Section [Executor](#executor), we will need to 
enforce $\mathtt{C}[7]$ to be $0$ at the ending of a cycle. This is to avoid 
$\mathtt{freeInC}$ charging a $1$ into $\mathtt{C}$, since the executor need to 
represent the bit of $\mathtt{C}$ in big-endian instead of little-endian.

So, similar to what we have done with $\mathtt{C}[0]$, we define another 
auxiliary polynomial $\mathtt{cTempS}$ and use it to constraint $\mathtt{C}[7]$:

$$
\begin{align}
\mathtt{cTempS} :&= \mathtt{C}[7] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInC} \cdot \mathtt{FACTOR}[7], \nonumber \\
\mathtt{C}[7]' &= \left(1 - \mathtt{useCarry}\right) \cdot \mathtt{cTempS}. \label{eq:c7update}
\end{align}
$$

As it can be seen, the previous constraint enforces that  

$$
\mathtt{C}[7]' = 0
$$

or 

$$\mathtt{C}[7]' = \mathtt{C}[7] \cdot \left(1 - \mathtt{RESET}\right) + \mathtt{freeInC} \cdot \mathtt{FACTOR}[7].
$$






## The Executor


### The Initialization

The executor first obtains the upper bound $N$ on the number of rows that the 
computation trace can contain from any of the involved polynomials.

```javascript
const N = Number(polsDef.freeInA.polDeg);
```

The polynomial obtained by interpolation the values of columns are therefore of 
degree lower than $N$.

Each element of the input has the form 

```javascript
{"a": a_hex, "b": b_hex, "c": c_hex, "opcode": opcode}
```

where $\mathtt{a_{hex}}, \mathtt{b_{hex}}$ and $\mathtt{c_{hex}}$ are $256$-bits
integers in hexadecimal which presumably satisfy

$$
\mathtt{a\_hex} \star \mathtt{b\_hex} = \mathtt{c\_hex}
$$

for a correct operation $\star$ which is described by $\mathtt{opcode}$. First 
of all, the input get split into chunks of bytes in little-endian from, to be 
ready to be charged via free inputs:

```javascript
prepareInput256bits(input, N);

function prepareInput256bits(input, N) {
  // Porcess all the inputs
  for (let i = 0; i < input.length; i++) {
    // Get all the keys and split them with padding
    for (var key of Object.keys(input[i])) {
      input[i][`${key}_bytes`] = hexToBytes(
        input[i][key].toString(16).padStart(64, "0")
      );
    }
  }
  function hexToBytes(hex) {
    for (var bytes = [], c = 64 - 2; c >= 0; c -= 2)
      bytes.push(BigInt(parseInt(hex.substr(c, 2), 16) || 0n));
    return bytes;
  }
}
```

After transforming the input appropriately, all the committed polynomials get 
initialized to $0$:



```javascript
for (var i = 0; i < N; i++) {
    for (let j = 0; j < REGISTERS_NUM; j++) {
        pols[`a${j}`].push(0n);
        pols[`b${j}`].push(0n);
        pols[`c${j}`].push(0n);
    }
    pols.last.push(0n);
    pols.opcode.push(0n);
    pols.freeInA.push(0n);
    pols.freeInB.push(0n);
    pols.freeInC.push(0n);
    pols.cIn.push(0n);
    pols.cOut.push(0n);
    pols.lCout.push(0n);
    pols.lOpcode.push(0n);
    pols.useCarry.push(0n);
}
```



Finally, we build the constant $\mathtt{FACTOR}$ and $\mathtt{RESET}$ 
polynomials:

```javascript
let FACTOR = [[], [], [], [], [], [], [], []];
let RESET = [];
buildFACTORS(FACTOR, N);
buildRESET(RESET, N);
```




### Processing the Inputs

First, we get the $\mathtt{opcode}$, $\mathtt{freeInA}$, $\mathtt{freeInB}$ 
and $\mathtt{freeInC}$ polynomials from the input:



```javascript
for (var i = 0; i < input.length; i++) {
  for (var j = 0; j < LATCH_SIZE; j++) {
    pols.opcode[i * LATCH_SIZE + j] = BigInt("0x" + input[i].opcode)
    pols.freeInA[i * LATCH_SIZE + j] = BigInt(input[i]["a_bytes"][j])
    pols.freeInB[i * LATCH_SIZE + j] = BigInt(input[i]["b_bytes"][j])
    pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][j])
    
    // -- code --
  }
}
```


At this moment, $\mathtt{LATCH\_SIZE}$ is set to $32$, therefore every $32$ steps 
the previous polynomials get fed again with totally new and independent field 
values. We will refer to these $32$ steps as the **cycles** of the 
computation.

We also need to check whenever we are in the last step of the cycle, and if so, update the $\mathtt{last}$ polynomial accordingly:
```javascript
// -- code --

if (j == LATCH_SIZE - 1) {
    pols.last[i * LATCH_SIZE + j] = BigInt(1n)
} else {
    pols.last[i * LATCH_SIZE + j] = BigInt(0n)
}

// -- code --
```


The following processes will be opcode dependent. That means that we will now 
see a branching that updates the corresponding polynomials depending on the 
type of operation (i.e., the opcode) that we are being carrying on. 

Let's break it down opcode by opcode, following the strategies that we have
described at section [Operating At Byte-Level](#operating-at-byte-level).


#### ADD

```javascript
// -- code --

switch (BigInt("0x" + input[i].opcode)) {
// ADD   (OPCODE = 0)
case 0n:
  let sum = input[i]["a_bytes"][j] + input[i]["b_bytes"][j]
  pols.cOut[i * LATCH_SIZE + j] = BigInt(sum >> 8n);
  break;
  
// -- code --
```


As it can be seen, the only polynomial that gets updated through the 
$\mathtt{ADD}$ branch is $\mathtt{cOut}$. As it is natural, the carry of the 
sum between registers $\mathtt{A}$ and $\mathtt{B}$ gets fed into 
$\mathtt{cOut}$ if it exists. Otherwise, it gets a $0$.




#### SUB

```javascript
// -- code --

// SUB   (OPCODE = 1)
case 1n:
  if (input[i]["a_bytes"][j] - pols.cIn[i * LATCH_SIZE + j] >= input[i]["b_bytes"][j]) {
    pols.cOut[i * LATCH_SIZE + j] = 0n;
  } else {
    pols.cOut[i * LATCH_SIZE + j] = 1n;
  }
  break;
  
// -- code --
```

The $\mathtt{SUB}$ operation is a little bit more tricky than the $\mathtt{ADD}$
operation, because we have to take care if the first operand is greater than the
second one and modify the carry accordingly, as explained in Section 
[Subtraction](#subtraction). In particular, if 
$\mathtt{A} - \mathtt{cIn} \geq \mathtt{B}$, then the subtraction
can be performed properly. However, if 
$\mathtt{A} - \mathtt{cIn} < \mathtt{B}$ then the result of the
subtraction is a number lower than $0$ and we indicating by pushing a $1$ to
$\mathtt{cOut}$.




#### LT

<!-- TODO: Change the code to the last version. Explainations are already done.  -->

```javascript
// -- code --

// LT    (OPCODE = 2)
case 2n:
  if (RESET[i * LATCH_SIZE + j]) {
    pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][LATCH_SIZE - 1]);
  }
  if ((input[i]["a_bytes"][j] < input[i]["b_bytes"][j])) {
    cout = 1n;
  } else if (input[i]["a_bytes"][j] == input[i]["b_bytes"][j]) {
    cout = pols.cIn[i * LATCH_SIZE + j];
  } else {
    cout = 0n;
  }
  pols.cOut[i * LATCH_SIZE + j] = cout;
  if (pols.last[i * LATCH_SIZE + j] == 1n) {
    pols.useCarry[i * LATCH_SIZE + j] = 1n
    pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][0])
  } else {
    pols.useCarry[i * LATCH_SIZE + j] = 0n;
  }
  break;
  
// -- code --
```



Recall that $\mathtt{LT}$ is a comparator, so the output of the operation is 
boolean. Moreover, we will only know the correct output at the end of the 
operation, after processing all bytes. This introduces a problem, since the 
way we are entering the bytes as free inputs positions the less significant
bytes first, but we can not verify anything at this point because only one 
byte is processed. The strategy that we will follow is to swap the first 
and the last byte of $\mathtt{freeInC}$. Hence, at the very last step of 
computation we will enforce the last byte of $\mathtt{C}$ to be $0$ and 
the first byte of $\mathtt{C}$ to be the result of the operation, stored in 
the last $\mathtt{cOut}$. We will see the correct update of $\mathtt{C}[0]$ and
$\mathtt{C}[7]$ later on. Henceforth, we only change the $\mathtt{freeInC}$
polynomial when either $\mathtt{last}$ or $\mathtt{reset}$ is $1$. This is the
main reason to introduce the $\mathtt{useCarry}$ register in order to take 
care of the last step only for the comparators and not the other operations. 
That is, $\mathtt{useCarry}$ is $1$ if and only if $\mathtt{last} = 1$ and 
$\mathtt{opcode} \in \{2, 3, 4\}$.  The algorithm is the same as the algorithm 
described in [Less Than](#less-than).





#### SLT

```javascript
// -- code --

// LT    (OPCODE = 2)
case 2n:
    if (pols.last[i * LATCH_SIZE + j]) {
        pols.useCarry[i * LATCH_SIZE + j] = 1n;
    } else {
        pols.useCarry[i * LATCH_SIZE + j] = 0n;
    }
    if (RESET[i * LATCH_SIZE + j]) {
        pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][LATCH_SIZE - 1]);
    }
    if (pols.last[i * LATCH_SIZE + j]) {
        let sig_a = input[i]["a_bytes"][j] >> 7n;
        let sig_b = input[i]["b_bytes"][j] >> 7n;
        // A Negative ; B Positive
        if (sig_a > sig_b) {
            cout = 1n;
        // A Positive ; B Negative
        } else if (sig_a < sig_b) {
            cout = 0n;
        // A and B equals
        } else {
            if ((input[i]["a_bytes"][j] < input[i]["b_bytes"][j])) {
                cout = 1n;
            } else if (input[i]["a_bytes"][j] == input[i]["b_bytes"][j]) {
                cout = pols.cIn[i * LATCH_SIZE + j];
            } else {
                cout = 0n;
            }
        }
        pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][0])
    } else {
        if ((input[i]["a_bytes"][j] < input[i]["b_bytes"][j])) {
            cout = 1n;
        } else if (input[i]["a_bytes"][j] == input[i]["b_bytes"][j]) {
            cout = pols.cIn[i * LATCH_SIZE + j];
        } else {
            cout = 0n;
        }
    }
    pols.cOut[i * LATCH_SIZE + j] = cout;
    break;

// -- code --
```




This operation conserves all the properties described in the last $\mathtt{LT}$
operation but now following the algorithm described in Section 
[Signed Less Than](#signed-less-than) instead. It is worth noting that

```javascript
let sig_a = input[i]["a_bytes"][j] >> 7n;
```

is actually computing the correct sign of $a$ if we are processing the last 
byte, since we are shifting $7$ bits to the right and capturing the most 
significant byte. 






#### EQ

```javascript
// -- code --

// EQ    (OPCODE = 4)
case 4n:
  if (RESET[i * LATCH_SIZE + j]) {
    pols.cIn[i * LATCH_SIZE + j] = 1n
    pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][LATCH_SIZE - 1]); 
  }
  
  if (
    input[i]["a_bytes"][j] == input[i]["b_bytes"][j] &&
    pols.cIn[i * LATCH_SIZE + j] == 1
  ) {
    cout = 1n;
  } else {
    cout = 0n;
  }
  pols.cOut[i * LATCH_SIZE + j] = cout;
  
  if (pols.last[i * LATCH_SIZE + j] == 1n) {
    pols.useCarry[i * LATCH_SIZE + j] = 1n
    pols.freeInC[i * LATCH_SIZE + j] = BigInt(input[i]["c_bytes"][0]) 
  } else {
    pols.useCarry[i * LATCH_SIZE + j] = 0n;
  }
  break;
  
// -- code --
```



This operation conserves all the properties described in the $\mathtt{LT}$
operation but now following the algorithm described in Section 
[Equality](#equality) instead. There are several things that are worth to 
notice. First of all, observe that the first carry is set to $1$, following the 
convention that the carry $1$ if and only if we have not found any difference 
between all the previously processed bytes of $a$ and $b$. Recall that this is 
strictly necessary for the correct execution of the previously described
algorithm.   





#### Default Operation 

```javascript
// -- code --

default:
  pols.cIn[i * LATCH_SIZE + j] = 0n;
  pols.cOut[i * LATCH_SIZE + j] = 0n;
  break;
}

// -- code --
```

Finally, if there is not at operation at all, then naturally the $\mathtt{cIn}$
and $\mathtt{cOut}$ polynomial are set to $0$.

After this branching, let's process all the edge cases and the remaining
 polynomials. 


```javascript
if (RESET[(i * LATCH_SIZE + j + 1) % N]) {
  pols.cIn[(i * LATCH_SIZE + j + 1) % N] = 0n;
} else {
  pols.cIn[(i * LATCH_SIZE + j + 1) % N] = pols.cOut[i * LATCH_SIZE + j]
}
pols.lCout[(i * LATCH_SIZE + j + 1) % N] = pols.cOut[i * LATCH_SIZE + j]
pols.lOpcode[(i * LATCH_SIZE + j + 1) % N] = pols.opcode[i * LATCH_SIZE + j]
```


This is simply saying that if we jump to another cycle, then the very first
input carry should be $0$, as we completely change the input values. Otherwise,
the input carry for the following step should be equal to the output carry of
the previous step. Moreover, we define the polynomials $\mathtt{lCout}$ and
$\mathtt{lOpcode}$ to be the polynomials $\mathtt{cOut}$ and 
$\mathtt{opcode}$, respectively, but shifted to the right by one position.


Next, polynomials $\mathtt{A}$, $\mathtt{B}$ and $\mathtt{C}$ get updated
accordingly:

```javascript
pols[`a0`][(i * LATCH_SIZE + j + 1) % N] = 
    pols[`a0`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
    + pols.freeInA[(i * LATCH_SIZE + j) % N] * FACTOR[0][(i * LATCH_SIZE + j) % N]
    
pols[`b0`][(i * LATCH_SIZE + j + 1) % N] = 
    pols[`b0`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
    + pols.freeInB[(i * LATCH_SIZE + j) % N] * FACTOR[0][(i * LATCH_SIZE + j) % N];

c0Temp[(i * LATCH_SIZE + j) % N] = 
    pols[`c0`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
    + pols.freeInC[(i * LATCH_SIZE + j) % N] * FACTOR[0][(i * LATCH_SIZE + j) % N];
    
pols[`c0`][(i * LATCH_SIZE + j + 1) % N] = 
    pols.useCarry[(i * LATCH_SIZE + j) % N] * (pols.cOut[(i * LATCH_SIZE + j) % N] 
    - c0Temp[(i * LATCH_SIZE + j) % N]) + c0Temp[(i * LATCH_SIZE + j) % N];

for (let k = 1; k < REGISTERS_NUM; k++) {

  pols[`a${k}`][(i * LATCH_SIZE + j + 1) % N] = 
    pols[`a${k}`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
    + pols.freeInA[(i * LATCH_SIZE + j) % N] * FACTOR[k][(i * LATCH_SIZE + j) % N];
    
  pols[`b${k}`][(i * LATCH_SIZE + j + 1) % N] = 
    pols[`b${k}`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
    + pols.freeInB[(i * LATCH_SIZE + j) % N] * FACTOR[k][(i * LATCH_SIZE + j) % N];
    
  if (pols.last[i * LATCH_SIZE + j] && pols.useCarry[i * LATCH_SIZE + j]) {
    pols[`c${k}`][(i * LATCH_SIZE + j + 1) % N] = 0n
  } else {
    pols[`c${k}`][(i * LATCH_SIZE + j + 1) % N] = 
        pols[`c${k}`][(i * LATCH_SIZE + j) % N] * (1n - RESET[(i * LATCH_SIZE + j) % N]) 
        + pols.freeInC[(i * LATCH_SIZE + j) % N] * FACTOR[k][(i * LATCH_SIZE + j) % N];
  }
}
```


Observe that the way we update $\mathtt{C}[0]$ coincides with the strategy we 
have followed to swap the last and the first byte of $\mathtt{freeInC}$ in the
comparators and leave the rest at $0$, in order to address the $1$-bit 
$\mathtt{C}$ case.

Finally, we fill the remaining "holes":

```javascript
for (var i = input.length * LATCH_SIZE; i < N; i++) {
  if (i % 10000 === 0) console.log(`Computing final binary pols ${i}/${N}`);
  pols[`a0`][(i + 1) % N] = pols[`a0`][i] * (1n - RESET[i]) + pols.freeInA[i] * FACTOR[0][i];
  pols[`b0`][(i + 1) % N] = pols[`b0`][i] * (1n - RESET[i]) + pols.freeInB[i] * FACTOR[0][i];

  c0Temp[i] = pols[`c0`][i] * (1n - RESET[i]) + pols.freeInC[i] * FACTOR[0][i];
  pols[`c0`][(i + 1) % N] = pols.useCarry[i] * (pols.cOut[i] - c0Temp[i]) + c0Temp[i];

  for (let j = 1; j < REGISTERS_NUM; j++) {
  
      pols[`a${j}`][(i + 1) % N] = 
        pols[`a${j}`][i] * (1n - RESET[i]) + pols.freeInA[i] * FACTOR[j][i];
        
      pols[`b${j}`][(i + 1) % N] = 
        pols[`b${j}`][i] * (1n - RESET[i]) + pols.freeInB[i] * FACTOR[j][i];
        
      pols[`c${j}`][(i + 1) % N] = 
        pols[`c${j}`][i] * (1n - RESET[i]) + pols.freeInC[i] * FACTOR[j][i];
  }
}
```



## Connecting the Binary and the Main State Machines

The polynomials $\mathtt{lCout}$ and $\mathtt{lOpcode}$ are used for the connection between the binary and the main state machine.

$$
\begin{align}
\mathtt{lCout}' &= \mathtt{cOut}, \\
\mathtt{lOpcode}' &= \mathtt{opcode}.
\end{align}
$$
