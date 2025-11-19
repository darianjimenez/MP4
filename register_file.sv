module register_file (
    input  logic        clk,
    input  logic        wren,

    input  logic [4:0]  rs1in,
    input  logic [4:0]  rs2in,
    input  logic [4:0]  rdin,

    input  logic [31:0] rd_data_in, // Data to write into the register

    output logic [31:0] rs1out,
    output logic [31:0] rs2out
);

    // 32 registers of 32 bits each
    // Register 0 is hardwired to zero
    logic [31:0] regs [31:0];

    // Combinational read operation
    // x0 is always zero
    assign rs1out = (rs1in == 5'd0) ? 32'd0 : regs[rs1in];
    assign rs2out = (rs2in == 5'd0) ? 32'd0 : regs[rs2in];

    // Synchronous write operation
    always_ff @(posedge clk) begin
        if (wren && (rdin != 5'd0))
            regs[rdin] <= rd_data_in; // Write data to register
    end

endmodule