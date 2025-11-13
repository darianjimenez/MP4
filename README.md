# CompArch-MP4

## Workflow
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
