module alu(
    input logic [31:0] alu_in1,
    input logic [31:0] alu_in2,
    input logic [2:0] alu_op,
    output logic [31:0] alu_out,
    output logic zero, less_than, less_than_unsigned
);

    always_comb begin
        case (alu_op)
            3'b000: alu_out = alu_in1 + alu_in2; // add
            3'b001: alu_out = alu_in1 - alu_in2; // subtract
            3'b010: alu_out = alu_in1 & alu_in2; // AND
            3'b011: alu_out = alu_in1 | alu_in2; // OR  
            3'b100: alu_out = alu_in1 ^ alu_in2; // XOR
            3'b101: alu_out = alu_in1 << alu_in2[4:0]; // shift left
            3'b110: alu_out = alu_in1 >> alu_in2[4:0]; // shift right logic
            3'b111: alu_out = $signed(alu_in1) >>> alu_in2[4:0]; // shift right arith
            default: alu_out = 32'b0;
        endcase
    end

    assign zero = (alu_out == 32'b0);
    assign less_than = ($signed(alu_in1) < $signed(alu_in2));
    assign less_than_unsigned = (alu_in1 < alu_in2);

endmodule