`include "../inc/alu_ops.vh"
`include "../inc/status_register.vh"

`default_nettype none

module alu (
    input  wire         clk, // You will need a clock for the registers
    input  wire [3:0]   alu_op,
    input  wire [7:0]   inputA,
    input  wire [7:0]   inputB,
    output reg  [7:0]   ALU_output,       // Make this a 'reg' driven by the sequential block
    output reg  [7:0]   ALU_flags_output  // Make this a 'reg' driven by the sequential block
);

    // --- Combinational "Pre-calculation" Wires ---
    // These calculate the result for every possible operation, all the time.
    wire [7:0] result_asl = inputA << 1;
    wire [7:0] result_rol = {input[6:0], input[7]};
    // wire [7:0] result_adc = inputA + inputB + C_in; // Example for another op

    // --- Combinational Logic for selecting the result and flags ---
    reg [7:0] next_alu_result = 8'b0;
    reg [7:0] next_alu_flags = 8'b0;
    always @(*) begin
        // Start with safe defaults

        case(alu_op)
            `ASL: begin
                // Select the pre-calculated result
                next_alu_result = result_asl;
                // Set flags based on the inputs and the result
                next_alu_flags[`CARRY_FLAG]    = inputA[7];
                next_alu_flags[`ZERO_FLAG]     = (result_asl == 8'b0);
                next_alu_flags[`NEGATIVE_FLAG] = result_asl[7];
            end
            `ROL: begin
                // Select the pre-calculated result
                next_alu_result = result_rol;
                // Set flags based on the inputs and the result
                next_alu_flags[`CARRY_FLAG]    = inputA[7];
                next_alu_flags[`ZERO_FLAG]     = (result_rol == 8'b0);
                next_alu_flags[`NEGATIVE_FLAG] = result_rol[7];
            end
            // `ADC: begin ... end // Example for another op
            // If need be add a condition that checks for tmx
            default: begin
                next_alu_result = 8'b0;
                next_alu_flags = 8'b0;
            end
        endcase
    end



    always @(posedge clk) begin
        ALU_output <= next_alu_result;
        ALU_flags_output <= next_alu_flags; 
    end


    wire _unused = &{inputB};

endmodule