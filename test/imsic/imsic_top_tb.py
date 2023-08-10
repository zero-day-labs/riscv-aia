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

ONE_CYCLE       = 2

M_MODE          = 3 
S_MODE          = 1

M_FILE_ADDR     = 0x24000000
S_FILE_ADDR     = 0x28000000

SETIPNUM_OFF    = 0x0

EDELIVERY       = 0X70
EITHRESHOLD     = 0X72
EIE0            = 0xC0

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

def imsic_write_reg(dut, addr, data, priv_lvl, vgein=0):
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = addr
    input.i_imsic_data = data
    input.i_imsic_claim = 0
    input.i_imsic_we = 1

    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def imsic_stop_write(dut):
    input.i_imsic_we = 0

    dut.i_imsic_we.value = input.i_imsic_we

def imsic_write_xtopei(dut, priv_lvl, vgein=0):
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = 0
    input.i_imsic_data = 0
    input.i_imsic_claim = 1
    input.i_imsic_we = 0

    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def imsic_read_reg(dut, addr, priv_lvl, vgein=0):
    input.i_priv_lvl = priv_lvl
    input.i_vgein = vgein
    input.i_imsic_addr = addr
    input.i_imsic_data = 0
    input.i_imsic_claim = 0
    input.i_imsic_we = 0

    dut.i_priv_lvl.value = input.i_priv_lvl
    dut.i_vgein.value = input.i_vgein
    dut.i_imsic_addr.value = input.i_imsic_addr
    dut.i_imsic_data.value = input.i_imsic_data
    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

async def debug_config(dut):
    imsic_write_reg(dut, EDELIVERY, 1, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_write_reg(dut, EITHRESHOLD, 3, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_write_reg(dut, EITHRESHOLD, 2, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)

async def imsic_with_m_s_files(dut):
    # Enable interrupt delivering for M-File
    imsic_write_reg(dut, EDELIVERY, 1, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt delivering for S-File
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 30 in S-File
    imsic_write_reg(dut, EIE0, 0x40000000, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 2 in M-File
    imsic_write_reg(dut, EIE0, 0x00000004, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    # Simulate a dummy device write to S-File 
    axi_write_reg(dut,0x28000000,30)
    await Timer(ONE_CYCLE, units="ns")
    axi_disable_write(dut)
    await Timer(ONE_CYCLE*4, units="ns")

    axi_write_reg(dut,0x24000000,2)
    await Timer(ONE_CYCLE, units="ns")
    axi_disable_write(dut)
    
    #clear the pending interrupt
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, S_MODE)

    #clear the pending interrupt
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, M_MODE)

async def imsic_with_vs_files(dut):
    # Enable interrupt delivering for M-File
    imsic_write_reg(dut, EDELIVERY, 1, M_MODE, 0)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt delivering for S-File
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE, 0)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt delivering for VS-File
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE, 1)
    await Timer(ONE_CYCLE, units="ns")

    # Enable interrupt 30 in S-File
    imsic_write_reg(dut, EIE0, 0x40000000, S_MODE, 0)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 2 in M-File
    imsic_write_reg(dut, EIE0, 0x00000004, M_MODE, 0)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 13 in VS-File
    imsic_write_reg(dut, EIE0, 0x00002000, S_MODE, 1)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    # Simulate a dummy device write 
    axi_write_reg(dut,0x28000000,30)
    await Timer(ONE_CYCLE, units="ns")
    axi_disable_write(dut)
    await Timer(ONE_CYCLE*4, units="ns")

    axi_write_reg(dut,0x24000000,2)
    await Timer(ONE_CYCLE, units="ns")
    axi_disable_write(dut)
    await Timer(ONE_CYCLE*4, units="ns")

    axi_write_reg(dut,0x28001000,13)
    await Timer(ONE_CYCLE, units="ns")
    axi_disable_write(dut)
    
    #clear the pending interrupt
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, S_MODE, 0)

    #clear the pending interrupt
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, M_MODE, 0)

    #clear the pending interrupt
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, S_MODE, 1)

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

    await cocotb.start(imsic_with_m_s_files(dut))
    
    await Timer(500, units="ns")
    