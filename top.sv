`include "memory.sv"

module top (
    input logic clk, 
    output logic LED, // remove LED later
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    localparam IDLE = 2'b00;
    localparam FETCH = 2'b01;
    localparam DECODE = 2'b10;
    localparam EXECUTE = 2'b11;

    // Instantiate variables for inter-module connections
    logic[31:0] pc, pc_next; // Leave pc next for now, not sure if final implementation
    logic[31:0] instruction_reg;

    logic[6:0] opcode;
    logic[2:0] funct3;
    logic[4:0] rs1in;
    logic[4:0] rs2in;
    logic[4:0] rdin;
    

    logic[1:0] state = IDLE; // could start with IDLE state
    
    
    logic [31:0] alu_in1;
    logic [31:0] alu_in2;
    logic [31:0] alu_out;
    logic alu_zero;
    logic alu_lt;
    logic alu_ltu;


    assign rs1in = 


    
    // Instantiate memory module
    memory #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test") // consider new file
    ) mem (
        .clk            (clk), 
        .funct3         (funct3), 
        .dmem_wren      (dmem_wren), 
        .dmem_address   (dmem_address), 
        .dmem_data_in   (dmem_data_in), 
        .imem_address   (pc), 
        .imem_data_out  (imem_data_out), 
        .dmem_data_out  (dmem_data_out), 
        .reset          (reset), 
        .led            (led), 
        .red            (red), 
        .green          (green), 
        .blue           (blue)
    );

    // Instantiate register file @darianjimenez
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

    // Instantiate ALU @TaneKoh
    alu u1 (
        .clk         (clk), 
        .alu_op      (alu_op), 
        .alu_in1     (alu_in1), 
        .alu_in2     (alu_in2), 
        .alu_out     (alu_out),
        .zero        (alu__zero),
        .less_than   (alu_lt),
        .less_than_unsigned (alu_ltu)
        
    );

    // Instantiate Immediate Generator @eddydpan
    imm_gen u2 (
        .instruction    (instruction_reg), 
        .imm_out        (imm_out)
    );

    /*  --<>-- FSM for main processor loop --<>--  */
    always_ff @(posedge clk) begin
        if (reset) state <= IDLE;
        alu_op <= 3'b000;
        // state transitions
        case (state) begin
            IDLE begin // used if holding reset not perform any operations
                state = FETCH; // blocking assignment
            end
            FETCH begin
                // Fetch
                
                // read from memory - imem_read, instruction register from imem_data_out
                instruction_reg = imem_data_out; // little or big endian?
                // store from instruction
                // read from instruction_memory
                // either implement pc+4 with next_pc type or implement individually in execute states
                state = DECODE; // transition to DECODE on next clk cycle
            end
            DECODE begin
                // Decode
                // no module, just look at first 7 bits to determine opcode -> which execute substate to go to
                // and also process funct3, rs1, rs2, rd

                // store the opcode in a 7 bit register
                // turn on a flag saying our next state should be execute
                opcode = instruction_reg[6:0];
                funct3 = instruction_reg[14:12]; // funct3 decoded or funct3?
                state = EXECUTE; // transition to EXECUTE on next clk cycle
            end
            EXECUTE begin
                // Execute state
                case (opcode) begin
                    // lots of sub-steps based on decoded instruction type
                    // switch statement on opcode register
                        7'b0110011: begin //R-type
                            alu_src_a <= 2'b01; //rs1
                            alu_src_b <= 2'b02; //rs2
                            alu_op <= funct3;
                            // parse: rs1 rs2 rd
                            // add, sub, and, or, xor, sll, srl, sra, slt, sltu
                        end

                        // I-type
                        7'b0000011: begin
                            // Load instructions: LB, LH, LW, LBU, LHU.
                        
                        end
                        7'b0010011: begin
                            // Integer register-immediate operations: addi, ori, andi, xori, slli, srli, srai, slti, sltiu
                            // determined by funct3 and funct7
                        end
                        7'b1100111: begin
                            // jalr
                        
                        
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

                state = FETCH; // transition back to FETCH on next clk cycle
            end
        endcase
    end
endmodule



