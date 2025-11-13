`include "memory.sv"

module top (
    input logic clk, 
    output logic LED, // remove LED later
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    

    initial begin
        // Read from memory initialization file
        // readmemh into IMEM memory of memory module
    end

    // Instantiate variables for inter-module connections
    logic[31:0] pc;
    logic[31:0] instruction;
    logic[6:0] opcode;

    // Instantiate memory module
    memory #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test") // consider new file
    ) mem (
        .clk            (clk), 
        .funct3         (funct3), 
        .dmem_wren      (dmem_wren), 
        .dmem_address   (dmem_address), 
        .dmem_data_in   (dmem_data_in), 
        .imem_address   (imem_address), 
        .imem_data_out  (imem_data_out), 
        .dmem_data_out  (dmem_data_out), 
        .reset          (reset), 
        .led            (led), 
        .red            (red), 
        .green          (green), 
        .blue           (blue)
    );



    // Instantiate register file
    register_file #(
        
    ) rf (
        .clk        (clk),
        .wren       (regfile_wren),
        .rs1in      (rs1in),
        .rs2in      (rs2in),
        .rdin       (rdin), // write data
        .data_addr   (data_addr), // <-- clarify
        .rs1out     (rs1out), // read data1
        .rs2out     (rs2out), // read data2
        .rdout      (rdout)
    );

    // Instantiate ALU
    alu u1 (
        .clk         (clk), 
        .alu_op      (alu_op), 
        .alu_in1     (alu_in1), 
        .alu_in2     (alu_in2), 
        .alu_out     (alu_out)
    );

    // Instantiate Immediate Generator
    imm_gen u2 (
        .instruction    (instruction), 
        .imm_out        (imm_out)
    );


    /*  --<>-- FSM for main processor loop --<>--  */
    always_ff @(posedge clk) begin

        // state transitions


        // Fetch
            // read from memory - imem_read, instruction register from imem_data_out
            // do we want this to advance pc (pc = pc+4)
            // then advance to decode
        
        
        // Decode
            // no module, just look at first 7 bits to determine opcode -> which execute substate to go to
            // and also process funct3, rs1, rs2, rd

            // store the opcode in a 7 bit register
            // turn on a flag saying our next state should be execute

        // Execute
            // lots of sub-steps based on decoded instruction type
            // switch statement on opcode register
                // R-type
                    // parse: rs1 rs2 rd
                // I-type

                // J-type
                    // jal, jalr
                    
                // S-type (store)
                    // sw, sb, sh

                // U-type
                
                // B-type
        
            
            // Complete
                // write to registers
                // depending on op-code will be coming from different execute substate variables
                // should be writing to register_file[rd]
                // cycle back to fetch
        
    end






