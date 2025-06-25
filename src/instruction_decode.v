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
    output reg       data_buffer_enable,
    output reg       data_buffer_direction, // 1 for internal, 0 for external
    output reg       input_data_latch_enable,
    output reg       pc_enable,
    output reg       accumulator_enable,
    output reg [2:0] alu_enable,
    output reg       stack_pointer_register_enable,
    output reg       index_register_X_enable,
    output reg       index_register_Y_enable
);

localparam T_0 = 3'd0;
localparam T_1 = 3'd1;
localparam T_2 = 3'd2;
localparam T_3 = 3'd3;
localparam T_4 = 3'd4;
localparam T_5 = 3'd5;
localparam T_6 = 3'd6;

reg [2:0] STATE = 0;
reg [2:0] ADDRESSING;
reg [7:0] OPCODE;


always @(*) begin
    processor_status_register_write = 1;
    address_select = 1;
    processor_status_register_rw = 1;
    rw = 1;
    data_buffer_enable = 0;
    data_buffer_direction = 1; 
    input_data_latch_enable = 0;
    pc_enable = 0;
    accumulator_enable = 0;
    alu_enable = `NOP;
    stack_pointer_register_enable = 0;
    index_register_X_enable = 0;
    index_register_Y_enable = 0;
    memory_address = 0;

    case(STATE)
    T_0: begin
        OPCODE = instruction;
        if((instruction & 8'b00011100) == {3'b000,`ADR_ZPG,2'b00}) begin
            ADDRESSING = `ADR_ZPG;
        end
        pc_enable = 1;   // Increment Program Counter  
    end
    T_1: begin
        if(ADDRESSING == `ADR_ZPG) begin
            memory_address = instruction; // Puts the memory address read in adh/adl
            address_select = 1;
        end
    end
    T_2: begin
        if(OPCODE == `OP_ASL_ZPG) begin 
            data_buffer_direction = 1; //read from memory
            data_buffer_enable = 1;
        end    
    end
    T_3: begin
        if(OPCODE == `OP_ASL_ZPG) begin
            alu_enable  = `ASL;// replace with a generic condition that enables ALU
            processor_status_register_rw = 0;

        end
    end
    T_4: begin
        if(OPCODE == `OP_ASL_ZPG) begin
            alu_enable = `ASL;
            data_buffer_enable = 1;
            data_buffer_direction = 0; //write to memory
            rw = 0;
        end
    end
    endcase
end

always @(posedge clk ) begin
    if(rdy) begin
        case(STATE) // Most likely state transitions are going to be happening in the 
                    // combinational block as we add more instructions (state <= next_state)
        T_0: STATE <= T_1;
        T_1: STATE <= T_2;
        T_2: STATE <= T_3;
        T_3: STATE <= T_4;
        T_4: STATE <= T_5;
        T_5: STATE <= T_6;
        T_6: STATE <= T_0;
        endcase
    end    
end

wire _unused = &{res, irq, nmi, processor_status_register_read };

endmodule
