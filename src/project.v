/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

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
  wire [7:0] instruction;
  wire [7:0] processor_status_register;
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

  clock_generator clockGenerator(clk, clk_cpu, clk_output);
  instruction_decode instructionDecode(
    instruction,
    processor_status_register,
    clk,
    rw,
    input_data_latch_enable,
    pc_enable,
    accumulator_enable,
    alu_enable,
    stack_pointer_register_enable,
    index_register_x_enable,
    index_register_y_enable,
    res,
    irq,
    nmi,
    rdy
  );

  interrupt_logic interruptLogic(clk, res_in, irq_in, nmi_in, res, irq, nmi);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
