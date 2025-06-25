`include "../inc/alu_ops.vh"

`default_nettype none

module alu (
    input  wire [2:0]   alu_op,
    input  wire [7:0]   inputA,
    input  wire [7:0]   inputB,
    output wire [7:0]   ALU_output
);

    reg [7:0] ALU_buffer = 0;

    always @(*) begin
        ALU_buffer = 0;
        case(alu_op)
            `ASL: ALU_buffer = inputA << 1;
            default: ALU_buffer = 0;
        endcase
    end

    assign ALU_output = ALU_buffer;

endmodule
