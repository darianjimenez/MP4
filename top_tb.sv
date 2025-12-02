// `timescale 1ns/1ps

// module top_tb;
//     logic clk, reset;
//     logic LED, RGB_R, RGB_G, RGB_B;
    
//     // Instantiate your processor
//     top dut (.*);
    
//     // Force PC initialization for simulation
//     initial begin
//         dut.pc = 32'h00001000;
//         dut.next_pc = 32'h00001000;
//         #1;
//     end

//     // Clock generation (100MHz)
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     logic [31:0] expected_pc[24];
//     integer expected_reg[24];
//     logic [31:0] expected_val[24];
//     string expected_instr[24];

//     integer error_count = 0;
//     integer result_index = 0;
//     integer total_expected = 0;

//     logic check_next_cycle = 1'b0;
//     integer last_rd = 0;
//     logic [31:0] last_write_data = 32'b0;
//     integer last_pc = 0;
//     string last_instr = "";

//     // Initialize expected results
//     initial begin
//         // lui x1, 0xFEDCC
//         expected_pc[0] = 32'h00001000;
//         expected_reg[0] = 1;
//         expected_val[0] = 32'hFEDCC000;
//         expected_instr[0] = "lui x1, 0xFEDCC";
        
//         // addi x1, x1, 0xA98
//         expected_pc[1] = 32'h00001004;
//         expected_reg[1] = 1;
//         expected_val[1] = 32'hFEDCBA98;
//         expected_instr[1] = "addi x1, x1, 0xA98";
        
//         // srli x2, x1, 4
//         expected_pc[2] = 32'h00001008;
//         expected_reg[2] = 2;
//         expected_val[2] = 32'h0FEDCBA9;
//         expected_instr[2] = "srli x2, x1, 4";
        
//         // srai x3, x1, 4
//         expected_pc[3] = 32'h0000100C;
//         expected_reg[3] = 3;
//         expected_val[3] = 32'hFFEDCBA9;
//         expected_instr[3] = "srai x3, x1, 4";
        
//         // xori x4, x3, -1
//         expected_pc[4] = 32'h00001010;
//         expected_reg[4] = 4;
//         expected_val[4] = 32'h00123456;
//         expected_instr[4] = "xori x4, x3, -1";
        
//         // addi x5, x0, 2
//         expected_pc[5] = 32'h00001014;
//         expected_reg[5] = 5;
//         expected_val[5] = 32'h00000002;
//         expected_instr[5] = "addi x5, x0, 2";
        
//         // add x6, x5, x4
//         expected_pc[6] = 32'h00001018;
//         expected_reg[6] = 6;
//         expected_val[6] = 32'h00123458;
//         expected_instr[6] = "add x6, x5, x4";
        
//         // sub x7, x6, x4
//         expected_pc[7] = 32'h0000101C;
//         expected_reg[7] = 7;
//         expected_val[7] = 32'h00000002;
//         expected_instr[7] = "sub x7, x6, x4";
        
//         // sll x8, x4, x5
//         expected_pc[8] = 32'h00001020;
//         expected_reg[8] = 8;
//         expected_val[8] = 32'h0048D158;
//         expected_instr[8] = "sll x8, x4, x5";
        
//         // ori x9, x8, 7
//         expected_pc[9] = 32'h00001024;
//         expected_reg[9] = 9;
//         expected_val[9] = 32'h0048D15F;
//         expected_instr[9] = "ori x9, x8, 7";
        
//         // auipc x10, 0x12345
//         expected_pc[10] = 32'h00001028;
//         expected_reg[10] = 10;
//         expected_val[10] = 32'h12345028;
//         expected_instr[10] = "auipc x10, 0x12345";
        
//         // slt x11, x3, x4
//         expected_pc[11] = 32'h0000102C;
//         expected_reg[11] = 11;
//         expected_val[11] = 32'h00000001;
//         expected_instr[11] = "slt x11, x3, x4";
        
