`include "../inc/opcode.vh"
`default_nettype none

module instruction_decode (
    input  wire [7:0] instruction,
    input  wire [7:0] processor_status_register,
    input  wire       clk,
    input  wire       rw,
    output  wire       input_data_latch_enable,
    output  wire       pc_enable,
    output  wire       accumulator_enable,
    output  wire       alu_enable,
    output  wire       stack_pointer_register_enable,
    output  wire       index_register_X_enable,
    output  wire       index_register_Y_enable,
    input  wire       res,
    input  wire       irq,
    input  wire       nmi,
    input  wire       rdy
);

reg [1:0] countdown = 1;
wire [1:0] countdown_next;

reg [7:0] OPCODE;


always @(*) begin
    countdown_next = countdown - 1;
    if(countdown_next == 0) begin
        OPCODE = instruction;
        case(instruction)
            `OP_ALS_ZPG : countdown_next <= 2; 
        endcase
    end    
end

always @(posedge clk ) begin
    countdown <= countdown_next;
end
endmodule
