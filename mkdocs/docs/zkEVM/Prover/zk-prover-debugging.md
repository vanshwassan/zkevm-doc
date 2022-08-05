
<!-- https://hackmd.io/_ktX_wjcTua_Ios-o8QAnQ?both -->

# zkProver Debugging

## Repositories Used

- [zkproverjs](https://github.com/hermeznetwork/zkproverjs): Prover reference implementation writen in javascript.
- [zkproverc](https://github.com/hermeznetwork/zkproverc): Prover implementation written in C.
- [zkasm](https://github.com/hermeznetwork/zkasm): Compiles .zkasm to a .json ready for the zkproverjs.
- [zkpil](https://github.com/hermeznetwork/zkpil): Polynomial Identity Language.
- [zkvmpil](https://github.com/hermeznetwork/zkvmpil): PIL source code for the zkVM (state-machines).
- [zkrom](https://github.com/hermeznetwork/zkrom): zkASM source code of the zkEVM.
- [zkevmdoc](https://github.com/hermeznetwork/zkevmdoc): zkEVM documentation.

## Setup Environment

- Ideal repository structure:
```
github
    --> zkrom
    --> zkvmpil
    --> zkproverjs
```
- To run the `zkprover:executor`, run the following git commands:
```
git clone https://github.com/hermeznetwork/zkrom.git

cd zkrom

npm i && npm run build

cd ..

git clone https://github.com/hermeznetwork/zkvmpil.git

cd zkvmpil

npm i && npm run build

git clone https://github.com/hermeznetwork/zkproverjs.git

cd zkproverjs

npm i
```
- Detailed explanation:
  - Repository `zkrom`
    - `main/*`: Contains assembly code
    - `build`: Compiled assembly. Code ready for the Executor
  - Repository `zkvmpil`
    - `src`: state-machines
    - `build`: compiled state-machines. Code ready for the Executor 
  - Repository `zkproverjs`
    - `src/main_executor.js`: CLI to run Executor easily
      - Executor needs files generated from `zkrom/build` & `zkvm pil/build`
      - it also needs an `input.json`
      - Examples:
        - [zkrom file](https://github.com/hermeznetwork/zkrom/blob/main/build/rom.json)
        - [zkvmpil file](https://github.com/hermeznetwork/zkvmpil/blob/main/build/zkevm.pil.json)
        - [input file](https://github.com/hermeznetwork/zkproverjs/blob/main/testvectors/input.json)

- Run Executor (in `zkproverjs` repository). To only test the Executor, the output is not required.

```
node src/main_executor.js ./testvectors/input.json -r ../zkrom/build/rom.json -p ../zkvmpil/build/zkevm.pil.json -o ./testvectors/poly.bin
``` 
## Executor Insights
Basically, the Executor runs the program that is specified by the ROM.
The program can be seen in the `rom.json` file, which includes the debugging information.
Let us see an example of `assembly code` build into the `rom.json`:
```
ASSEMBLY: 1 => B
JSON FILE:
{
  "CONST": 1,
  "neg": 0,
  "setB": 1,
  "line": 51,
  "fileName": "../zkrom/main/main.zkasm"
 }
```
All operations are defined in the JSON file, plus `line` & `fileName` where the assembly code is. This JSON file is ready to be interpreted by the `executor`

## VSCode Debugging
In the `zkproverjs` repository, you can find an example of `launch.json` to debug the Executor code: https://github.com/hermeznetwork/zkproverjs/blob/main/.vscode/launch.json#L8

## Debugging Tips
- Main executor code to debug: https://github.com/hermeznetwork/zkproverjs/blob/main/src/executor.js#L12
- Variable `l` is the rom.json that is going to be executed: https://github.com/hermeznetwork/zkproverjs/blob/main/src/executor.js#L61
- Debug Helpers
  - [print registers](https://github.com/hermeznetwork/zkproverjs/blob/main/src/executor.js#L1030)
- By monitoring `ctx(context)`, registers, and `op`, you will see all the states changes made by the Executor.
- `ctx.input` contains all the variables loaded from `input.json`.
- `storage` makes reference to the Merkle tree.
- The transactions places at `input.json` are pre-processed and are stored on `ctx.pTxs`. Besides, `globalHash` is computed given all the `inputs.json` according to [`specifications`] <!--(TO_BE_UPDATED)]-->https://hackmd.io/tEny6MhSQaqPpu4ltUyC_w#validateBatch


## Table ROM Assembly Instructions

|   NAME    |     DESCRIPTION      |                                                                                 EXECUTION                                                                                  |
|:---------:|:--------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|   MLOAD   |     memory load      |                                                                               op = mem(addr)                                                                               |
|  MSTORE   |    memory storage    |                                                                               mem(addr) = op                                                                               |
|   SLOAD   |     storage load     |                              op = `storage.get(SR, H[A0 , A1 , A2 , B0 , C0 , C1 , C2 , C3, 0...0]))` where `storage.get(root, key) -> value`                              |
|  SSTORE   |    storage store     | op = `storage.set(SR, (H[A0 , A1 , A2 , B0 , C0 , C1 , C2 , C3, 0...0], D0 + D1 * 2^64 + D2 * 2^128 + D3 * 2^192 )` where `storage.set(oldRoot, key, newValue) -> newRoot` |
|   HASHW   |   hash write bytes   |                                                                        hash[addr].push(op[0..D-1])                                                                         |
|   HASHE   |       hash end       |                                                                              hash[addr].end()                                                                              |
|   HASHR   |      hash read       |                                                                           op = hash[addr].result                                             |
|   ARITH   | arithmetic operation |                                                                              AB + C = D OR op                                                                              |
|    SHL    |      shift left      |                                                                                op = A << D                                                                                 |
|    SHR    |     shift right      |                                                                                op = A >> D                                                                                 |
| ECRECOVER |  signature recover   |                                                                 op = ECRECOVER( A: HASH, B: R, C:S, D: V)                                                                  |
|  ASSERT   |      assertion       |                                                                                   A = op                                                                                   |

## Examples Assembly
### MSTORE
- Assembly
```javascript=
A                       :MSTORE(sequencerAddr)
```
- rom.json
```json=
{
  "inA": 1,
  "neg": 0,
  "offset": 4,
  "mWR": 1,
  "line": 9,
  "offsetLabel": "sequencerAddr",
  "useCTX": 0,
  "fileName": ".../zkrom/main/main.zkasm"
 }
```
- Description:
Load register `A` in `op` and write in memory position 4 (`offset`) the `op` value.

### MREAD
- Assembly:
```javascript=
$ => A          : MLOAD(pendingTxs)
```
- rom.json
```json=
{
  "freeInTag": {
   "op": ""
  },
  "inFREE": 1,
  "neg": 0,
  "setA": 1,
  "offset": 1,
  "mRD": 1,
  "line": 25,
  "offsetLabel": "pendingTxs",
  "useCTX": 0,
  "fileName": ".../zkrom/main/main.zkasm"
 }
```
- Description:
Load a memory value from position 1 (`offset`) into `op` (action marked by `inFREE`) and set `op` in register `A`.

### LOAD FROM STORAGE
- Assembly
```javascript=
$ => A                          :MLOAD(sequencerAddr)
0 => B,C
$ => A                          :SLOAD 
```
- rom.json
```json=
 {
  "freeInTag": {
   "op": ""
  },
  "inFREE": 1,
  "neg": 0,
  "setA": 1,
  "offset": 4,
  "mRD": 1,
  "line": 47,
  "offsetLabel": "sequencerAddr",
  "useCTX": 0,
  "fileName": ".../zkrom/main/main.zkasm"
 },
 {
  "CONST": 0,
  "neg": 0,
  "setB": 1,
  "setC": 1,
  "line": 48,
  "fileName": ".../zkrom/main/main.zkasm"
 },
 {
  "freeInTag": {
   "op": ""
  },
  "inFREE": 1,
  "neg": 0,
  "setA": 1,
  "sRD": 1,
  "line": 49,
  "fileName": ".../zkrom/main/main.zkasm"
 }
```
- Description
  - Load from memory position 5 (`sequencerAccValue`) into `op` and store `op` on register `D`.
  - Load from memory position 4 (`sequencerAddr`) into `op` and store `op` on register `A`.
  - Load CONST in `op` and store it in registers `B` and `C`.
  - Perform SLOAD (reading from Merkle tree) with the following key: `storage.get(SR, H[A0 , A1 , A2 , B0 , C0 , C1 , C2 , C3, 0...0]))`
    - `SR` is the current state-root saved in register `SR`.
    - `A0, A1, A2` carry the sequencer address.
    - `B0` is set to `0`, pointing out that the `balance` is going to be read.
    - `C0,C1,C2,C3` are set to 0 since they are not used when reading balance from 
    Merkle tree.
  - Merkle tree value is stored in `op` (marked with `inFREE` tag), set `op` to register `A`.

### WRITE TO STORAGE
- Assembly
```javascript=
$ => A                          :MLOAD(sequencerAddr)
0 => B,C
$ => SR                         :SSTORE
```
- rom.json
```json=
{
  "freeInTag": {
   "op": ""
  },
  "inFREE": 1,
  "neg": 0,
  "setA": 1,
  "offset": 4,
  "mRD": 1,
  "line": 56,
  "offsetLabel": "sequencerAddr",
  "useCTX": 0,
  "fileName": ".../zkrom/main/main.zkasm"
 },
 {
  "CONST": 0,
  "neg": 0,
  "setB": 1,
  "setC": 1,
  "line": 57,
  "fileName": ".../zkrom/main/main.zkasm"
 },
 {
  "freeInTag": {
   "op": ""
  },
  "inFREE": 1,
  "neg": 0,
  "setSR": 1,
  "sWR": 1,
  "line": 58,
  "fileName": ".../zkrom/main/main.zkasm"
 }
```
- Description
  - Read from memory position 4 (`sequencerAddr`) and store it on `op`. Set `op` to register A.
  - Set CONST to `op` and store `op` in registers `B` and `C`.
  - Perform SWRITE (write to Merkle tree) according: `storage.set(SR, (H[A0 , A1 , A2 , B0 , C0 , C1 , C2 , C3, 0...0], D0 + D1 * 2^64 + D2 * 2^128 + D3 * 2^192 )`
    - `SR` is the current state-root saved in register `SR`.
    - `A0, A1, A2` carry the sequencer address.
    - `B0` is set to `0` pointing out that the `balance` is going to be read.
    - `C0,C1,C2,C3` are set to 0 since they are not used when reading balance from the Merkle tree.
    - `D0, D1, D2, D3` is the value written in the Merkle tree pointed out by `H[A0 , A1 , A2 , B0 , C0 , C1 , C2 , C3, 0...0]`. In this example, register `D` has the balance of the `seqAddr`.
  - Write Merkle tree state root in register `SR`.