//         // sltu x12, x3, x4
//         expected_pc[12] = 32'h00001030;
//         expected_reg[12] = 12;
//         expected_val[12] = 32'h00000000;
//         expected_instr[12] = "sltu x12, x3, x4";
        
//         // jal x13, 0x28
//         expected_pc[13] = 32'h00001034;
//         expected_reg[13] = 13;
//         expected_val[13] = 32'h00000038;
//         expected_instr[13] = "jal x13, 0x28";
        
//         // addi x15, x0, 10
//         expected_pc[14] = 32'h00001038;
//         expected_reg[14] = 15;
//         expected_val[14] = 32'h0000000A;
//         expected_instr[14] = "addi x15, x0, 10";
        
//         // jal x16, -8 (after loop)
//         expected_pc[15] = 32'h00001044;
//         expected_reg[15] = 16;
//         expected_val[15] = 32'h00000048;
//         expected_instr[15] = "jal x16, -8";
        
//         // jalr x14, 0(x13)
//         expected_pc[16] = 32'h0000105C;
//         expected_reg[16] = 14;
//         expected_val[16] = 32'h00000060;
//         expected_instr[16] = "jalr x14, 0(x13)";
        
//         // addi x17, x0, 0xC0
//         expected_pc[17] = 32'h00001060;
//         expected_reg[17] = 17;
//         expected_val[17] = 32'h000000C0;
//         expected_instr[17] = "addi x17, x0, 0xC0";
        
//         // lw x18, -4(x0)
//         expected_pc[18] = 32'h00001074;
//         expected_reg[18] = 18;
//         expected_val[18] = 32'hC0C0C0C0;
//         expected_instr[18] = "lw x18, -4(x0)";
        
//         // lw x19, -12(x0) - micros (variable)
//         expected_pc[19] = 32'h00001078;
//         expected_reg[19] = 19;
//         expected_val[19] = 32'hXXXXXXXX;
//         expected_instr[19] = "lw x19, -12(x0)";
        
//         // lh x20, -4(x0)
//         expected_pc[20] = 32'h0000107C;
//         expected_reg[20] = 20;
//         expected_val[20] = 32'hFFFFC0C0;
//         expected_instr[20] = "lh x20, -4(x0)";
        
//         // lhu x21, -4(x0)
//         expected_pc[21] = 32'h00001080;
//         expected_reg[21] = 21;
//         expected_val[21] = 32'h0000C0C0;
//         expected_instr[21] = "lhu x21, -4(x0)";
        
//         // lb x22, -4(x0)
//         expected_pc[22] = 32'h00001084;
//         expected_reg[22] = 22;
//         expected_val[22] = 32'hFFFFFFC0;
//         expected_instr[22] = "lb x22, -4(x0)";
        
//         // lbu x23, -4(x0)
//         expected_pc[23] = 32'h00001088;
//         expected_reg[23] = 23;
//         expected_val[23] = 32'h000000C0;
//         expected_instr[23] = "lbu x23, -4(x0)";
        
//         total_expected = 24;
//     end
    
//     // Reset and test sequence
//     initial begin
//         $dumpfile("top_tb.vcd");
//         $dumpvars(0, top_tb);
//         // Initialize signals
//         reset = 1;
//         #200;
//         reset = 0;
        
//         $display("=== Starting RV32I Processor Test ===");
//         $display("Time\tPC\t\tInstruction\tState");
//         $display("----------------------------------------");
        
//         // Run for enough cycles to execute all instructions
//         #10000;  // 10000ns = plenty of time
        
//         $display("----------------------------------------");
//         $display("Test completed: %0d/%0d instructions passed", 
//                  result_index - error_count, result_index);
//         if (error_count == 0) begin
//             $display("SUCCESS! All tests passed!");
//         end else begin
//             $display("FAILURE: %0d errors detected", error_count);
//         end
//         $finish;
//     end
    
//     // Monitor important signals every clock cycle
//     always @(posedge clk) begin
//         if (!reset) begin
//             $display("%0t\t%h\tMEM:%h\tREG:%h\t%d", $time, dut.pc, dut.imem_data_out, dut.instruction_reg,dut.state);
//         end
//     end
    
