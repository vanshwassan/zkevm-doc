


Designing a simple zero-knowledge cryptographic tool or app can involve a lot of intricacies. Consider now, how complex it is to develop a zkEVM. It is a huge and complex project.

In this document we breakdown the complexities of the Polygon zkEVM's design in terms of a simplified example, a Fibonacci State Machine. The aim is to illustrate, in a generic sense, how the state machine approach has been implemented to realise the Polygon zkEVM.





## Fibonacci State Machine



Consider constructing a membership cryptographic tool, which determines whether a given number $\beta$ is a member of the Fibonacci sequence or not. The tool must be cryptographically secure, needs to preserve privacy, and should be designed in terms of a state machine.



### The Fibonacci Sequence

The Fibonacci sequence  $\mathbf{a_1, a_2, \dots , a_n}$  has the property that the sum of every two consecutive members $\mathbf{a_{i-1}}$ and $\mathbf{a_i}$ gives the value of the next member $\mathbf{a_{i+1}}$. That is,  $\mathbf{ a_{i+1} = a_{i-1} + a_i }$. 

Here are the first twelve members of the sequence;

$$
\mathbf{ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, \dots}
$$
It is easy to check whether  $\mathbf{377}$  and  $\mathbf{987}$  are members of the Fibonacci sequence. But to do the same with $\mathbf{ 12,586,269,025 }$, one clearly needs a formula or a computer program. The task here is a state machine crypto tool to achieve this.





### The Fibonacci State Machine

Consider a state machine with registries $\mathbf{A} = ( A_1, A_2, \dots , A_l )$ and  $\mathbf{B} = ( B_1, B_ 2, \dots , B_l )$, so that the i-th state is the pair $\big( A_i , B_i \big)$.  Such a state machine is a **Fibonacci state machine** if indeed the registry values conform to the format of the Fibonnacci sequence. See the picture below, with the initial conditions  $A_1 = 0$  and  $B_1 = 1$. 



![Figure 2 : Fibonacci State Machine - Three Registries](figures/fibonacci-sequence.pdf.png)

<div align="center"><b> Figure 1 : Fibonacci State Machine - Two Registries </b></div>



Since the two registries contain the Fibonacci sequence, except that $\mathbf{B}$ is one step ahead of $\mathbf{A}$, they are related as follows,


$$
\begin{aligned} 
A_{i+1} &= B_i , \\ 
B_{i+1} &= A_i + B_i.
\end{aligned}
$$


The idea here is to express the registries as polynomials and ultimately employ a polynomial commitment scheme in order to fully construct the membership crypto tool. 



#### Polynomial Identities

As it is the tradition in blockchains, the polynomials that represent the two registries are taken from the set of polynomials $\mathbb{Z}_p[x]$,  where the coefficients are elements of a prime field $\mathbb{Z}_p$. 

For this specific example, as shown in Figure 1 above, the polynomials are evaluated over the subgroup $H = \{\omega,\omega^2,\omega^3,\dots,\omega^8 = 1\} = \langle\omega\rangle$ of order $8$. 

Define two polynomials $P(x)$ and $Q(x)$ such that 
$$
P(\omega^i) = A_i, \\
Q(\omega^i) = B_i.
$$

Since every $x$ in $H$ is of the form $x = \omega^i$ for some $i$, we have

$$
\begin{aligned}
P(x\omega) &=  P(\omega^{i + 1})  =  A_{i+1},\\
Q(x\omega) &= Q(\omega^{i+1})  =  B_{i+1}.
\end{aligned}
$$


But substituting the relations, $A_{i+1} = B_i$ and $B_{i+1} = A_i + B_i$, results in the following identities,


$$
\begin{aligned}
P(x\omega) &= A_{i+1} = B_i = Q(\omega^i) = \bigg\lvert_H Q(x),\\ 
Q(x\omega) &= B_{i+1} = A_i + B_i  = P(\omega^i) + Q(\omega^i) = \bigg\lvert_H P(x) + Q(x).
\end{aligned}
$$



That is, 


$$
\begin{aligned}
P(x\omega) &= \bigg\lvert_H  Q(x),\\
Q(x\omega) &= \bigg\lvert_H  P(x) + Q(x).
\end{aligned}
$$






#### Non-cyclic Polynomial Identities Problem

If these polynomial identities accurately express the two registries, then every member of the Fibonacci sequence should satisfy them. 

Note that the definition of $H$ does not restrict the values of $i$ to be less or equal to $8$. Even if we set $i = 27$, the element  $\omega^{27}$  is in $H$ because  $\omega^{27} = w^8 \cdot \omega^8 \cdot \omega^8 \cdot \omega^3 = 1 \cdot 1 \cdot 1 \cdot \omega^3 = \omega^3$.

However, the unrestricted value of  $i$  presents problems with the above polynomial identities. 

For example, let us test if the polynomial identities hold for all values of  $i$ . We let  $x = \omega^8$  and use the registry values given in Figure 1.

- For the first identity we get, 

