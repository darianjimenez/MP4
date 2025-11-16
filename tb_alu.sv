module tb_alu();
    logic clk;
    logic [31:0] alu_in1, alu_in2;
    logic [2:0] alu_op;
    logic [31:0] alu_out;
    logic zero, less_than, less_than_unsigned;
    
    alu dut (
        .clk(clk),
        .alu_in1(alu_in1),
        .alu_in2(alu_in2), 
        .alu_op(alu_op),
        .alu_out(alu_out),
        .zero(zero),
        .less_than(less_than),
        .less_than_unsigned(less_than_unsigned)
    );

    always #5 clk = ~clk;
    
    initial begin
        $display("=== ALU TEST STARTED ===");
        clk = 0;
        @(posedge clk);

        // Test 1: ADDITION
        alu_in1 = 32'd10;
        alu_in2 = 32'd20;
        alu_op = 3'b000; // ADD
        @(posedge clk);
        #1;
        $display("ADD: %0d + %0d = %0d, zero=%0d", alu_in1, alu_in2, alu_out, zero);
        
        // Test 2: SUBTRACTION  
        alu_in1 = 32'd50;
        alu_in2 = 32'd30;
        alu_op = 3'b001; // SUB
        @(posedge clk);
        #1;
        $display("SUB: %0d - %0d = %0d, zero=%0d", alu_in1, alu_in2, alu_out, zero);
        
        // Test 3: AND
        alu_in1 = 32'hFFFF0000;
        alu_in2 = 32'h0000FFFF;
        alu_op = 3'b010; // AND
        @(posedge clk);
        #1;
        $display("AND: %h & %h = %h", alu_in1, alu_in2, alu_out);
        
        // Test 4: OR
        alu_in1 = 32'hFF00FF00;
        alu_in2 = 32'h00FF00FF;
        alu_op = 3'b011; // OR
        @(posedge clk);
        #1;
        $display("OR:  %h | %h = %h", alu_in1, alu_in2, alu_out);
        
        // Test 5: Signed Comparison (less than)
        alu_in1 = 32'd5;
        alu_in2 = 32'd10;
        alu_op = 3'b001; // SUBTRACT for comparison
        @(posedge clk);
        #1;
        $display("COMPARE: %0d < %0d? signed=%0d, unsigned=%0d", 
                 alu_in1, alu_in2, less_than, less_than_unsigned);
        
        // Test 6: Negative numbers comparison
        alu_in1 = 32'hFFFFFFFE; // -2 in two's complement
        alu_in2 = 32'd1;        // 1
        alu_op = 3'b001; // SUBTRACT
        @(posedge clk);
        #1;
        $display("COMPARE: -2 < 1? signed=%0d, unsigned=%0d", 
                 less_than, less_than_unsigned);
        
        // Test 7: Shift left
        alu_in1 = 32'h0000000F; // 15
        alu_in2 = 32'd2;        // shift by 2
        alu_op = 3'b101; // SLL
        @(posedge clk);
        #1;
        $display("SLL: %h << %0d = %h", alu_in1, alu_in2, alu_out);
        
        $display("=== ALU TEST COMPLETED ===");
        $finish;
    end
endmodule