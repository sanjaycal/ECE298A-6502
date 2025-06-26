`include "../inc/opcode.vh"
`include "../inc/status_register.vh"

`include "../inc/alu_ops.vh"

`default_nettype none

module instruction_decode (
    input  wire [7:0] instruction,
    input  wire       clk,
    input  wire       res,
    input  wire       irq,
    input  wire       nmi,
    input  wire       rdy,
    input  wire [6:0] processor_status_register_read,
    output reg [6:0] processor_status_register_write,        
    output reg [15:0] memory_address,  // better name for this
    output reg       address_select,
    output reg       processor_status_register_rw,
    output reg       rw, //1 for read, 0 for write
    output reg [1:0] data_buffer_enable, // 00 IDLE, 01 STORE, 02 LOAD
    output reg [1:0] input_data_latch_enable, // ^
    output reg       pc_enable,
    output reg       accumulator_enable,
    output reg [2:0] alu_enable,
    output reg       stack_pointer_register_enable,
    output reg       index_register_X_enable,
    output reg       index_register_Y_enable
);

localparam S_IDLE           = 3'd0;
localparam S_OPCODE_READ    = 3'd1;
localparam S_ZPG_ADR_READ   = 3'd2;
localparam S_IDL_WRITE = 3'd3;
localparam S_ALU_ZPG = 3'd4;
localparam S_DBUF_OUTPUT = 3'd5;
localparam T_6 = 3'd6;

reg [4:0] STATE = 0;
reg [4:0] NEXT_STATE = 0;
reg [2:0] ADDRESSING;
reg [7:0] OPCODE;


always @(*) begin
    NEXT_STATE = STATE;

    processor_status_register_write = 1;
    address_select = 1;
    processor_status_register_rw = 1;
    rw = 1;
    data_buffer_enable = 2'b00;
    input_data_latch_enable = 2'b00;
    pc_enable = 0;
    accumulator_enable = 0;
    alu_enable = `NOP;
    stack_pointer_register_enable = 0;
    index_register_X_enable = 0;
    index_register_Y_enable = 0;
    memory_address = 0;
    case(STATE)
    S_IDLE: begin
        NEXT_STATE = S_OPCODE_READ;
    end
    S_OPCODE_READ: begin
        OPCODE = instruction;
        case(OPCODE)
        (OPCODE[4:2] == `ADR_ZPG): begin
            ADDRESSING = `ADR_ZPG;
            NEXT_STATE = S_ZPG_ADR_READ;
        end
        (OPCODE[4:2] == `ADR_ABS): begin
            ADDRESSING = `ADR_ABS; // THIS DOES NOT HANDLE JUMP SUBROUTINE (JSR). THAT WILL NEED ITS OWN STATES IN THE SM!!!!
        end
        (OPCODE == `ADR_A): begin
            ADDRESSING = `ADR_A;
        end
        endcase
        pc_enable = 1;   // Increment Program Counter  
    end
    S_ZPG_ADR_READ: begin
        memory_address = instruction; // Puts the memory address read in adh/adl
        address_select = 1;
        if(ADDRESSING == `ADR_ZPG) begin
            NEXT_STATE = S_DBUF_WRITE_EXT;
        end
    end
    S_IDL_WRITE: begin
        input_data_latch_enable = 2'b01;
        if(OPCODE == `OP_ASL_ZPG) begin
            NEXT_STATE = S_ALU_ZPG;
        end    
    end
    S_ALU_ZPG: begin
        if(OPCODE == `OP_ASL_ZPG) begin
            alu_enable  = `ASL;
            input_data_latch_enable = 2'b10;
            data_buffer_enable = 2'b01;
            processor_status_register_rw = 0;
            NEXT_STATE = S_DBUF_OUTPUT;
        end
    end
    S_DBUF_OUTPUT: begin
        data_buffer_enable = 2'b10;
        rw = 0;
        NEXT_STATE = S_OPCODE_READ;
    end
    endcase
end

always @(posedge clk ) begin
    if(rdy) begin
        STATE <= NEXT_STATE;
    end    
end

wire _unused = &{res, irq, nmi, processor_status_register_read };

endmodule
