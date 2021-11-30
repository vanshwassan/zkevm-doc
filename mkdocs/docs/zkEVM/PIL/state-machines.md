## Byte 4

This state machine is able to build any number of 4 bytes (32 bits).

Example for building numbers: 0x0307, 0x4405, 0x5069 and 0x0893.

|            | SET | freeIN | out  | out' |
| ---------- | --- | ------ | ---- | ---- |
| $\omega^0$ | 1   | 3      | 0    | 3    |
| $\omega^1$ | 0   | 7      | 3    | 0307 |
| $\omega^2$ | 1   | 44     | 0307 | 44   |
| $\omega^3$ | 0   | 5      | 44   | 4405 |
| $\omega^4$ | 1   | 50     | 4405 | 50   |
| $\omega^5$ | 0   | 69     | 50   | 5069 |
| $\omega^6$ | 1   | 8      | 5069 | 8    |
| $\omega^7$ | 0   | 93     | 8    | 0893 |

The polynomial identity between the elements of this table is:

$$
\textsf{out}'(x) = \textsf{SET}(x) * \textsf{freeIN}(x) + (1 - \textsf{SET}(x)) * (\textsf{out}(x) * 2^{16} + \textsf{freeIN}(x)).
$$

We write this polynomial identity in the PIL language as:

```
pol constant BYTE2;   // All the numbers between 0x00 and 0xFF

namespace byte4;
    /////// Constant Polynomials
    pol bool constant SET;    // 1, 0, 1, 0, 1, 0 ...

    /////// State Polynomials
    pol u32 commited freeIN;
    pol u32 commited out;

    freeIN in GLOBAL.BYTE2;

    out' = SET*freeIN +
           (1-SET)*(out * 2**16 + freeIN);
```

## Main
