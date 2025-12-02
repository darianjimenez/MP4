# Multicycle Unpipelined RISC-V Processor
Tane Koh, Eddy Pan, Darian Jimenez

In this repository, we implemented and tested our RISC-V Processor. 

## High Level Design
We architected our processor with the following modular design:

1. Register File
2. ALU
3. Immediate Generator
4. Memory
5. Top


### Register File module `register_file.sv`


### ALU module `alu.sv`


### Immediate Generator module `imm_gen.sv`
- asynchronous
- `always_comb` block

### Memory module `memory.sv`
Adapted from the iceBlinkPico `memory` module, we reused the Data Memory (DMEM) and Instruction Memory (IMEM) from the original implementation.
- expand on the inputs it takes (wren, clk, funct3, data in)
- synchronous
- briefly restate its organization (imem from 0x000000 to 0x000FFF dmem from 0x001000 to 0x001FFF)

### Top module `top.sv`
- Ties together all our modules
    - initiates `alu`, `register_file`, `memory` and `imm_gen` modules
- pc
- Finite State Machine
    - `FETCH` state
    - `DECODE` state
    - `EXECUTE` state
        - Most of the instruction implementation occurs in substates of the `EXECUTE` state
    - `MEMORY` state
    - `WRITEBACK` state



## Instruction Types

### R-Type Instructions
For R-Type instructions, we implemented ADD, SUB, XOR, OR, AND, SLL, SRL, SRA, SLT, and SLTU. Here is our testbench validating the functionality of the `add` instruction:

[screenshot_of_add_instruction.jpg]
- walk through the implementation and the results on the simulation

### I-Type Instructions
Immediate and load

### B-Type Instructions
Conditional branch

### J-Type Instructions
Unconditional jump

### S-Type Instructions
Store

### U-Type Instructions
Long immediate

## LED Behavior













1. Save the instructions from the input file into memory

2. Set PC to the first instruction (0x)

3. Enter our FSM loop (synchronous on pos clk edge)
    a. FETCH STEP: fetch the instruction at PC
    b. DECODE STEP: now that we the instruction fetched from IMEM stored in our `instruction[31:0] register, we take out the first 7 bits (opcode) and store that

    c. EXECUTE STEP: switch statement on the opcode 7-bit register, parse the remaining the bitword based off the instruction type

    d. STORE/COMPLETE STEP: if the opcode 
## Modules:

### top
- register file module
- memory module
- alu module
- imm_gen module
- fsm
    - load
    - decode
    - execute
    - store


### Register File
- Store register values: 2 src, 1 dest
    - Inputs
        - [ ] Wren
        - [ ] clk
        - [ ] rd in
        - [ ] rs1in, rs2in
    - Oututs
        - [ ] rs1o, rs2o --> async reads
        - [ ] rdo

### Memory
- Unified DMEM & IMEM 
- Alr mostly done from template
- Inputs
    - [ ] clk
    - [ ] wren
    - [ ] dmem
    - [ ] imem
- Outputs
    - [ ] data out --> dmem, imem

### ALU
- Perform bit operations
- Inputs
    - [ ] 2 read source reg. from register file
    - [ ] clk
- Outputs
    - [ ] Destination register

### imm_gen
