`include "../inc/alu_ops.vh"
`include "../inc/status_register.vh"

`default_nettype none

module alu (
    input  wire [2:0]   alu_op,
    input  wire [7:0]   inputA,
    input  wire [7:0]   inputB,
    output wire [7:0]   ALU_output,
    output wire [7:0]   ALU_flags_output,
);

    reg [7:0] ALU_buffer = 0;
    reg [7:0] ALU_flags_buffer = 0;

    always @(*) begin
        ALU_buffer = 0;
        case(alu_op)
            `ASL: 
                ALU_flags_buffer[`CARRY_FLAG] = inputA[7];
                ALU_flags_buffer[`ZERO_FLAG] = ~|inputA;
                ALU_flags_buffer[`NEGATIVE_FLAG] = inputA[6];

                ALU_buffer = inputA << 1;
            default: ALU_buffer = 0;
        endcase
    end

    assign ALU_output = ALU_buffer;
    assign ALU_flags_output = ALU_flags_buffer;

endmodule
