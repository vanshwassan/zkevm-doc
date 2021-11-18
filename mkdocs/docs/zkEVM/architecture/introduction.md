Introduction
============

First Example: The Fibonacci Sequence

0.3

![image](fibonacci-sequence){width="\textwidth"}

0.7

-   We can build the Fibonacci state machine with two registries: $A$
    and $B$.

-   Then, we have the following relations between the states of these
    registries: $$\begin{aligned}
    A_{i+1} &= B_i, \\
    B_{i+1} &= A_i + B_i,\end{aligned}$$ for $i \in [5]$.

-   Now, represent these states as polynomials evaluated on the group
    $H = \{\omega, \omega^2, \omega^3, \omega^4, \omega^5 = 1\}$:
    $$\begin{aligned}
    A(\omega^i) &= A_i \quad \Longrightarrow \quad A = [0, 1, 1, 2, 3] \\
    B(\omega^i) &= B_i \quad \Longrightarrow \quad B = [1, 1, 2, 3, 5]\end{aligned}$$
    for $i \in [5]$.

0.3

![image](fibonacci-sequence){width="\textwidth"}

0.7

-   We can now translate the previous relations to the polynomial
    setting: $$\begin{aligned}
    A(x\omega) &=  B(x), \\
    B(x\omega) &=  A(x) + B(x).\end{aligned}$$

-   However, this is not completely correct, since when we evaluate in
    $\omega^5$ we obtain: $$\begin{aligned}
    A(\omega^6) = A(\omega) = 0 &\neq  5 = B(\omega^5), \\
    B(\omega^6) = B(\omega) = 1 &\neq  8 = A(\omega^5) + B(\omega^5).\end{aligned}$$

-   Let's add an auxiliary registry $C$ to solve this problem.

-   To create simple polynomial identities that can can be described as
    relations between successive points in H, we will make the state
    machine cyclic, that is, to start again in (0,1).

0.4

![image](fibonacci-sequence-aux){width="\textwidth"}

0.6

-   Similarly to $A$ and $B$, represent the state $C$ as a polynomial
    evaluated on $H$: $$\begin{aligned}
    C(\omega^i) &= C_i \quad \forall i \in [5] \quad \Longrightarrow \quad C = [1, 0, 0, 0, 0].\end{aligned}$$

-   With this auxiliary state, we can now fix the polynomial identities
    as follows: $$\begin{aligned}
    A(x\omega) &=  B(x)(1 - C(x\omega)), \\
    B(x\omega) &=  (A(x) + B(x))(1 - C(x\omega)) + C(x\omega).\end{aligned}$$

    Notice that now, when $x = w^5$:

    $A(Xw) = A(w^6) \neq B(X)$ ; $A(Xw) = A(w^6) = 0$.

    $B(Xw) = B(w^6) \neq A(X)+B(X)$ ; $B(Xw) = B(w^6) = 1$.

Starting from the Basics: Move State Machine

![image](main-state-machine-simplified){width="80%"}

-   We have used the following notation:

    a)  **inX**: $1$ or $0$ depending if the state $X_i$ is included in
        the sum or not.

    b)  **op**: The resulting operation between the included states.

    c)  **setX**: $1$ or $0$ depending if one state (or a combination or
        more) will be moved into $X_{i+1}$.

-   The relations between the states of the registries can be expressed
    as follows: $$\begin{aligned}
    \op_i &= A_i \cdot \inp A_i + B_i \cdot \inp B_i + C_i \cdot \inp C_i + D_i \cdot \inp D_i + E_i \cdot \inp E_i, \\
    A_{i+1} &= \set A_i \cdot (\op_i - A_i) + A_i, \\
    B_{i+1} &= \set B_i \cdot (\op_i - B_i) + B_i, \\
    C_{i+1} &= \set C_i \cdot (\op_i - C_i) + C_i, \\
    D_{i+1} &= \set D_i \cdot (\op_i - D_i) + D_i, \\
    E_{i+1} &= \set E_i \cdot (\op_i - E_i) + E_i.\end{aligned}$$

How to Encode the Move State Machine

-   Let's assume that we want to perform the following instructions:
    $$\begin{aligned}
    \mathbf{MOV}~B, A \quad \mathbf{MOV}~C, D \quad \mathbf{MOV}~A, D \quad \mathbf{MOV}~E,B.\end{aligned}$$

$$%\begin{array}{|c|}
%\hline
%\mathbf{Inst.~Name} \\ \hline
%MOV \quad B, A \\ \hline
%MOV \quad C, D \\ \hline
%MOV \quad A, D \\ \hline
%MOV \quad E, B \\ \hline
%\end{array}
%\hspace{0.1cm}
\begin{array}{|c|}
\hline
\mathbf{Position} \\ \hline
0 \\ \hline
1 \\ \hline
2 \\ \hline
3 \\ \hline
\end{array}
\hspace{0.1cm}
\begin{array}{|c|c|c|c|c|c|c|c|c|c|}
\hline
\inp A & \inp B & \inp C & \inp D & \inp E & \set A & \set B & \set C & \set D & \set E \\ \hline
1 & 0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\ \hline
0 & 0 & 0 & 1 & 0 & 0 & 0 & 1 & 0 & 0 \\ \hline
0 & 0 & 0 & 1 & 0 & 1 & 0 & 0 & 0 & 0 \\ \hline
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 \\ \hline
\end{array}
\hspace{0.1cm}
\begin{array}{|c|}
\hline
\mathbf{Inst.~Value} \\ \hline
0x41 \\ \hline
0x88 \\ \hline
0x28 \\ \hline
0x202 \\ \hline
\end{array}$$

-   We code the instruction value as follows:
    $$\mathsf{inst} = ~\inp A + 2 \cdot \inp B + 2^2 \cdot \inp C + 2^3 \cdot \inp D + 2^4 \cdot \inp E + 2^5 \cdot \set A + 2^6 \cdot \set B + 2^7 \cdot \set C + 2^8 \cdot \set D + 2^9 \cdot \set E.$$

-   We can write the previous table values as the following polynomial
    identity: $$\begin{aligned}
    \mathsf{inst}(x) = &~\inp A(x) + 2 \cdot \inp B(x) + 2^2 \cdot \inp C(x) + 2^3 \cdot \inp D(x) + 2^4 \cdot \inp E(x) \\
    & + 2^5 \cdot \set A(x) + 2^6 \cdot \set B(x) + 2^7 \cdot \set C(x) + 2^8 \cdot \set D(x) + 2^9 \cdot \set E(x).\end{aligned}$$

-   Now, to build a program, every instruction will be uniquely
    identified by its value and the position in which it is executed.

-   We define the polynomial $rom(x)$ which consists on an instruction
    value concatenated with the position: $$\begin{array}{|c|c|c|c|}
    \hline
    \mathbf{Position} & \mathbf{Instruction} & \mathbf{Inst.~Value} & \mathbf{Rom} = \mathbf{inst} + 2^{16} \cdot \mathbf{position} \\ \hline
    0 & \mathbf{MOV} \quad B, A & 0x0041 & 0x00041 \\ \hline
    1 & \mathbf{MOV} \quad C, D & 0x0088 & 0x10088 \\ \hline
    2 & \mathbf{MOV} \quad A, D & 0x0028 & 0x20028 \\ \hline
    3 & \mathbf{MOV} \quad E, B & 0x0202 & 0x30202 \\ \hline
    \end{array}$$
