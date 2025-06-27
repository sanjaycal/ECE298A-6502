`include "../inc/alu_ops.vh"
`include "../inc/status_register.vh"

`default_nettype none

module alu (
    input  wire [2:0]   alu_op,
    input  wire [7:0]   inputA,
    input  wire [7:0]   inputB,
    output wire [7:0]   ALU_output,
    output wire [7:0]   ALU_flags_output
);

    reg [7:0] ALU_flags_buffer = 0;

    always @(*) begin
        case(alu_op)
            `ASL: begin
                ALU_flags_buffer[`CARRY_FLAG] = inputA[7];
                ALU_flags_buffer[`ZERO_FLAG] = 0; //TODO FIX THIS
                ALU_flags_buffer[`NEGATIVE_FLAG] = inputA[6];
            end
            default: ALU_flags_buffer = 0;
        endcase
    end

    assign ALU_output = (alu_op==`ASL) ? 0:
                        (inputA<<1);
    assign ALU_flags_output = ALU_flags_buffer;

endmodule
