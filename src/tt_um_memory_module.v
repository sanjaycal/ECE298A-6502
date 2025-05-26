/*
 * Copyright (c) 2024 Sanjay Jayaram, Sri Charan Tandepalli, Dennis Chen
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_memory_module(
    input wire RW,
    input wire [7:0] mem_addr,
    input wire [7:0] mem_data_in,
    output wire [7:0] mem_data_out,
    input wire clk
);

  reg [7:0] data[2047:0];
  
  always_comb begin
    if (RW) begin
      data[mem_addr] = mem_data_in;
    end
  end
  assign mem_data_out = data[mem_addr];

endmodule
