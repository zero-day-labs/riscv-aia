# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

from os import setpgid
from readline import set_pre_input_hook
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from random import seed
from random import randint
import math

ONE_CYCLE       = 2

M_MODE          = 3 
S_MODE          = 1

M_FILE_BASE_ADDR     = 0x24000000
S_FILE_BASE_ADDR     = 0x28000000
PAGE_SIZE            = 0x1000

SETIPNUM_OFF    = 0x0

EDELIVERY       = 0X70
EITHRESHOLD     = 0X72
EIE0            = 0xC0

ENABLE_INTP_FILE        = 1
DISABLE_INTP_FILE       = 0

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
RESET = "\033[0m"

class CInputs:
    ready_i                     = 0
    addr_i                      = 0
    data_i                      = 0
    i_priv_lvl                  = 0
    i_vgein                     = 0
    i_imsic_addr                = 0
    i_imsic_data                = 0
    i_imsic_we                  = 0
    i_imsic_claim               = 0

class COutputs:
    o_imsic_data                = 0   
    o_xtopei                    = 0
    o_imsic_exception           = 0       

input                           = CInputs()
outputs                         = COutputs()

def set_reg(reg, hexa, reg_width, reg_num):
    reg     = (hexa << reg_width*reg_num)
    return reg

def set_or_reg(reg, hexa, reg_width, reg_num):
    reg     = reg | (hexa << reg_width*reg_num)
    return reg

def read_bit_from_reg(reg, bit_num):
    aux     = int(reg)
    aux     = (aux >> bit_num) & 1
    return aux

def axi_write_reg(dut, addr, data):
    input.addr_i        = addr
    input.data_i        = data
    input.ready_i       = 1 

    dut.addr_i.value    = input.addr_i
    dut.data_i.value    = input.data_i
    dut.ready_i.value   = input.ready_i
    
def axi_disable_write(dut):
    input.addr_i        = 0
    input.data_i        = 0
    input.ready_i       = 0 

    dut.addr_i.value    = input.addr_i
    dut.data_i.value    = input.data_i
    dut.ready_i.value   = input.ready_i

def imsic_write_reg(dut, imsic=1, addr=0, data=0, priv_lvl=M_MODE, vgein=0):
    input.i_select_imsic = (1 << (imsic-1))
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = addr
    input.i_imsic_data = data
    input.i_imsic_claim = 0
    input.i_imsic_we = 1

    dut.i_select_imsic.value = input.i_select_imsic
    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def imsic_stop_write(dut):
    input.i_imsic_we = 0

    dut.i_imsic_we.value = input.i_imsic_we

def imsic_write_xtopei(dut, imsic = 1, priv_lvl=M_MODE, vgein=0):
    input.i_select_imsic = (1 << (imsic-1))
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = 0
    input.i_imsic_data = 0
    input.i_imsic_claim = 1
    input.i_imsic_we = 0

    dut.i_select_imsic.value = input.i_select_imsic
    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def imsic_read_reg(dut, imsic = 1, addr=0, priv_lvl=M_MODE, vgein=0):
    input.i_select_imsic = (1 << (imsic-1))
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = addr
    input.i_imsic_data = 0
    input.i_imsic_claim = 0
    input.i_imsic_we = 0

    dut.i_select_imsic.value = input.i_select_imsic
    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def organize_xtopei(array, nr_imsics = 0, nr_intp_files = 0, length=5):
    index = 0
    organized_data = []
    final_result = []

    if (nr_imsics == 0 or nr_intp_files == 0):
        raise("NR_IMSIC or NR_INTP_FILES lower than 1")
    
    for i in range(nr_imsics):
        for j in range(nr_intp_files):
            subrange = array[index:index + length]
            index = index + length + 1
            organized_data.append(subrange)
        organized_data.reverse()
        final_result.append(organized_data)
        organized_data = []

    final_result.reverse()
    return final_result

def clog2(x):
    if x <= 0:
        raise ValueError("Input must be a positive integer")
    return math.floor(math.log2(x))

