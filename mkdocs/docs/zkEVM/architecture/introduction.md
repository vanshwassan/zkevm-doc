# Introduction

## First Example: The Fibonacci State Machine

![Fibonacci Sequence](figures/fibonacci-sequence.pdf.png)

- We can build the Fibonacci state machine with two registries, $A$ and $B$.

- In the Fibonacci sequence, we have the following relations between the states of these registries:

\begin{aligned}
A_{i+1} &= B_i, \\
B_{i+1} &= A_i + B_i.
\end{aligned}

- Let's represent the states of these registries for four steps as polynomials in $\mathbb{Z}_p[x]$ evaluated on the group $H = \{\omega, \omega^2, \omega^3, \omega^4 = 1\}$:

\begin{aligned}
A(\omega^i) &= A_i \quad \Longrightarrow \quad A = [0, 1, 1, 2] \\
B(\omega^i) &= B_i \quad \Longrightarrow \quad B = [1, 1, 2, 3]
\end{aligned}

- The relations between the states of registries are translated into relations (A.K.A identities) in the polynomial setting:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H B(x), \\
B(x\omega) &= \bigg\lvert_H A(x) + B(x).
\end{aligned}

- However, the previous identities do not correctly and uniquely describe our sequence because:

    1.  The equations are not cyclic: When we evaluate the identities at $\omega^4$:

    \begin{aligned}
    A(\omega^5) = A(\omega) = 0 &\neq 3 = B(\omega^4), \\
    B(\omega^5) = B(\omega) = 1 &\neq 5 = A(\omega^4) + B(\omega^4).
    \end{aligned}

    2.  Other initial conditions also fulfill the identities, e.g: $(2,3),(3,5),(5,8),(8,13)$.

![Fibonacci Sequence](figures/fibonacci-sequence-aux.pdf.png)

- Let's add an auxiliary registry $C$ to solve these problems.

- The corresponding polynomial is:

\begin{aligned}
C(\omega^i) &= C_i \quad \Longrightarrow \quad C = [1, 0, 0, 0].
\end{aligned}

- With this auxiliary registry, we can now fix the polynomial identities as follows:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H B(x)(1 - C(x\omega)), \\
B(x\omega) &= \bigg\lvert_H (A(x) + B(x))(1 - C(x\omega)) + C(x\omega).
\end{aligned}

$C(x)$ is publicly known (A.K.A **pre-processed** or **constant**).

- Note that now at $x = w^4$ the identities are satisfied:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H B(x)(1 - C(x\omega)), \\
B(x\omega) &= \bigg\lvert_H (A(x) + B(x))(1 - C(x\omega)) + C(x\omega), \\
A(\omega^4 \omega) &= A(\omega^5) = A(\omega) = 0, \\
B(\omega^4 \omega) &= B(\omega^5) = B(\omega) = 1.
\end{aligned}

- We can also use other initial conditions $(A_0, B_0)$:

\begin{aligned}
A(x\omega) &= \bigg\lvert_H B(x)(1 - C(x\omega))+ A_0C(x\omega), \\
B(x\omega) &= \bigg\lvert_H (A(x) + B(x))(1 - C(x\omega)) + B_0 C(x\omega).
\end{aligned}

## Proving our State Machine (High Level)

\begin{aligned}
p_1(x)&= A(x\omega) - B(x)(1 - C(x\omega)) - A_0C(x\omega) = \bigg\lvert_H 0,\\
p_2(x) &= B(x\omega) - (A(x) + B(x))(1 - C(x\omega)) - B_0 C(x\omega) = \bigg\lvert_H 0.
\end{aligned}

- We are going to convert these H-ranged identities into $\mathbb{F}$-ranged identities that is valid for any $x \in \mathbb{F}$.

- To do so, we are going to use the **zero polynomial** $Z_H(x)$.

- $Z_H(x)$ is computed as the polynomial that is zero in $H$:

  $$
  (\omega,0), (\omega^2,0), (\omega^3,0), (\omega^4,0) \, \Longrightarrow \, Z_H(x) = (x-\omega)(x-\omega^2)(x-\omega^3)(x-\omega^4) = x^4-1.
  $$

- Notice that $p_1(x)$ and $p_2(x)$ have roots at $H$.

- That means $Z_H(x) | p_1(x)$ and $Z_H(x) | p_2(x)$ because $(x-\omega)$, $(x-\omega^2)$, etc. are monomials of $p_1(x)$ and $p_2(x)$.

- Now we can compute $d_1(x) = p_1(x) / Z_H(x)$ and $d_2(x) = p_2(x) / Z_H(x)$.

- The identities that need to be checked are $p_1(x) - d_1(x)Z_H(x) = 0$ and $p_2(x) - d_2(x)Z_H(x) = 0$ for any $x \in \mathbb{F}$.

![Fibonacci Sequence](figures/proving-fibonacci.pdf.png)
