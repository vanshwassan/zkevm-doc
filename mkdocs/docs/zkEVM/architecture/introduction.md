## First Example: The Fibonacci State Machine

![Fibonacci Sequence](figures/fibonacci-sequence.pdf.png)

We can build the Fibonacci state machine with two registries, $A$ and $B$. In the Fibonacci sequence, we have the following relations between the states of these registries:

\begin{aligned}
A_{i+1} &= B_i, \\
B_{i+1} &= A_i + B_i.
\end{aligned}

Let's represent the states of these registries as polynomials in $\mathbb{Z}_p[x]$ evaluated on the subgroup $H = \{\omega, \omega^2, \omega^3, \omega^4, \omega^5, \omega^6, \omega^7, \omega^8 = 1\}$:

\begin{aligned}
A(\omega^i) &= A_i \quad \Longrightarrow \quad A = [0, 1, 1, 2, 3, 5, 8, 13] \\
B(\omega^i) &= B_i \quad \Longrightarrow \quad B = [1, 1, 2, 3, 5, 8, 13, 21]
\end{aligned}

The relations between the states of registries are translated into identities in the polynomial setting:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H  B(x), \\
B(x\omega) &= \bigg\lvert_H  A(x) + B(x).
\end{aligned}

However, the previous identities do not correctly and uniquely describe our sequence because:

  1.  The registries are not cyclic: When we evaluate the identities at $\omega^8$:

    \begin{aligned}
    A(\omega^9) &= A(\omega) = 0 \neq  21 = B(\omega^8), \\
    B(\omega^9) &= B(\omega) = 1 \neq  34 = A(\omega^8) + B(\omega^8).
    \end{aligned}

  2.  We can use other initial conditions, for example $(2,4)$, that also fulfills the identities: $(2,4)\to(4,6)\to(6,10)\to(10,16)\to(16,26)\to(26,42)\to(42,68)\to(68,110).$

![Fibonacci Sequence Aux](figures/fibonacci-sequence-aux.pdf.png)

Let's add an auxiliary registry $C$ to solve these problems. The corresponding polynomial is:

\begin{aligned}
C(\omega^i) &= C_i \quad \Longrightarrow \quad C = [1, 0, 0, 0, 0, 0, 0, 0].
\end{aligned}

With this auxiliary registry, we can now fix the polynomial identities as follows:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H  B(x)(1 - C(x\omega)), \\
B(x\omega) &= \bigg\lvert_H (A(x) + B(x))(1 - C(x\omega)) + C(x\omega).
\end{aligned}

Note that now at $x = \omega^8$ the identities are satisfied:

\begin{aligned}
A(\omega^9) &= A(\omega) = 0 = B(\omega^8)(1 - C(\omega)), \\
B(\omega^9) &= B(\omega) = 1 = (A(\omega^8) + B(\omega^8))(1 - C(\omega)) + C(\omega).
\end{aligned}

We can also use other initial conditions $(A_0, B_0)$:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H  B(x)(1 - C(x\omega))+ A_0C(x\omega), \\
B(x\omega) &= \bigg\lvert_H  (A(x) + B(x))(1 - C(x\omega)) + B_0 C(x\omega).
\end{aligned}

## Proving our State Machine (High Level)

![Polynomial Commitment](figures/polynomial-commitment.pdf.png)

The previous polynomial relations can be efficiently proven through **polynomial commitments** such as [Kate](https://www.iacr.org/archive/asiacrypt2010/6477178/6477178.pdf) and [FRI-based](https://drops.dagstuhl.de/opus/volltexte/2018/9018/pdf/LIPIcs-ICALP-2018-14.pdf).

Commitment schemes are binding and hiding:

  1. **Binding**: The prover can not change the polynomial she committed to.
  1. **Hiding**: The verifier can not deduce which is the committed polynomial by only looking at the commitment.
