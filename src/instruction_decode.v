
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

endmodule