$$
\begin{aligned}
&P(x \omega) = P(\omega^8 \cdot \omega)  =   P(\omega^1)  =  A_1 = 0,\ \ \text{but}\\
&Q(x) = Q(w^8) = B_8 = 21 \not= 0.
\end{aligned}
$$

- Similarly, for the second identity, we get,

$$
\begin{aligned}
&Q(x \omega) = Q(\omega) = B_1 = 1\\
&P(x) = P(\omega^8) + Q(\omega^8) = 21 + 13 = 34 \not= 1.
\end{aligned}
$$

This means the polynomial identities are not aligned with the registries of the Fibonacci state machine because although $H$ is cyclic, the identities are not. 

We therefore need some error-correcting polynomial $R(x)$ which makes the polynomial identities cyclic. Such a polynomial must also be in $\mathbb{Z}_p[x]$.



#### Correcting Errors In Polynomial Identities

We first modify our Fibonacci state machine by adding a third registry $\mathbf{C} = ( C_1, C_2, \dots , C_l)$. Set the registry values to  $\mathbf{C} = ( 1, 0, 0, \dots , 0)$. So the Fibonacci state machine is now as depicted in Figure 2 below.



![Figure 2 : Fibonacci State Machine - Three Registries](figures/fibonacci-sequence-aux.pdf.png)

<div align="center"><b> Figure 2 : Fibonacci State Machine - Three Registries </b></div>



The corresponding polynomial $R(x)$ is defined as follows, 
$$
R(\omega^i) = C_i.
$$

That is, 


$$
\begin{aligned}
R(\omega^i) &= C_i = 1, \text{ if }\ \ i \mod 8 = 1 , \\
R(\omega^i) &= C_i = 0, \text{ otherwise}.
\end{aligned}
$$



The polynomial $R(x)$ is incorporated into the previous polynomial identities as follows,

$$
\begin{aligned}
P(x \omega) &= \bigg\lvert_H Q(x) \big( 1 - R(x \omega) \big),\\
Q(x \omega) &= \bigg\lvert_H \big( P(x) + Q(x) \big) \big( 1 - R(x \omega) \big) + R(x \omega)
\end{aligned}
$$



Let us test if these new polynomial identities are cyclic, by again using  $x = \omega^8$. 

- For the first identity we have 

$$
\begin{aligned}
LHS &= P(x \omega) = P(\omega^8 \cdot \omega) = P(\omega^1) = A_1 = 0,\\
RHS &= Q(x) \big( 1 - R(x \omega) \big) = Q(\omega^8) \big( 1 - R(\omega^8 \cdot \omega) \big) = A_8 \big( 1 - R(\omega) \big) = 13 \big( 1 - 1 \big) = 0.
\end{aligned}
$$





So the first identity holds true for  $x = \omega^8$,  and it is easy to check that it holds true for all other values of  $x$  in  $H$.

- For the second identity we have


$$
\begin{aligned}
LHS &= Q(x\omega) = Q(\omega^8 \cdot \omega) = Q(\omega^1) = B_1 = 1,\\ \\
RHS &= \big(P(\omega^8) + Q(\omega^8) \big) \big( 1 - R(\omega^8 \cdot \omega) \big) + R(\omega^8 \cdot \omega)\\ 
&= \big( A_8 + B_8 \big) \big( 1 - R(\omega^1) \big) + R(\omega^1)\\
&= \big( 13 + 21 \big) \big( 1 - 1 \big) + 1 = 1.
\end{aligned}
$$

The second identity also holds true for $x = \omega^8$, and it is readily verifiable that it holds true for all other values of $x$ in $H$.





#### Varied Initial Conditions

Note that instead of being restricted to the given initial conditions $\big( A_1 , B_1 \big) = \big( 0 , 1 \big)$,  the Fibonacci state machine together with its polynomial identities can be easily adjusted to any other initial conditions  $\big( A_1 , B_1 \big)$ as follows; 



$$
\begin{aligned} 
P(x \omega) &= \bigg\lvert_H Q(x) \big( 1 - R(x \omega) \big) + A_1 R(x \omega),\\
Q(x \omega) &= \bigg\lvert_H \big( P(x) + Q(x) \big) \big( 1 - R(x \omega) \big) + B_1 R(x \omega) .
\end{aligned}
$$





## Proving Our State Machine (High Level)



The previous polynomial relations can be efficiently proven via **polynomial commitments** such as [Kate](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf) and [FRI-based](https://drops.dagstuhl.de/opus/volltexte/2018/9018/pdf/LIPIcs-ICALP-2018-14.pdf).




![Figure 3 : Polynomial Commitment Scheme](figures/fibo-polnml-commit.pdf.png)

<div align="center"><b> Figure 3 : Polynomial Commitment Scheme </b></div>




Commitment schemes are binding and hiding:

  1. **Binding**: The prover can not change the polynomial he or she committed to.
  1. **Hiding**: The verifier cannot deduce which polynomial the prover committed to, by merely looking at the commitment.