//     always @(posedge clk) begin
//         if (!reset && dut.state == 3'b101) begin // WRITEBACK stage
//             if (dut.reg_write && dut.rdin != 0) begin
//                 check_next_cycle <= 1'b1;
//                 last_rd <= dut.rdin;
//                 last_write_data <= dut.write_data;
//                 last_pc <= dut.pc;
//                 $display("  CAPTURED WRITE: PC=%h will write x%d = %h", 
//                         dut.pc, dut.rdin, dut.write_data);

//             end else begin
//                 check_next_cycle <= 1'b0;
//             end
//         end else begin
//             check_next_cycle <= 1'b0;
//         end
//     end
    
// always @(posedge clk) begin
//         if (!reset && dut.state == 3'b001) begin // FETCH stage
//             if (check_next_cycle) begin
//                 // Now check if this was an expected result
//                 if (result_index < total_expected) begin
//                     integer current_pc = expected_pc[result_index];
//                     integer current_reg = expected_reg[result_index];
//                     logic [31:0] current_expected = expected_val[result_index];
//                     string current_instr = expected_instr[result_index];
                    
//                     logic [31:0] actual_value = last_write_data;
//                     logic pass;
                    
//                     // Display what we're checking
//                     $display("  CHECKING: PC=%h, Instr=%s, Exp: x%d=%h, Act: x%d=%h",
//                             current_pc, current_instr, current_reg, current_expected,
//                             last_rd, actual_value);
                    
//                     if (current_instr == "lw x19, -12(x0)") begin
//                         // micros counter - just check it's not X or 0 after some time
//                         pass = (actual_value !== 32'hXXXXXXXX && actual_value != 32'h0);
//                         $display("%0t\t%h\t%-16s\t<variable>\t%h\t%s", 
//                                 $time, current_pc, current_instr, 
//                                 actual_value, pass ? "OK" : "ERROR");
//                     end else begin
//                         pass = (actual_value === current_expected);
//                         $display("%0t\t%h\t%-16s\t%h\t%h\t%s", 
//                                 $time, current_pc, current_instr, 
//                                 current_expected, actual_value, 
//                                 pass ? "OK" : "ERROR");
//                     end
                    
//                     if (!pass) begin
//                         error_count = error_count + 1;
//                         $display("  ERROR: Expected %h, got %h for %s", 
//                                 current_expected, actual_value, current_instr);
//                     end
                    
//                     result_index = result_index + 1;
//                 end else begin
//                     // Unexpected register write
//                     $display("%0t\t%h\tUNEXPECTED REG WRITE: x%d = %h", 
//                             $time, last_pc, last_rd, last_write_data);
//                 end
//             end
//         end
//     end
//     always @(posedge clk) begin
//         if (!reset && dut.state == 3'b001) begin // FETCH stage
//             $display("%0t\t%h\tFETCH: MEM[PC] = %h", 
//                     $time, dut.pc, dut.imem_data_out);
//         end
//     end
//     initial begin
//     $display("Debug: expected_pc[0]=%h, expected_instr[0]=%s", 
//              expected_pc[0], expected_instr[0]);
// end
// endmodule

