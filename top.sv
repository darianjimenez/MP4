module top (
    input logic clk, reset,
    output logic LED, // remove LED later
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    localparam IDLE = 3'b000;
    localparam FETCH = 3'b001;
    localparam DECODE = 3'b010;
    localparam EXECUTE = 3'b011;
    localparam MEMORY = 3'b100;
    localparam WRITEBACK = 3'b101;
    logic[2:0] state;

    // pc management
    logic[31:0] pc;
    logic[31:0 ]next_pc = 32'bx;
    logic       pc_update; //flag for branch target instead of pc+4
    logic[31:0] branch_target;
    logic       will_branch;
    logic[31:0] jalr_return;

    //instruction management
    logic[31:0] instruction_reg;
    logic[6:0]  opcode, funct7;
    logic[2:0]  funct3;
    logic       is_jalr;

    //register file management
    logic[4:0] rs1in, rs2in, rdin;
    logic[31:0] rs1out, rs2out, dmem_data_in;
    
    //ALU control signals
    logic[1:0] alu_src_a, alu_src_b;
    logic[2:0] alu_op;
    
    //memory control signals
    logic reg_write, dmem_wren;

    logic[31:0] imm_out;

    //ALU dataflow
    logic[31:0] alu_in1, alu_in2, dmem_address;
    logic alu_zero, alu_lt, alu_ltu;

    //write data
    logic[31:0] write_data;

    //memory interface
    logic[31:0] imem_data_out;
    logic[31:0] dmem_data_out;
    
    // Instantiate memory module
    memory #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test") // consider new file
    ) mem (
        .clk            (clk), 
        //instruction memory - read only
        .imem_address   (pc), 
        .imem_data_out  (imem_data_out), 
        //data memory - read/write
        .dmem_wren      (dmem_wren), 
        .dmem_address   (dmem_address), 
        .dmem_data_in   (dmem_data_in), 
        .dmem_data_out  (dmem_data_out), 
        .funct3         (funct3), 
        .led            (LED), 
        .red            (RGB_R), 
        .green          (RGB_G), 
        .blue           (RGB_B)
    );

    // Instantiate register file @darianjimenez
    register_file rf (
        .clk        (clk),
        .rs1in      (rs1in), // read data
        .rs2in      (rs2in),
        .rs1out     (rs1out),
        .rs2out     (rs2out),
        .rdin       (rdin), // write data
        .wren       (reg_write),
        .rd_data_in (write_data)
    );

    assign dmem_data_in = rs2out;

    // Instantiate ALU @TaneKoh
    alu u1 (
        .alu_op      (alu_op), 
        .alu_in1     (alu_in1), 
        .alu_in2     (alu_in2), 
        .alu_out     (dmem_address),
        .zero        (alu_zero),
        .less_than   (alu_lt),
        .less_than_unsigned (alu_ltu)
    );

    // Instantiate Immediate Generator @eddydpan
    imm_gen u2 (
        .instruction    (instruction_reg), 
        .imm_out        (imm_out)
    );

    // alu input selection 1 - for fetch/decode, use pc, for execute use rs1out
    assign alu_in1 = (alu_src_a == 2'b00) ? pc :
                 (alu_src_a == 2'b01) ? rs1out :
                 32'b0;

    // alu input selection 2 -dmem_data_in used for r-type instructions
    // immediate used for i-type
    // 10 = 4 used for pc+4
    assign alu_in2 = (alu_src_b == 2'b00) ? dmem_data_in :
                    (alu_src_b == 2'b01) ? imm_out :
                    (alu_src_b == 2'b10) ? 32'd4 :
                    32'b0;

    /*  --<>-- FSM for main processor loop --<>--  */
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            alu_op <= 3'b000;
        end else begin
            // FSM
            case (state)
                IDLE: begin // used if holding reset not perform any operations
                    state <= FETCH;
                end

                FETCH: begin
                    instruction_reg <= imem_data_out; // reading instructions from memory (read from text files)
                    alu_src_a <= 2'b00;
                    alu_src_b <= 2'b10;
                    alu_op <= 3'b000; // for pc+4
                    state <= DECODE; // transition to DECODE on next clk cycle
                end

                DECODE: begin
                    // Decode
                    next_pc <= dmem_address;
                    opcode  <= instruction_reg[6:0]; // what kind of instruction
                    funct3  <= instruction_reg[14:12]; 

                    // DONT SET THIS FOR A JAL!!!!!!!!!!
                    rs1in   <= (opcode != 7'b1101111) ?  instruction_reg[19:15] : rs1in; // which registers to read
                    rs2in   <= instruction_reg[24:20];
                    rdin    <= instruction_reg[11:7]; // which register to write to
                    funct7  <= instruction_reg[31:25];

                    // TODO: validate if we should actually keep this or not
                    // alu_src_a <= 2'b00;  // Use PC (from fetch)
                    // alu_src_b <= 2'b01;  // Use immediate
                    // alu_op <= 3'b000;    // ADD
                    case (instruction_reg[6:0])
                        7'b1101111: begin // JAL - J-type immediate
                            branch_target <= pc + {{12{instruction_reg[31]}}, 
                                                instruction_reg[19:12], 
                                                instruction_reg[20], 
                                                instruction_reg[30:21], 
                                                1'b0};
                        end
                        //TODO: validate that this should be commented out

                        // 7'b1100111: begin // JALR - I-type immediate
                        //     branch_target <= pc + {{21{instruction_reg[31]}}, 
                        //                         instruction_reg[30:20]};
                        // end  
                        7'b1100011: begin // Branches - B-type immediate
                            branch_target <= pc + {{20{instruction_reg[31]}}, 
                                                instruction_reg[7], 
                                                instruction_reg[30:25], 
                                                instruction_reg[11:8], 
                                                1'b0};
                        end
                        default: begin
                            branch_target <= pc + 4; // Default
                        end
                    endcase
                    state <= EXECUTE; // transition to EXECUTE on next clk cycle
                end
                
                EXECUTE: begin
                    // Execute state
                    case(opcode)
                    //r-type
                    7'b0110011: begin
                        alu_src_a <= 2'b01;  // Use rs1out
                        alu_src_b <= 2'b00;  // Use rs2out (via dmem_data_in)
                        case (funct3)
                            3'b000: alu_op <= (funct7[5]) ? 3'b001 : 3'b000; // ADD/SUB
                            3'b001: alu_op <= 3'b101; // SLL
                            3'b010: alu_op <= 3'b001; // SLT (use SUB, check less_than flag)
                            3'b011: alu_op <= 3'b001; // SLTU (use SUB, check less_than_unsigned flag)
                            3'b100: alu_op <= 3'b100; // XOR
                            3'b101: alu_op <= (funct7[5]) ? 3'b111 : 3'b110; // SRL/SRA
                            3'b110: alu_op <= 3'b110; // OR
                            3'b111: alu_op <= 3'b111; // AND
                        endcase
                        // dmem_address = rs1 op rs2
                    end
                    // i-type
                    7'b0010011: begin
                        // addi, ori, andi, xori, slli, srli, srai, slti, sltiu
                        alu_src_a <= 2'b01;  // Use rs1out
                        alu_src_b <= 2'b01;  // Use immediate
                        case (funct3)
                            3'b000: alu_op <= 3'b000; // ADDI (no SUB for I-type)
                            3'b001: alu_op <= 3'b101; // SLLI
                            3'b010: alu_op <= 3'b001; // SLTI (use SUB, check less_than flag)
                            3'b011: alu_op <= 3'b001; // SLTIU (use SUB, check less_than_unsigned flag)
                            3'b100: alu_op <= 3'b100; // XORI
                            3'b101: alu_op <= (instruction_reg[30]) ? 3'b111 : 3'b110; // SRLI/SRAI (bit 30 distinguishes)
                            3'b110: alu_op <= 3'b011; // ORI
                            3'b111: alu_op <= 3'b010; // ANDI
                        endcase
                        // dmem_address = rs1 op immediate
                    end
                    // load i-type / store (s-type)
                    7'b0000011, 7'b0100011: begin
                        // LB, LH, LW, LBU, LHU
                        alu_src_a <= 2'b01;  // Use rs1out (base address)
                        alu_src_b <= 2'b01;  // Use immediate (offset)
                        alu_op <= 3'b000;    // ADD
                        // dmem_address = rs1 + immediate (memory address)
                    end
                    // branch (B-type)
                    7'b1100011: begin
                        alu_src_a <= 2'b01;  // Use rs1out
                        alu_src_b <= 2'b00;  // Use dmem_data_in
                        alu_op <= 3'b001;    // SUBTRACT
                        // dmem_address = rs1 - rs2 (for comparison)
                        // alu_zero flag determines branch
                    end
                    // JAL (J-type)
                    7'b1101111: begin
                        alu_src_a <= 2'b00;  // Use PC
                        alu_src_b <= 2'b10;  // Use constant 4
                        alu_op <= 3'b000;    // ADD
                        // dmem_address = PC + 4 (return address)
                    end
                    // JALR (I-type)
                    7'b1100111: begin
                        jalr_return = dmem_address; // PC + 4 (return address)
                        alu_src_a <= 2'b01;  // Use rs1out
                        alu_src_b <= 2'b01;  // Use immediate
                        alu_op <= 3'b000;    // ADD
                        // dmem_address = rs1 + immediate (jump target)
                    end
                    // U-type (LUI)
                    7'b0110111: begin
                        alu_src_a <= 2'b00;  // Use PC (not used)
                        alu_src_b <= 2'b01;  // Use immediate
                        alu_op <= 3'b000;    // ADD (not used)
                        // dmem_address = immediate (load upper/immediate)
                    end
                    // U-type (AUIPC)
                    7'b0010111: begin
                        alu_src_a <= 2'b00;  // Use PC
                        alu_src_b <= 2'b01;  // Use immediate
                        alu_op <= 3'b000;    // ADD
                        // dmem_address = PC + immediate
                    end
                    endcase
                    state <= MEMORY;
                end

                MEMORY: begin
                    dmem_wren <= 1'b0; // default to no write (safety)
                    // read/write memory or update PC for branches/jumps
                    case(opcode)
                        //load
                        7'b0000011: begin
                            dmem_wren <= 1'b0; // read from memory - write disabled
                            pc_update <= 1'b1;
                            // dmem_data_out = memory[dmem_address]
                        end
                        //store
                        7'b0100011: begin
                            dmem_wren <= 1'b1; // write to memory
                            pc_update <= 1'b1;
                            // memory[dmem_address] <= dmem_data_in
                        end
                        //branch - update PC
                        7'b1100011: begin
                            unique case (funct3)
                                3'b000: will_branch <= alu_zero;     // BEQ
                                3'b001: will_branch <= !alu_zero;    // BNE
                                3'b100: will_branch <= alu_lt;       // BLT
                                3'b101: will_branch <= !alu_lt;      // BGE
                                3'b110: will_branch <= alu_ltu;      // BLTU
                                3'b111: will_branch <= !alu_ltu;     // BGEU
                            endcase
                            if (will_branch) next_pc <= branch_target;
                            pc_update <= 1'b1;
                        end
                        //JAL - update PC to jump target
                        7'b1101111: begin
                            pc_update <= 1'b1;
                            next_pc <= branch_target; // Jump target
                        end
                        //JALR - update PC to jump target
                        7'b1100111: begin
                            pc_update <= 1'b1;     
                            next_pc <= (dmem_address & ~32'h00000001); // Jump target (LSB = 0)
                        end

                        default: begin
                            pc_update <= 1'b1;
                        end
                    endcase
                    state <= WRITEBACK;
                end
                WRITEBACK: begin
                    case(opcode)
                        //r-type
                        7'b0110011: begin
                            reg_write <= 1'b1; // enable register write
                            // Handle SLT/SLTU specially - write comparison result
                            if (funct3 == 3'b010) // SLT
                                write_data <= {31'b0, alu_lt}; // 1 if less than (signed), 0 otherwise
                            else if (funct3 == 3'b011) // SLTU
                                write_data <= {31'b0, alu_ltu}; // 1 if less than (unsigned), 0 otherwise
                            else
                                write_data <= dmem_address; // write alu result to register
                        end
                        
                        //i-type ALU
                        7'b0010011: begin
                            reg_write <= 1'b1; // enable register write
                            // Handle SLTI/SLTIU specially - write comparison result
                            if (funct3 == 3'b010) // SLTI
                                write_data <= {31'b0, alu_lt}; // 1 if less than (signed), 0 otherwise
                            else if (funct3 == 3'b011) // SLTIU
                                write_data <= {31'b0, alu_ltu}; // 1 if less than (unsigned), 0 otherwise
                            else
                                write_data <= dmem_address; // write alu result to register
                        end

                        //load - write mem data into register
                        7'b0000011: begin
                            reg_write <= 1'b1;
                            write_data <= dmem_data_out; // data from memory
                        end

                        //jal - write return address (PC + 4)
                        7'b1101111: begin
                            reg_write <= 1'b1;
                            write_data <= dmem_address;  // PC + 4 from EXECUTE stage
                        end

                        //jalr - write return address (PC + 4)
                        7'b1100111: begin
                            reg_write <= 1'b1;
                            write_data <= jalr_return;  // PC + 4 from EXECUTE stage
                        end
                        
                        //lui - write immediate
                        7'b0110111: begin
                            reg_write <= 1'b1;
                            write_data <= imm_out;
                        end

                        //auipc - write pc + immediate
                        7'b0010111: begin
                            reg_write <= 1'b1;
                            write_data <= dmem_address; // alu result from EXECUTE stage
                        end

                    endcase
                    // Update PC here (WRITEBACK) so synchronous instruction memory
                    // has a full cycle to produce imem_data_out for the next fetch.
                    
                    state <= IDLE; // transition back to FETCH on next clk cycle
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (pc_update) begin
            if (next_pc === 32'bx) begin
                pc <= pc + 4;  // Fallback if next_pc is unknown
            end else begin
                pc <= next_pc; // Use branch/jump target
            end
            pc_update <= 1'b0; // Clear flag
        end
    end
    // PC is updated in WRITEBACK so synchronous imem has time to produce data
endmodule