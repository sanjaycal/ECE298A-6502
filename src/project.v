/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`include "../src/clock_generator.v"
`include "../src/instruction_decode.v"
`include "../src/interrupt_logic.v"
`include "../src/alu.v"

`include "../inc/buf_instructions.vh"

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

  wire [2:0] index_register_y_enable;
  wire [2:0] index_register_x_enable;
  wire [2:0] stack_pointer_register_enable;
  wire [2:0] ALU_op;
  wire [2:0] accumulator_enable;
  wire pc_enable;
  wire [1:0] input_data_latch_enable;
  wire rdy;
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
  wire [1:0] data_buffer_enable;
  wire processor_status_register_rw;
  wire [6:0] processor_status_register_read;
  wire [6:0] processor_status_register_write;


  wire [15:0] ab;

  reg [7:0] input_data_latch;
  wire [7:0] internal_data_bus;
  wire [7:0] alu_output_bus;
  reg [7:0] data_bus_buffer=255;

  reg [15:0] pc;
  wire [15:0] memory_address;
  reg [7:0] accumulator;
  reg [7:0] index_register_x;
  reg [7:0] index_register_y;
  wire [7:0] instruction_register;
  reg [6:0] processor_status_register;

  wire [7:0] ALU_inputA;
  reg [7:0] ALU_inputB;

  wire [7:0] ALU_output;
  wire [7:0] ALU_flags_output;

  clock_generator clockGenerator(clk, clk_cpu, clk_output);
  instruction_decode instructionDecode(
    .instruction                   (instruction_register),
    .clk                           (clk_cpu),
    .res                           (res),
    .irq                           (irq),
    .nmi                           (nmi),
    .rdy                           (rdy),
    .processor_status_register_read(processor_status_register_read),
    .processor_status_register_write(processor_status_register_write),
    .memory_address                (memory_address),
    .address_select                (address_select),
    .processor_status_register_rw  (processor_status_register_rw),
    .rw                            (rw),
    .data_buffer_enable            (data_buffer_enable),
    .input_data_latch_enable       (input_data_latch_enable), 
    .pc_enable                     (pc_enable),
    .accumulator_enable            (accumulator_enable),
    .alu_enable                    (ALU_op),  
    .stack_pointer_register_enable (stack_pointer_register_enable),
    .index_register_X_enable       (index_register_x_enable),
    .index_register_Y_enable       (index_register_y_enable)
  );
  
  alu ALU(
    ALU_op,
    ALU_inputA,
    ALU_inputB,
    ALU_output,
    ALU_flags_output
  );

  interrupt_logic interruptLogic(clk, res_in, irq_in, nmi_in, res, irq, nmi);


  always @(posedge clk_cpu) begin
    if (rst_n == 0) begin
      pc <= 1;
      accumulator <= 0;
      index_register_x <= 0;
      index_register_y <= 0;
      processor_status_register <= 0;
    end else begin
      data_bus_buffer <= (data_buffer_enable!=2'b01)?
                          alu_output_bus:
                          data_bus_buffer;

      input_data_latch <= (input_data_latch_enable!=2'b01)?instruction_register:input_data_latch;


      if (pc_enable) begin
        pc <= pc+1;
      end

    end
  end

  // List all unused inputs to prevent warnings
  assign dbe = 0;
  assign irq_in = 0;
  assign nmi_in = 0;
  assign res_in = 0;
  assign processor_status_register_read = processor_status_register;
  wire _unused = &{ena, 1'b0, ui_in, index_register_y_enable, index_register_x_enable, accumulator_enable, input_data_latch_enable, dbe, accumulator, index_register_x, index_register_y, stack_pointer_register_enable, processor_status_register_rw, processor_status_register_read, processor_status_register_write, clk_output, ALU_flags_output};

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = clk_cpu?ab[7:0]:ab[15:8];
  assign uio_out = clk_cpu?{7'b0, rw}:data_bus_buffer;
  assign uio_oe  = clk_cpu?8'h1:(rw?8'hff:8'h00);

  assign instruction_register = uio_in;
  assign ALU_inputA = internal_data_bus;

  assign ab = pc_enable?pc:(address_select?memory_address:11);

  assign alu_output_bus = ALU_output;
  assign internal_data_bus = (input_data_latch_enable!=2)?input_data_latch:
                              0;

  assign rdy = rst_n;
endmodule
