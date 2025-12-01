`timescale 1ns/1ps

module top_tb;
    logic clk, reset;
    logic LED, RGB_R, RGB_G, RGB_B;
    
    // Instantiate your processor
    top dut (.*);
    
    // Force PC initialization for simulation
    initial begin
        dut.pc = 32'h00001000;
        dut.next_pc = 32'h00001000;
        #1;
    end

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset and test sequence
    initial begin
        // Initialize signals
        reset = 1;
        #200;
        reset = 0;
        
        $display("=== Starting RV32I Processor Test ===");
        $display("Time\tPC\t\tInstruction\tState");
        $display("----------------------------------------");
        
        // Run for enough cycles to execute all instructions
        #2000;  // 2000ns = plenty of time
        
        $display("----------------------------------------");
        $display("Test completed at time %0t", $time);
        $finish;
    end
    
    // Monitor important signals every clock cycle
    always @(posedge clk) begin
        if (!reset) begin
            $display("%0t\t%h\t%h\t%d", $time, dut.pc, dut.instruction_reg, dut.state);
        end
    end
    
    // Additional monitoring for specific events
    always @(posedge clk) begin
        if (!reset && dut.state == 3'b101) begin // WRITEBACK
            if (dut.reg_write && dut.rdin != 0) begin
                $display("  REG WRITE: x%d = %h", dut.rdin, dut.write_data);
            end
        end
    end
endmodule