async def generic_test(dut):
    TARGET_INTP = [63, 20, 1]
    TARGET_HART = [1, 2, 4] # this value depends on how many IMSIC were instantiated in wrap.sv
    NR_VS_INTP_FILES = 1 # this value depends on how many VS files were instantiated in wrap.sv
    TARGET_GUEST = [0, 1, 0]
    TARGET_LEVEL = [M_MODE, S_MODE, M_MODE]
    
    XLEN = 64
    NR_IMSICS = 4
    IMSIC_MAX_SRC = 64
    NR_VS_FILES_IMSIC = NR_VS_INTP_FILES
    NR_FILES_IMSIC = 2 + NR_VS_FILES_IMSIC
    NR_TESTS_INTP = len(TARGET_INTP)
    EIE_OFF = []
    TARGET_IMSIC_ADDR = []

    for i in range(NR_TESTS_INTP):
        if ((TARGET_GUEST[i] != 0) and (TARGET_LEVEL[i] != S_MODE)):
            raise ValueError('Wrong value for TARGET_GUEST[{}]. It only make sense to set the guest to 1 if the TARFET_LEVEL is S_MODE'.format(i))
        if (TARGET_GUEST[i] > NR_VS_INTP_FILES):
            raise ValueError('Wrong value for TARGET_GUEST[{}]. Max is {}'.format(i, NR_VS_INTP_FILES))
    
    # Calculate the target imsic address fro each target interrupt and populate the TARGET_IMSIC_ADDR array
    for i in range(NR_TESTS_INTP):
        eie_off_subrange = (TARGET_INTP[i]//XLEN)*2 

        if (TARGET_LEVEL[i] == M_MODE):
            target_imsic_subrange = M_FILE_BASE_ADDR + (PAGE_SIZE * (TARGET_HART[i] - 1)) 
        else:
            target_imsic_subrange = S_FILE_BASE_ADDR + (PAGE_SIZE * (TARGET_HART[i] - 1) * (NR_VS_INTP_FILES+1)) + (PAGE_SIZE * TARGET_GUEST[i])

        EIE_OFF.append(eie_off_subrange)
        TARGET_IMSIC_ADDR.append(target_imsic_subrange)

    # Enable interrupt delivering in IMSICs
    for i in range(NR_TESTS_INTP):
        imsic_write_reg(dut, TARGET_HART[i], EDELIVERY, ENABLE_INTP_FILE, TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE, units="ns")

    # Enable target interrupts in IMSICs interrupt files 
    for i in range(NR_TESTS_INTP):
        imsic_write_reg(dut, TARGET_HART[i], EIE0+EIE_OFF[i], 1<<(TARGET_INTP[i]%XLEN), TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE, units="ns")

    # Simulate a dummy device write to IMSICs
    for i in range(NR_TESTS_INTP):
        axi_write_reg(dut, TARGET_IMSIC_ADDR[i], TARGET_INTP[i])
        await Timer(ONE_CYCLE, units="ns")
        axi_disable_write(dut)
        await Timer(ONE_CYCLE*4, units="ns")

    xtopei_array = organize_xtopei(dut.o_xtopei.value, NR_IMSICS, NR_FILES_IMSIC, clog2(IMSIC_MAX_SRC-1))

    for i in range(NR_TESTS_INTP):
        try:
            if (TARGET_LEVEL[i] == M_MODE):
                assert xtopei_array[TARGET_HART[i]-1][0] == TARGET_INTP[i], "Read xtopei does not match the expected value"
                print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][M] = {TARGET_INTP[i]}{RESET}")
            else:
                assert xtopei_array[TARGET_HART[i]-1][TARGET_GUEST[i]+1] == TARGET_INTP[i]
                if (TARGET_GUEST[i] == 0):
                    print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][S] = {TARGET_INTP[i]}{RESET}")
                else:
                    print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][VS][{TARGET_GUEST[i]-1}] = {TARGET_INTP[i]}{RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")
    
    print(f"{YELLOW}Strat claiming interrupts...")
    
    # Clear the pending interrupt
    for i in range(NR_TESTS_INTP):
        imsic_write_xtopei(dut, TARGET_HART[i], TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE*3, units="ns")
    
    xtopei_array = organize_xtopei(dut.o_xtopei.value, NR_IMSICS, NR_FILES_IMSIC, clog2(IMSIC_MAX_SRC-1))

    for i in range(NR_TESTS_INTP):
        try:
            if (TARGET_LEVEL[i] == M_MODE):
                assert xtopei_array[TARGET_HART[i]-1][0] == 0, "Read xtopei does not match the expected value"
                print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][M] = 0{RESET}")
            else:
                assert xtopei_array[TARGET_HART[i]-1][TARGET_GUEST[i]+1] == 0
                if (TARGET_GUEST[i] == 0):
                    print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][S] = 0{RESET}")
                else:
                    print(f"{GREEN}PASSED: xtopei[{TARGET_HART[i]-1}][VS][{TARGET_GUEST[i]-1}] = 0{RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(500):
        dut.i_clk.value = 0
        await Timer(1, units="ns")
        dut.i_clk.value = 1
        await Timer(1, units="ns")

@cocotb.test()
async def regctl_unit_test(dut):
    """Try accessing the design."""

    dut.ni_rst.value = 1
    # run the clock "in the background"
    await cocotb.start(generate_clock(dut))  
    # wait a bit
    await Timer(2, units="ns")  
    # wait for falling edge/"negedge"
    await FallingEdge(dut.i_clk)

    # Reset the dut
    dut.ni_rst.value = 0
    await Timer(1, units="ns")
    dut.ni_rst.value = 1
    await Timer(1, units="ns")

    await cocotb.start(generic_test(dut))
    
    await Timer(500, units="ns")
    