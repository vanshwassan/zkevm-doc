
# The Norm-Gate9 State Machine



As it is the case with most secondary and auxiliary state machines in the zkProver, the $\texttt{Norm}\texttt{-Gate9}$ State Machine has an executor to compute the normalised $\mathtt{XOR}$ operation and a PIL code containing verification rules for checking its computations.





## The Norm-Gate9 Executor



The executor builds the constant polynomials and the committed polynomials of minimum degree $\mathtt{2^{21}}$.

Let $\mathtt{X}$ be an $\mathtt{N}$-bit field element, where $\mathtt{N = 2^{63}}$. It can be split into its $\mathtt{2^{21}}$ factors as follows,
$$
\mathtt{ X = X_0 * 2^0 + X_1 * 2^{21} + X_2 * 2^{42}}
$$
where each
$$
\mathtt{X_j} = \sum_{i=1}^6({\eta_i}*2^i) + \mathbf{a_1}*2^{7} +  \sum_{i=1}^6({\eta_{i+7}}*2^{i+7}) + \mathbf{a_2}*2^{14} +  \sum_{i=1}^6({\eta_{i+14}}*2^{i+14}) + \mathbf{a_3}*2^{21}
$$
is a $\mathtt{21}$-bit number, $\mathtt{j \in \{ 0, 1, 2 \}}$ and each $\mathtt{\eta_{i+\alpha}}$ is some carry bit.



The $\texttt{Norm}\texttt{-Gate9}$ [executor](https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/src/sm/sm_norm_gate9.js) is implemented as a circuit with logic gates for normal $\mathtt{XOR}$'s and a normalised $\mathtt{XOR}$ operation (denoted by $\mathtt{XORN}$). That is, either
$$
\mathtt{a\ XOR\ b = c}\ \ \text{ or }\ \ \mathtt{a\ XORN\ b = \big(a\ XOR\ 0b000000100000010000001 \big) \& b = c}
$$
depending on whether the $\mathtt{XOR}$ is iterated for the sixth time or not. A constant polynomial called $\mathtt{Gate9Type[i]}$ where $\mathtt{i \in \{ 0, 1, 2, \dots , 6 \}}$, is used to determine when $\mathtt{op = XOR}$ or $\mathtt{op = XORN}$.

As explained in the $\texttt{Nine}\texttt{-2One}$ State Machine document, and now illustrated in Figure 3 below, the $\texttt{Norm}\texttt{-Gate9}$ State Machine takes $\mathtt{N}$-bit field elements as inputs (using here $\mathtt{N} = 64$), 
$$
\text{0b0}\mathtt{\eta\eta\eta\eta\eta\eta} \text{X}_1\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_2\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_3\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_4\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_5\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_6\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_7\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_8\mathtt{\eta\eta\eta\eta\eta\eta}\text{X}_9
\text{ }
$$
in order to clear the accumulated carry bits, and outputs
$$
\text{0b0000000X}_1\text{000000X}_2\text{000000X}_3\text{000000X}_4\text{000000X}_5\text{000000}\text{X}_6\text{000000X}_7\text{000000X}_8\text{000000X}_9.
\text{ }
$$




![Figure 3: The Normalising XOR Operation](/Users/anthonymatlala/Documents/Blockchain-and-DLTs/Polygon-Hermez-docs/State-Machines-Docs/Keccak-related-SMs/figures/norm-gate-9-xorn.png)

<div align="center"><b> Figure 1: The Normalising XOR Operation per 64-bit Field Element </b></div>





### The Norm-Gate9 PIL Code



The aim is to build a set of verification rules for proving correctness of execution in the form of a PIL code.



```pil
// norm_gate9.pil @(https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/pil/~)

namespace NormGate9(%N);

    pol constant Value3, Value3Norm;   // Normalization table
    pol constant Gate9Type, Gate9A, Gate9B, Gate9C; // AndN table
    pol constant Latch;   // 0,0,0,1,0,0,1,0,0,1,....
    pol constant Factor;  // 1, 1<<21, 1<<42, 1, 1<<21, 1<<42, ..... 1 << 42, 0, 0

    pol commit freeA, freeB;
    pol commit gateType;     // 0=XOR, 1=ANDN

    (gateType' - gateType)*(1 - Latch) = 0;

    pol commit freeANorm, freeBNorm, freeCNorm;

    { freeA , freeANorm } in { Value3, Value3Norm };
    { freeB , freeBNorm } in { Value3, Value3Norm };
    { gateType, freeANorm, freeBNorm, freeCNorm } in { Gate9Type, Gate9A, Gate9B, Gate9C};
    pol commit a, b, c;

    pol latch_a = a + Factor*freeA;
    pol latch_b = b + Factor*freeB;
    pol latch_c = c + Factor*freeCNorm;

    a' = latch_a * (1-Latch);
    b' = latch_b * (1-Latch);
    c' = latch_c * (1-Latch);
```







### Connection With Keccak-f



The values computed by the $\texttt{Norm}\texttt{-Gate9}$ SM executor are connected back to the Keccak-f circuit as shown in the PIL code below.



```pil
// keccakf.pil @(https://github.com/0xPolygonHermez/zkevm-proverjs/blob/main/pil/~)

include "global.pil";
include "norm_gate9.pil";


namespace KeccakF(%N);

    pol constant ConnA, ConnB, ConnC, NormalizedGate, GateType;
    pol commit a,b,c;

    {a, b, c} connect {ConnA, ConnB, ConnC};

    (1-NormalizedGate)*(a+b-c) = 0;

    NormalizedGate { GateType, a, b, c } in NormGate9.Latch { NormGate9.gateType, NormGate9.latch_a, NormGate9.latch_b, NormGate9.latch_c } ;

    Global.L1 * a = 0;
    Global.L1 * (72624976668147841-b) = 0;
```





