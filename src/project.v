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

  wire [7:0] mem_data_in;
  wire [7:0] mem_data_out;
  wire [7:0] mem_addr;
  wire index_register_y_enable;
  wire index_register_x_enable;
  wire stack_pointer_register_enable;
  wire alu_enable;
  wire accumulator_enable;
  wire pc_enable;
  wire input_data_latch_enable;
  wire rdy;
  wire rw;
  wire dbe;
  wire res_in;
  wire irq_in;
  wire nmi_in;
  wire res;
  wire irq;
  wire nmi;
  wire [7:0] internal_adh;
  wire [7:0] internal_adl;
  wire [7:0] data_bus;
  wire [7:0] internal_data_bus;
  wire clk_cpu;
  wire clk_output;
  wire [6:0] processor_status_register_enables;


  reg [7:0] address_register = 0;
  reg [7:0] abl;
  reg [7:0] abh;

  reg [7:0] data_register;
  wire [7:0] data_flags = 0; //data_flags[0]=RW, 0 is read, 1 is write
  reg [7:0] data_bus_buffer;

  reg [15:0] pc;
  reg [7:0] accumulator;
  reg [7:0] stack_point_register;
  reg [7:0] index_register_x;
  reg [7:0] index_register_y;
  reg [7:0] instruction_register;
  reg [6:0] processor_status_register;

  clock_generator clockGenerator(clk, clk_cpu, clk_output);
  instruction_decode instructionDecode(
    instruction_register,
    processor_status_register,
    clk,
    rw,
    res,
    irq,
    nmi,
    rdy,
    processor_status_register_enables,
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
      pc <= 0;
      abl <= 0;
      abh <= 0;
      accumulator <= 0;
      stack_point_register <= 0;
      index_register_x <= 0;
      index_register_y <= 0;
      instruction_register <= 0;
      processor_status_register <= 0;
      if(clk_cpu) begin
        address_register <= abh; 
      end else begin
        address_register <= abl; 
      end
    end else begin
      if(clk_cpu) begin
        if(data_flags[0]==0) begin
          data_bus_buffer <= uio_in;
          instruction_register <= uio_in;
        end
        data_register <= data_bus_buffer; 

        //deal with PC stuff
        pc <= pc + 1;
        abl <= pc[7:0]+1;
        abh <= pc[15:8];

        address_register <= abh; 
      end else begin
        address_register <= abl; 
        data_register <= data_flags;
      end
    end
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = address_register;
  assign uio_out = data_register;
  assign uio_oe  = 0;
endmodule
