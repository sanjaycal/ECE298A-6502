/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`include "../src/clock_generator.v"
`include "../src/instruction_decode.v"
`include "../src/interrupt_logic.v"

`default_nettype none

module tt_um_6502 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire index_register_y_enable;
  wire index_register_x_enable;
  wire stack_pointer_register_enable;
  wire alu_enable;
  wire accumulator_enable;
  wire pc_enable;
  wire input_data_latch_enable;
  wire rdy = 1;
  wire rw;
  wire dbe;
  wire res_in;
  wire irq_in;
  wire nmi_in;
  wire res;
  wire irq;
  wire nmi;
  wire clk_cpu;
  wire clk_output;
  wire address_select;
  wire data_buffer_enable;
  wire data_buffer_direction;
  wire processor_status_register_rw;
  wire [6:0] processor_status_register_read;
  wire [6:0] processor_status_register_write;


  reg [7:0] address_register = 0;
  reg [7:0] abl;
  reg [7:0] abh;

  reg [7:0] data_register;
  wire [7:0] data_flags = 0; //data_flags[0]=RW, 0 is read, 1 is write
  reg [7:0] data_bus_buffer;

  reg [15:0] pc;
  reg [15:0] memory_address;
  reg [7:0] accumulator;
  reg [7:0] index_register_x;
  reg [7:0] index_register_y;
  reg [7:0] instruction_register;
  reg [6:0] processor_status_register;

  clock_generator clockGenerator(clk, clk_cpu, clk_output);
  instruction_decode instructionDecode(
    instruction_register,
    clk,
    res,
    irq,
    nmi,
    rdy,
    processor_status_register_read,
    processor_status_register_write,
    memory_address,
    address_select,
    processor_status_register_rw,
    rw,
    data_buffer_enable,
    data_buffer_direction,
    input_data_latch_enable,
    pc_enable,
    accumulator_enable,
    alu_enable,
    stack_pointer_register_enable,
    index_register_x_enable,
    index_register_y_enable
  );

  interrupt_logic interruptLogic(clk, res_in, irq_in, nmi_in, res, irq, nmi);


  always @(posedge clk_output) begin
    if (rst_n == 0) begin
      pc = 0;
      abl = 0;
      abh = 0;
      accumulator = 0;
      index_register_x = 0;
      index_register_y = 0;
      instruction_register = 0;
      processor_status_register = 0;
      if(clk_cpu) begin
        address_register = abh; 
      end else begin
        address_register = abl; 
      end
    end else begin
      if(clk_cpu) begin
        if(data_flags[0]==0) begin
          data_bus_buffer = uio_in;
          instruction_register = uio_in;
        end
        data_register = data_bus_buffer; 

        if(address_select) begin
          abl = memory_address[7:0];
          abh = memory_address[15:8];
          abl = instruction_register;
        end

        //deal with PC stuff
        if(pc_enable) begin
          pc = pc + 1;
          abl = pc[7:0];
          abh = pc[15:8];
        end


        address_register = abh; 
      end else begin
        address_register <= abl; 
        data_register <= data_flags;
      end
    end
  end

  // List all unused inputs to prevent warnings
  assign dbe = 0;
  assign irq_in = 0;
  assign nmi_in = 0;
  assign res_in = 0;
  assign processor_status_register_read = processor_status_register;
  wire _unused = &{ena, 1'b0, ui_in, index_register_y_enable, index_register_x_enable, alu_enable, accumulator_enable, pc_enable, input_data_latch_enable, dbe, accumulator, index_register_x, index_register_y, stack_pointer_register_enable, address_select, data_buffer_enable, data_buffer_direction, processor_status_register_rw, processor_status_register_read, processor_status_register_write, memory_address, rw};

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = address_register;
  assign uio_out = data_register;
  assign uio_oe  = 0;
endmodule
