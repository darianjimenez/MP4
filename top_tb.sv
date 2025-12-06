`timescale 1ns/1ps

module top_tb;
    // Testbench signals
    logic clk, reset;
    logic LED, RGB_R, RGB_G, RGB_B;
    
    // Instantiate the processor
    top dut (
        .clk(clk),
        .reset(reset),
        .LED(LED),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        // Initialize waveform dump
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        
        // Force PC initialization
        dut.pc = 32'h00001000;
        
        // Apply reset
        reset = 1;
        #200;
        reset = 0;
        
        // Run simulation for sufficient time
        #50000;  // 50,000 ns
        
        $finish;
    end
    
    // Safety timeout
    initial begin
        #100000;  // 100,000 ns absolute timeout
        $finish;
    end
endmodule