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
    output reg [1:0] data_buffer_enable, // 00 IDLE, 01 LOAD, 10 STORE
    output reg [1:0] input_data_latch_enable, // 00 IDLE, 01 LOAD, 10 STORE
    output reg       pc_enable,
    output reg [3:0] alu_enable,
    output reg [2:0] accumulator_enable, // BIT 2 is enable, BIT 1 is R/W_n and BIT 0 is BUS SELECT         
    output reg [2:0] stack_pointer_register_enable, // 0 is light blue and 1 is dark blue.
    output reg [2:0] index_register_X_enable,
    output reg [2:0] index_register_Y_enable
);
//STATES
localparam S_IDLE           = 3'd0;
localparam S_OPCODE_READ    = 3'd1;
localparam S_ZPG_ADR_READ   = 3'd2;
localparam S_IDL_WRITE      = 3'd3;
localparam S_ALU_ZPG        = 3'd4;
localparam S_DBUF_OUTPUT    = 3'd5;
localparam S_ALU_A          = 3'd6;
localparam S_ALU_TMX        = 3'd7;

//BUFFER OPERATIONS
localparam BUF_IDLE_TWO     = 2'b00;
localparam BUF_LOAD_TWO     = 2'b01; // Take from a BUS and keep
localparam BUF_STORE_TWO    = 2'b10; // Put the register value on a BUS
localparam BUF_IDLE_THREE   = 3'b000;
localparam BUF_LOAD1_THREE   = 3'b100; // Take from a BUS and keep
localparam BUF_LOAD2_THREE   = 3'b101; // Take from a BUS and keep
localparam BUF_STORE1_THREE   = 3'b110; // Put the register value on a BUS
localparam BUF_STORE2_THREE   = 3'b111; // Put the register value on a BUS

reg [4:0] STATE      = S_IDLE;
reg [4:0] NEXT_STATE = S_IDLE;
reg [2:0] ADDRESSING;
reg [7:0] OPCODE;



always @(*) begin
    NEXT_STATE = STATE;
    memory_address = 16'b0;
    alu_enable = NOP;
    processor_status_register_write = 7'b0;
    address_select = 1'b0;
    processor_status_register_rw = 1;
    rw = 1;
    data_buffer_enable = BUF_IDLE_TWO;
    input_data_latch_enable = BUF_IDLE_TWO;
    pc_enable = 0;
    accumulator_enable = BUF_IDLE_THREE;
    stack_pointer_register_enable = BUF_IDLE_THREE;
    index_register_X_enable = BUF_IDLE_THREE;
    index_register_Y_enable = BUF_IDLE_THREE;
    case(STATE)
    S_IDLE: begin
        NEXT_STATE = S_OPCODE_READ;
    end
    S_OPCODE_READ: begin
        // In this state, we just need to increment the PC and decide where to go next.
        // The actual loading of OPCODE and ADDRESSING will happen in the clocked block below.
        pc_enable = 1;   // Increment Program Counter
        if(instruction[4:2] == `ADR_ZPG | instruction[4:2] == `ADR_ZPG_X) begin
            NEXT_STATE = S_ZPG_ADR_READ;
        end else if(instruction[4:2] == `ADR_ABS) begin
            NEXT_STATE = S_IDLE;
        end else if(instruction == `ADR_A) begin
            NEXT_STATE = S_ALU_A;   // This is a special case for accumulator operations. All Accumulator operations involve the ALU.
        end else if(instruction == `OP_NOP) begin
            NEXT_STATE = S_IDLE; // NOP is a no-operation, so we just stay idle.
        end else begin
            NEXT_STATE = S_IDLE; // Default case, should not happen.
        end  
    end
    S_ZPG_ADR_READ: begin
        memory_address = instruction; // Puts the memory address read in adh/adl
        address_select = 1;
        if(ADDRESSING == `ADR_ZPG) begin
            NEXT_STATE = S_IDL_WRITE;
        end
        else if(ADDRESSING == `ADR_ZPG_X) begin
            NEXT_STATE = S_IDLE;//TODO
        end
    end
    S_IDL_WRITE: begin
        input_data_latch_enable = BUF_LOAD_TWO;
        if(OPCODE == `OP_ASL_ZPG) begin
            NEXT_STATE = S_ALU_ZPG;
        end    
    end
    S_ALU_ZPG: begin
        input_data_latch_enable = BUF_STORE_TWO;
        processor_status_register_rw = 0;
        if(OPCODE == `OP_ASL_ZPG) begin
            alu_enable  = `ASL;
            processor_status_register_write = `CARRY_FLAG + `ZERO_FLAG + `NEGATIVE_FLAG;
        end
        NEXT_STATE = S_ALU_TMX
    end
    S_ALU_TMX: begin
        alu_enable = `TMX;
        if(ADDRESSING == ADR_ZPG) begin
            data_buffer_enable = BUF_LOAD_TWO;
            NEXT_STATE = S_DBUF_OUTPUT;
        end
        if(ADDRESSING == ADR_A) begin
            accumulator_enable = BUF_LOAD2_THREE;
            NEXT_STATE = S_OPCODE_READ;
        end
    end 
    S_DBUF_OUTPUT: begin
        data_buffer_enable = BUF_STORE_TWO;
        rw = 0;
        NEXT_STATE = S_OPCODE_READ;
    end
    S_ALU_A: begin
        processor_status_register_rw = 0;
        if(OPCODE == `OP_ASL_A) begin
            alu_enable = `ASL;
            processor_status_register_write = `CARRY_FLAG + `ZERO_FLAG + `NEGATIVE_FLAG;
        end
        NEXT_STATE = S_ALU_TMX;
    end
    default: NEXT_STATE = S_IDLE;
    endcase
end

always @(posedge clk ) begin
    if(res) begin
        STATE <= S_IDLE;
        OPCODE <= `OP_NOP;
        ADDRESSING <= 3'b000;
    end else if(rdy) begin
        STATE <= NEXT_STATE;
        if(NEXT_STATE == S_OPCODE_READ) begin
             OPCODE <= instruction;
            if(instruction[4:2] == `ADR_ZPG) begin
                ADDRESSING <= `ADR_ZPG;
            end else if(instruction[4:2] == `ADR_ABS) begin
                ADDRESSING <= `ADR_ABS; // THIS DOES NOT HANDLE JUMP SUBROUTINE (JSR). THAT WILL NEED ITS OWN STATES IN THE SM!!!!
            end else if(instruction == `ADR_A) begin
                ADDRESSING <= `ADR_A;
            end else if (instruction[4:2] == `ADR_ZPG_X) begin
                ADDRESSING <= `ADR_ZPG_X;
            end
        end
    end
end
wire _unused = &{irq, nmi, processor_status_register_read };

endmodule
