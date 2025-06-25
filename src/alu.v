`include "../inc/alu_ops.vh"

`default_nettype none

module alu (
    input  wire [2:0]   alu_op,
    input  wire [7:0]   inputA,
    input  wire [7:0]   inputB,
    output wire [7:0] ALU_output
);

    reg [7:0] output;

always @(*) begin
    case(alu_op)
        NOP: output = 0;
        ASL: output = inputA << 1;
        default: output = 0;
    endcase
end

assign ALU_output = output;

endmodule
