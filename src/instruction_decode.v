`include "../inc/opcode.vh"
`include "../inc/status_register.vh"
`default_nettype none

module instruction_decode (
    input  wire [7:0] instruction,
    input  wire [6:0] processor_status_register,
    input  wire       clk,
    input  wire       rw,
    input  wire       res,
    input  wire       irq,
    input  wire       nmi,
    input  wire       rdy,
    output wire [6:0] processor_status_register_enables,      
    output wire       input_data_latch_enable,
    output wire       pc_enable,
    output wire       accumulator_enable,
    output wire       alu_enable,
    output wire       stack_pointer_register_enable,
    output wire       index_register_X_enable,
    output wire       index_register_Y_enable
);

localparam T_0 = 3'd0;
localparam T_1 = 3'd1;
localparam T_2 = 3'd2;
localparam T_3 = 3'd3;
localparam T_4 = 3'd4;
localparam T_5 = 3'd5;
localparam T_6 = 3'd6;

reg [2:0] STATE;
reg [2:0] ADDRESSING;
reg [7:0] OPCODE;


always @(*) begin
    case(STATE)
    T_0: begin
        OPCODE = instruction;
        if((instruction & 8'b00011100) == 8'b000_001_00) begin
            ADDRESSING = `ADR_ZPG;
        end
    end
    endcase
end

always @(posedge clk ) begin
    case(STATE)
    T_0: STATE <= T_1;
    T_1: STATE <= T_2;
    T_2: STATE <= T_3;
    T_3: STATE <= T_4;
    T_4: STATE <= T_5;
    T_5: STATE <= T_6;
    T_6: STATE <= T_0;
    default: STATE <= T_0;
    endcase
end
endmodule