`timescale 1ns/1ps

module top_tb;
    // Testbench signals
    reg clk, reset;
    reg LED, RGB_R, RGB_G, RGB_B;
    
    // Instantiate the processor
    top dut (
        .clk(clk),
        .reset(reset),
        .LED(LED),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );
    
    // Test control
    reg [31:0] expected_pc [0:99];
    reg [4:0] expected_reg [0:99];
    reg [31:0] expected_val [0:99];
    reg [8*100:0] expected_instr [0:99];  // String storage
    
    integer test_num = 0;
    integer error_count = 0;
    integer total_tests = 24;
    integer cycle_count = 0;
    integer num_test_cases = 0;
    integer checked [0:99];
    
    // Register write tracking
    reg last_reg_write;
    integer last_rd;
    reg [31:0] last_write_data;
    reg [31:0] last_write_pc;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize test cases
    task init_test_cases;
        begin
            // lui x1, 0xFEDCC
            expected_pc[0] = 32'h00001000;
            expected_reg[0] = 1;
            expected_val[0] = 32'hFEDCC000;
            expected_instr[0] = "lui x1, 0xFEDCC";
            checked[0] = 0;
            
            // addi x1, x1, 0xA98
            expected_pc[1] = 32'h00001004;
            expected_reg[1] = 1;
            expected_val[1] = 32'hFEDCBA98;
            expected_instr[1] = "addi x1, x1, 0xA98";
            checked[1] = 0;
            
            // srli x2, x1, 4
            expected_pc[2] = 32'h00001008;
            expected_reg[2] = 2;
            expected_val[2] = 32'h0FEDCBA9;
            expected_instr[2] = "srli x2, x1, 4";
            checked[2] = 0;
            
            // srai x3, x1, 4
            expected_pc[3] = 32'h0000100C;
            expected_reg[3] = 3;
            expected_val[3] = 32'hFFEDCBA9;
            expected_instr[3] = "srai x3, x1, 4";
            checked[3] = 0;
            
            // xori x4, x3, -1
            expected_pc[4] = 32'h00001010;
            expected_reg[4] = 4;
            expected_val[4] = 32'h00123456;
            expected_instr[4] = "xori x4, x3, -1";
            checked[4] = 0;
            
            // addi x5, x0, 2
            expected_pc[5] = 32'h00001014;
            expected_reg[5] = 5;
            expected_val[5] = 32'h00000002;
            expected_instr[5] = "addi x5, x0, 2";
            checked[5] = 0;
            
            // add x6, x5, x4
            expected_pc[6] = 32'h00001018;
            expected_reg[6] = 6;
            expected_val[6] = 32'h00123458;
            expected_instr[6] = "add x6, x5, x4";
            checked[6] = 0;
            
            // sub x7, x6, x4
            expected_pc[7] = 32'h0000101C;
            expected_reg[7] = 7;
            expected_val[7] = 32'h00000002;
            expected_instr[7] = "sub x7, x6, x4";
            checked[7] = 0;
            
            // sll x8, x4, x5
            expected_pc[8] = 32'h00001020;
            expected_reg[8] = 8;
            expected_val[8] = 32'h0048D158;
            expected_instr[8] = "sll x8, x4, x5";
            checked[8] = 0;
            
            // ori x9, x8, 7
            expected_pc[9] = 32'h00001024;
            expected_reg[9] = 9;
            expected_val[9] = 32'h0048D15F;
            expected_instr[9] = "ori x9, x8, 7";
            checked[9] = 0;
            
            // auipc x10, 0x12345
            expected_pc[10] = 32'h00001028;
            expected_reg[10] = 10;
            expected_val[10] = 32'h12345028;
            expected_instr[10] = "auipc x10, 0x12345";
            checked[10] = 0;
            
            // slt x11, x3, x4
            expected_pc[11] = 32'h0000102C;
            expected_reg[11] = 11;
            expected_val[11] = 32'h00000001;
            expected_instr[11] = "slt x11, x3, x4";
            checked[11] = 0;
            
            // sltu x12, x3, x4
            expected_pc[12] = 32'h00001030;
            expected_reg[12] = 12;
            expected_val[12] = 32'h00000000;
            expected_instr[12] = "sltu x12, x3, x4";
            checked[12] = 0;
            
            // jal x13, 0x28
            expected_pc[13] = 32'h00001034;
            expected_reg[13] = 13;
            expected_val[13] = 32'h00000038;
            expected_instr[13] = "jal x13, 0x28";
            checked[13] = 0;
            
            // addi x15, x0, 10
            expected_pc[14] = 32'h00001038;
            expected_reg[14] = 15;
            expected_val[14] = 32'h0000000A;
            expected_instr[14] = "addi x15, x0, 10";
            checked[14] = 0;
            
            // jal x16, -8 (after loop)
            expected_pc[15] = 32'h00001044;
            expected_reg[15] = 16;
            expected_val[15] = 32'h00000048;
            expected_instr[15] = "jal x16, -8";
            checked[15] = 0;
            
            // jalr x14, 0(x13)
            expected_pc[16] = 32'h0000105C;
            expected_reg[16] = 14;
            expected_val[16] = 32'h00000060;
            expected_instr[16] = "jalr x14, 0(x13)";
            checked[16] = 0;
            
            // addi x17, x0, 0xC0
            expected_pc[17] = 32'h00001060;
            expected_reg[17] = 17;
            expected_val[17] = 32'h000000C0;
            expected_instr[17] = "addi x17, x0, 0xC0";
            checked[17] = 0;
            
            // lw x18, -4(x0)
            expected_pc[18] = 32'h00001074;
            expected_reg[18] = 18;
            expected_val[18] = 32'hC0C0C0C0;
            expected_instr[18] = "lw x18, -4(x0)";
            checked[18] = 0;
            
            // lw x19, -12(x0) - micros (variable)
            expected_pc[19] = 32'h00001078;
            expected_reg[19] = 19;
            expected_val[19] = 32'hXXXXXXXX;  // Variable
            expected_instr[19] = "lw x19, -12(x0)";
            checked[19] = 0;
            
            // lh x20, -4(x0)
            expected_pc[20] = 32'h0000107C;
            expected_reg[20] = 20;
            expected_val[20] = 32'hFFFFC0C0;
            expected_instr[20] = "lh x20, -4(x0)";
            checked[20] = 0;
            
            // lhu x21, -4(x0)
            expected_pc[21] = 32'h00001080;
            expected_reg[21] = 21;
            expected_val[21] = 32'h0000C0C0;
            expected_instr[21] = "lhu x21, -4(x0)";
            checked[21] = 0;
            
            // lb x22, -4(x0)
            expected_pc[22] = 32'h00001084;
            expected_reg[22] = 22;
            expected_val[22] = 32'hFFFFFFC0;
            expected_instr[22] = "lb x22, -4(x0)";
            checked[22] = 0;
            
            // lbu x23, -4(x0)
            expected_pc[23] = 32'h00001088;
            expected_reg[23] = 23;
            expected_val[23] = 32'h000000C0;
            expected_instr[23] = "lbu x23, -4(x0)";
            checked[23] = 0;
            
            num_test_cases = 24;
            
            $display("Initialized %0d test cases", num_test_cases);
            for (integer i = 0; i < num_test_cases; i = i + 1) begin
                $display("Test %0d: PC=%h, %s -> x%d = %h", 
                        i, expected_pc[i], expected_instr[i],
                        expected_reg[i], expected_val[i]);
            end
        end
    endtask
    
    // Track register writes (happens in WRITEBACK stage)
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            // Capture register writes in WRITEBACK stage
            if (dut.state == 3'b101) begin  // WRITEBACK
                if (dut.reg_write && dut.rdin != 0) begin
                    last_reg_write = 1'b1;
                    last_rd = dut.rdin;
                    last_write_data = dut.write_data;
                    last_write_pc = dut.pc;
                    
                    $display("[%0t] Cycle %0d: WRITEBACK @ PC=%h -> x%d = %h", 
                            $time, cycle_count, dut.pc, dut.rdin, dut.write_data);
                end else begin
                    last_reg_write = 1'b0;
                end
            end else begin
                last_reg_write = 1'b0;
            end
        end
    end
    
    // Check results on next cycle (after WRITEBACK)
    always @(posedge clk) begin
        integer i;
        integer found;
        integer test_idx;
        
        if (!reset) begin
            if (last_reg_write) begin
                // Find matching test case
                found = 0;
                test_idx = -1;
                
                for (i = 0; i < num_test_cases; i = i + 1) begin
                    if (checked[i] == 0 && expected_reg[i] == last_rd) begin
                        // Found a matching test case
                        found = 1;
                        test_idx = i;
                        i = num_test_cases;  // break
                    end
                end
                
                if (found) begin
                    test_num = test_num + 1;
                    
                    $display("[%0t] TEST %0d/%0d: Checking %s", 
                            $time, test_num, total_tests, 
                            expected_instr[test_idx]);
                    
                    // Check the result
                    if (expected_instr[test_idx] == "lw x19, -12(x0)") begin
                        // Special case: micros counter (variable)
                        if (last_write_data !== 32'hXXXXXXXX && last_write_data != 32'h0) begin
                            $display("  PASS: x%d = %h (variable value OK)", 
                                    last_rd, last_write_data);
                            checked[test_idx] = 1;
                        end else begin
                            $display("  FAIL: x%d = %h (unexpected value)", 
                                    last_rd, last_write_data);
                            error_count = error_count + 1;
                        end
                    end else begin
                        if (last_write_data === expected_val[test_idx]) begin
                            $display("  PASS: x%d = %h (expected %h)", 
                                    last_rd, last_write_data, expected_val[test_idx]);
                            checked[test_idx] = 1;
                        end else begin
                            $display("  FAIL: x%d = %h (expected %h)", 
                                    last_rd, last_write_data, expected_val[test_idx]);
                            error_count = error_count + 1;
                        end
                    end
                end else begin
                    // Unexpected register write
                    $display("[%0t] WARNING: Unexpected register write: x%d = %h @ PC=%h", 
                            $time, last_rd, last_write_data, last_write_pc);
                end
            end
        end
    end
    
    // Monitor state and PC
    always @(posedge clk) begin
        reg [8*20:0] state_name;
        
        if (!reset) begin
            // Display state machine progress
            case (dut.state)
                3'b000: state_name = "IDLE";
                3'b001: state_name = "FETCH";
                3'b010: state_name = "DECODE";
                3'b011: state_name = "EXECUTE";
                3'b100: state_name = "MEMORY";
                3'b101: state_name = "WRITEBACK";
                default: state_name = "UNKNOWN";
            endcase
            
            // Only display when instruction changes or on state changes
            if (dut.state == 3'b001) begin  // FETCH stage
                $display("[%0t] FETCH: PC=%h, Instr=%h, State=%s", 
                        $time, dut.pc, dut.imem_data_out, state_name);
            end
        end
    end
    
    // Main test sequence
    initial begin
        integer i;
        integer uncompleted;
        
        // Initialize test cases
        init_test_cases();
        
        // Initialize waveform dump
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        
        // Force PC initialization
        dut.pc = 32'h00001000;
        dut.next_pc = 32'h00001000;
        
        $display("\n=== Starting RV32I Processor Test ===");
        $display("Initial PC forced to: %h", dut.pc);
        
        // Apply reset
        reset = 1;
        #200;
        reset = 0;
        
        $display("Reset released at %0t", $time);
        $display("Beginning execution...\n");
        
        // Run simulation with timeout
        #50000;  // 50,000 ns timeout
        
        // Check final results
        $display("\n=== Test Complete ===");
        $display("Cycles executed: %0d", cycle_count);
        $display("Tests completed: %0d/%0d", test_num, total_tests);
        
        // Check for any uncompleted tests
        uncompleted = 0;
        for (i = 0; i < num_test_cases; i = i + 1) begin
            if (checked[i] == 0) begin
                $display("UNCOMPLETED: Test %0d: %s", i, expected_instr[i]);
                uncompleted = uncompleted + 1;
            end
        end
        
        if (error_count == 0 && uncompleted == 0) begin
            $display("SUCCESS: All %0d tests passed!", total_tests);
        end else begin
            $display("FAILURE: %0d errors, %0d tests not completed", error_count, uncompleted);
        end
        
        $finish;
    end
    
    // Safety timeout
    initial begin
        #100000;  // 100,000 ns absolute timeout
        $display("\nERROR: Simulation timeout!");
        $display("Tests completed: %0d/%0d", test_num, total_tests);
        $display("Cycles: %0d", cycle_count);
        $finish;
    end
endmodule