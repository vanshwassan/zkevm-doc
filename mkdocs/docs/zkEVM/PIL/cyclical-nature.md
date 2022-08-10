# Cyclic Nature of State Machines

There is one implicit complexity in the design of state machines:

$$
\textbf{State machines should have a cyclical nature.}
$$

This means that the description (in terms of constraints) of a state machine is not correct if the appropriate constraints are not satisfied in every row transition. In particular, this should remain true in the transition from the last row to the first row. This is an important aspect that has to be taken care of while designing the set of constraints of a state machine.

![Cyclic Nature of State Machines](figures/fig10-cycl-ntr-sms.png)

<div align="center"><b> Figure 10: Cyclic Nature of State Machines </b></div>
<br>
If there is some constraint that is not satisfied in the last transition, one normally overcomes this problem by adding artificial values in the later evaluations of polynomials.

For example, consider the following state machine with its respective computational trace:

![State Machine Example](figures/fig11-sm-eg-cmpt-trc.png)

<div align="center"><b> Code Excerpt 13: State Machine Example </b></div>
<br>
Clearly, the constraint $b' = b+a$ is not satisfied in the last transition: $(a,b) = (1,2)$ to $(a,b) = (1,1)$.

This can be solved by appending two extra rows. Figure 11 shows how this can be performed in the context of the previous example.

![Inducing a Cyclic Nature](figures/fig11-indc-cycl-ntr.png)

<div align="center"><b> Figure 11: Inducing a Cyclic Nature </b></div>
<br>
Another option would be the introduction of a selector:
<br>

![State Machine Example](figures/fig12-sel-eg-cyclc-sm.png)

<div align="center"><b> Code Excerpt 14: State Machine Example </b></div>
<br>
As it can be seen in the code excerpt above, the cost of adding extra rows has been substituted by the addition of the selector $\texttt{SEL}$.

A third option (wherever possible) is to take the advantage of some existing selectors to accommodate the later values.
