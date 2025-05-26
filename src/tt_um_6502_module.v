/*
 * Copyright (c) 2024 Sanjay Jayaram, Sri Charan Tandepalli, Dennis Chen
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_6502_module(
    input  wire [7:0] data_in, 
    input  wire [7:0] instruction_in,
    output wire [7:0] mem_addr,
    output wire [7:0] mem_data_in,
    input  wire [7:0] mem_data_out,
    input wire clk
);

  reg [7:0] A;
  reg [7:0] X,Y;
  reg [15:0] PC;
  reg [7:0] S;
  reg [5:0] P;
  
  assign mem_addr = data_in;
  assign mem_data_in = instruction_in;

endmodule
