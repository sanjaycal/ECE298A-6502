# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def hex_to_num(hex_string):
    vals = {
        "0": 0,
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "a": 10,
        "b": 11,
        "c": 12,
        "d": 13,
        "e": 14,
        "f": 15,
    }
    return vals[hex_string[0]] * 16 + vals[hex_string[1]]


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 9)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    # assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.


@cocotb.test()
async def test_ASL_ZPG(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test ASL zeropage behaviour")
    # Write the instructions to the data bus that is being read from
    # ASL oper is 06 oper

    # check that instructions are being read and that the PC is incrementing
    dut.uio_in.value = hex_to_num("06")
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 1  # last bit should be 1 for read
    assert dut.uo_out.value == 1

    # tell it to read from memory address 0x0066
    dut.uio_in.value = hex_to_num("66")
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 1  # last bit should be 1 for read
    assert dut.uo_out.value == hex_to_num("66")

    # when it tries to read from 0x0066 it should get 69 as the value
    dut.uio_in.value = 69
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0  # this shouldn't change though
    await ClockCycles(dut.clk, 1)
    # we arent trying to read at this time, so it doesnt matter

    # now we write from the ALU to the data bus buffer
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0
    await ClockCycles(dut.clk, 1)
    # we arent trying to read at this time, so it doesnt matter

    # now we output 34(currently in the data buffer) to 0x066
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0  # check if we're outputting to 0x0066
    assert dut.uio_oe.value == hex_to_num("ff")  # check if we are otuputting
    assert dut.uio_out.value == 138  # check the output
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0  # last bit should be 0 for write
    assert dut.uo_out.value == hex_to_num("66")  # check if we're outputting to 0x0066
