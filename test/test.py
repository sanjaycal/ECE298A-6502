# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import random


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


async def reset_cpu(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # now we run a nop so that our pc actually increments
    dut.uio_in.value = hex_to_num("ea")
    await ClockCycles(dut.clk, 2)
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)


async def run_zpg_instruction(
    dut, opcode, addr_LB, starting_PC, input_value, output_value, enable_pc_checks=True
):
    # feed in the opcode
    dut.uio_in.value = opcode
    await ClockCycles(dut.clk, 1)
    if enable_pc_checks:
        assert dut.uo_out.value == starting_PC
    assert dut.uio_out.value % 2 == 1  # last bit should be 1 for read
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    # feed in the addr to read from
    dut.uio_in.value = addr_LB
    await ClockCycles(dut.clk, 1)
    if enable_pc_checks:
        assert dut.uo_out.value == starting_PC + 1
    assert dut.uio_out.value % 2 == 1  # last bit should be 1 for read
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    # feed in the data we want to operate on
    dut.uio_in.value = input_value
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == addr_LB
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0  # this shouldn't change though

    # wait for the ALU to get the data
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)

    # wait for data bus buffer to get the data
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)

    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == output_value  # check the value
    assert dut.uio_oe.value == hex_to_num("ff")  # check if we are outputting
    assert dut.uo_out.value == 0  # check the page we are writing to

    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value % 2 == 0  # last bit should be 0 for write
    assert dut.uo_out.value == addr_LB  # check the mem addr we are writing to
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 2)


async def run_abs_instruction(
    dut,
    opcode,
    addr_HB,
    addr_LB,
    starting_PC,
    input_value,
    output_value,
    enable_pc_checks=True,
):
    # feed in the opcode
    dut.uio_in.value = opcode
    await ClockCycles(dut.clk, 1)
    if enable_pc_checks:
        assert dut.uo_out.value == starting_PC
    assert dut.uio_out.value % 2 == 1  # last bit should be 1 for read
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    # feed in the addr_LB to read from
    dut.uio_in.value = addr_LB
    await ClockCycles(dut.clk, 1)
    if enable_pc_checks:
        assert dut.uo_out.value == starting_PC + 1
    assert dut.uio_out.value % 2 == 1  # last bit should be 1 for read
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    # feed in the addr_HB to read from
    dut.uio_in.value = addr_HB
    await ClockCycles(dut.clk, 1)
    if enable_pc_checks:
        assert dut.uo_out.value == starting_PC + 2
    assert dut.uio_out.value % 2 == 1  # last bit should be 1 for read
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == addr_HB

    # feed in the data we want to operate on
    dut.uio_in.value = input_value
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == addr_LB
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0  # this shouldn't change though

    # wait for the ALU to get the data
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)

    # wait for data bus buffer to get the data
    dut.uio_in.value = hex_to_num("00")
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)

    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == output_value  # check the value
    assert dut.uio_oe.value == hex_to_num("ff")  # check if we are outputting
    assert dut.uo_out.value == addr_HB  # check the page we are writing to

    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value % 2 == 0  # last bit should be 0 for write
    assert dut.uo_out.value == addr_LB  # check the mem addr we are writing to
    await ClockCycles(dut.clk, 1)
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_ASL_ZPG_Clear(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # test instruction on it's own
    for test_num in range(256):
        memory_addr_with_value = random.randint(10, 255)
        await reset_cpu(dut)

        cval = test_num
        pc = 1

        for _ in range(8):
            await run_zpg_instruction(
                dut,
                hex_to_num("06"),
                memory_addr_with_value,
                pc,
                cval,
                (cval * 2) % 256,
            )
            cval = (cval * 2) % 256
            pc += 2

        assert cval == 0


@cocotb.test()
async def test_ASL_ZPG_Base(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # test instruction on it's own
    for test_num in range(256):
        memory_addr_with_value = random.randint(10, 255)
        await reset_cpu(dut)
        await run_zpg_instruction(
            dut,
            hex_to_num("06"),
            memory_addr_with_value,
            1,
            test_num,
            (test_num * 2) % 256,
        )


@cocotb.test()
async def test_LSR_ZPG(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value = random.randint(10, 255)
        await reset_cpu(dut)
        await run_zpg_instruction(
            dut,
            hex_to_num("46"),
            memory_addr_with_value,
            1,
            test_num,
            (test_num // 2),
        )


@cocotb.test()
async def test_ROL_ZPG(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value = random.randint(10, 255)
        await reset_cpu(dut)
        await run_zpg_instruction(
            dut,
            hex_to_num("26"),
            memory_addr_with_value,
            1,
            test_num,
            (test_num * 2) % 256,
        )


@cocotb.test()
async def test_ROR_ZPG(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value = random.randint(10, 255)
        await reset_cpu(dut)
        await run_zpg_instruction(
            dut,
            hex_to_num("66"),
            memory_addr_with_value,
            1,
            test_num,
            (test_num // 2) % 256,
        )


@cocotb.test()
async def test_ASL_ABS(dut):
    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value_LB = random.randint(10, 255)
        memory_addr_with_value_HB = random.randint(1, 255)
        await reset_cpu(dut)
        await run_abs_instruction(
            dut,
            hex_to_num("0e"),
            memory_addr_with_value_HB,
            memory_addr_with_value_LB,
            1,
            test_num,
            (test_num * 2) % 256,
        )


@cocotb.test()
async def test_LSR_ABS(dut):
    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value_LB = random.randint(10, 255)
        memory_addr_with_value_HB = random.randint(1, 255)
        await reset_cpu(dut)
        await run_abs_instruction(
            dut,
            hex_to_num("4e"),
            memory_addr_with_value_HB,
            memory_addr_with_value_LB,
            1,
            test_num,
            (test_num // 2) % 256,
        )


@cocotb.test()
async def test_ROL_ABS(dut):
    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value_LB = random.randint(10, 255)
        memory_addr_with_value_HB = random.randint(1, 255)
        await reset_cpu(dut)
        await run_abs_instruction(
            dut,
            hex_to_num("2e"),
            memory_addr_with_value_HB,
            memory_addr_with_value_LB,
            1,
            test_num,
            (test_num * 2) % 256,
        )


@cocotb.test()
async def test_ROR_ABS(dut):
    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for test_num in range(256):
        memory_addr_with_value_LB = random.randint(10, 255)
        memory_addr_with_value_HB = random.randint(1, 255)
        await reset_cpu(dut)
        await run_abs_instruction(
            dut,
            hex_to_num("6e"),
            memory_addr_with_value_HB,
            memory_addr_with_value_LB,
            1,
            test_num,
            (test_num // 2) % 256,
        )
