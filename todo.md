# 12.1.25
- Merge together the simulation testing (Tane) + S, B, U instructions (Darian)
- I-type instructions implementation (Eddy)
- Write-up talk
- extension?

## What do we want to do that is "Unique" with our LED?
### Ideation:
- "interesting manner"
    - *state* in our FSM corresponds to a color
    - Different LEDs blinking for different bits
        - 8 bits per RGB channel and 8 bits for LED
    - Color for different instruction types
    - Blink frequency depending on value written to register
    - (actively) Red for if using ALU, Green if using imm_gen, blue if writing to memory

Next Steps:
- more simulation testing
- all instructions implemented
    - i type
- Filling in write up skeleton

# 11.19.25
Plan to review all of our implemented modules and integrate :)

# 11.17.25

Working on top.sv

1. initial block to read in from text file using `readmemh` into our memory
2. Build out main FSM logic
- decoding
- fetching
- execution
    - substates within execute
3. clearly define interfaces for each module