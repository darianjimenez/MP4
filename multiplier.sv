module multiplier (
    input logic clk,
    input logic reset,
    input logic start,
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [2:0] funct3, // MUL, MULH, MULHSU, MULHU
    output logic [31:0] result,
    output logic done
);

// opcodes based on funct3
localparam MUL = 3'b000;    // lower bits of signed x signed
localparam MULH = 3'b001;   // upper bits of signed x signed
localparam MULHSU = 3'b010; // upper bits of signed x unsigned
localparam MULHU = 3'b011;  // upper bits of unsigned x unsigned

// internal registers
logic [63:0] product_register;
logic [1:0]  state;
logic [31:0] multiplicand;
logic [31:0] multiplier;
logic signed_mul; 

//states

localparam IDLE = 2'b00;
localparam MULTIPLY = 2'b01;
localparam DONE = 2'b10;

always_ff @(posedge clk) begin
    if (reset) begin
        state <= IDLE;
        done <= 1'b0;
        result <= 32'b0;
        product_register <= 64'b0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    case (funct3)
                        MUL, MULH: begin
                            //signed x signed
                            multiplicand <= $signed(rs1);
                            multiplier <= $signed(rs2);
                            signed_mul <= 1'b1;
                        end
                        MULHSU: begin
                            //signed x unsigned
                            multiplicand <= $signed(rs1);
                            multiplier <= rs2;
                            signed_mul <= 1'b0;
                        end
                        MULHU: begin
                            //unsigned x unsigned
                            multiplicand <= rs1;
                            multiplier <= rs2;
                            signed_mul <= 1'b0;
                        end
                        default: begin // default signed
                            multiplicand <= $signed(rs1);
                            multiplier <= $signed(rs2);
                            signed_mul <= 1'b1;
                        end
                    endcase
                    state <= MULTIPLY;
                    done <= 1'b0;
                end
            end

            MULTIPLY: begin
                // perform 32x32 multiplication
                if (signed_mul) begin
                    product_register <= $signed(multiplicand)  * $signed(multiplier);
                end else if (funct3 == MULHSU) begin
                    // rs1 is signed, rs2 is unsigned
                    if (multiplicand[31]) begin
                        //rs1 is negative, so sign extend it
                        product_register <= $signed({{32{multiplicand[31]}}, multiplicand[31:0]} * multiplier);
                    end else begin
                        // rs1 is positive
                        product_register <= (multiplicand * multiplier);
                    end
                end else begin
                    // both rs1 and rs2 are unsigned
                    product_register <= multiplicand * multiplier;
                end
                state <= DONE;
            end
            DONE: begin
                // select correct 32 bits of product based on funct3
                case (funct3)
                    MUL: result <= product_register[31:0];
                    MULH, MULHSU, MULHU: result <= product_register[63:32];
                    default: result <= product_register[31:0];
                endcase
                done <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end
endmodule