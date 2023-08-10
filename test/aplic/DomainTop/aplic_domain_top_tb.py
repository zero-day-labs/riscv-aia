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

# The test functions need to use the decorator @cocotb.test()
# Usage: await cocotb.start(generate_clock(dut))  # run the clock "in the background"
# if you want to wait a specific time: await Timer(5, units="ns")  # wait a bit

NR_SRC                  = 32
NR_BITS_SRC             = NR_SRC if (NR_SRC > 31) else 32
NR_REG                  = NR_SRC//32
NR_IDC                  = 1

IDC_PER_BIT             = 1
SRC_PER_BIT             = 1
SRCCFG_W                = 11

DELEGATE_SRC            = 0x400
INACTIVE                = 0
DETACHED                = 1
EDGE1                   = 4
EDGE0                   = 5
LEVEL1                  = 6
LEVEL0                  = 7

APLIC_BASE              = 0xc000000
domainBase              = APLIC_BASE + 0x0000
sourcecfgBase           = APLIC_BASE + 0x0004
mmsiaddrcfgBase         = APLIC_BASE + 0x1BC0
mmsiaddrcfghBase        = APLIC_BASE + 0x1BC4
smsiaddrcfgBase         = APLIC_BASE + 0x1BC8
smsiaddrcfghBase        = APLIC_BASE + 0x1BCC
setipBase               = APLIC_BASE + 0x1C00
setipnumBase            = APLIC_BASE + 0x1CDC
in_clripBase            = APLIC_BASE + 0x1D00
clripnumBase            = APLIC_BASE + 0x1DDC
setieBase               = APLIC_BASE + 0x1E00
setienumBase            = APLIC_BASE + 0x1EDC
clrieBase               = APLIC_BASE + 0x1F00
clrienumBase            = APLIC_BASE + 0x1FDC
setipnum_leBase         = APLIC_BASE + 0x2000
setipnum_beBase         = APLIC_BASE + 0x2004
genmsiBase              = APLIC_BASE + 0x3000
targetBase              = APLIC_BASE + 0x3004

aplic_idc_base          = APLIC_BASE + 0x4000
ideliveryBase            = aplic_idc_base + 0x00
iforceBase               = aplic_idc_base + 0x04
ithresholdBase           = aplic_idc_base + 0x08
topiBase                 = aplic_idc_base + 0x18
claimiBase               = aplic_idc_base + 0x1C


# interrupt sources macros
# Just to make the code more readable
class CSources:
    SRC = list(range(0, NR_SRC))

intp = CSources()

class CIDCs:
    ID = list(range(0, NR_IDC))

idc = CIDCs()

class CInputs:
    reg_intf_req_a32_d32_addr = 0
    reg_intf_req_a32_d32_write = 0
    reg_intf_req_a32_d32_wdata = 0
    reg_intf_req_a32_d32_wstrb = 0
    reg_intf_req_a32_d32_valid = 0
    i_irq_sources = 0

class COutputs:
    reg_intf_resp_d32_rdata = 0
    reg_intf_resp_d32_error = 0
    reg_intf_resp_d32_ready = 0
    o_irq_del_sources = 0
    o_Xeip_targets = 0

input                   = CInputs()
outputs                 = COutputs()

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
    input.reg_intf_req_a32_d32_addr = addr
    input.reg_intf_req_a32_d32_wdata = data
    input.reg_intf_req_a32_d32_write = 1 
    input.reg_intf_req_a32_d32_wstrb = 0 
    input.reg_intf_req_a32_d32_valid = 1

    dut.reg_intf_req_a32_d32_addr.value = input.reg_intf_req_a32_d32_addr
    dut.reg_intf_req_a32_d32_wdata.value = input.reg_intf_req_a32_d32_wdata
    dut.reg_intf_req_a32_d32_write.value = input.reg_intf_req_a32_d32_write
    dut.reg_intf_req_a32_d32_wstrb.value = input.reg_intf_req_a32_d32_wstrb
    dut.reg_intf_req_a32_d32_valid.value = input.reg_intf_req_a32_d32_valid
    #await Timer(randint(0,5), units="ns")

def axi_read_reg(dut, addr):
    input.reg_intf_req_a32_d32_addr = addr
    input.reg_intf_req_a32_d32_valid = 1
    input.reg_intf_req_a32_d32_write = 0

    dut.reg_intf_req_a32_d32_addr.value = input.reg_intf_req_a32_d32_addr
    dut.reg_intf_req_a32_d32_write.value = input.reg_intf_req_a32_d32_write
    dut.reg_intf_req_a32_d32_valid.value = input.reg_intf_req_a32_d32_valid 

    outputs.reg_intf_resp_d32_rdata = dut.reg_intf_resp_d32_rdata.value
    return outputs.reg_intf_resp_d32_rdata 
    
def axi_disable_read(dut):
    input.reg_intf_req_a32_d32_valid = 0
    input.reg_intf_req_a32_d32_write = 1
    dut.reg_intf_req_a32_d32_valid.value = input.reg_intf_req_a32_d32_valid
    dut.reg_intf_req_a32_d32_write.value = input.reg_intf_req_a32_d32_write

async def debug_config(dut):
    # Disable domain
    axi_write_reg(dut, domainBase, 0)
    await Timer(3, units="ns")

    # Interrupts source configuration
    for i in range(NR_SRC):
        if i == 13:
            axi_write_reg(dut, sourcecfgBase + (0x4 * (i-1)), EDGE1)
        elif i == 17:
            axi_write_reg(dut, sourcecfgBase + (0x4 * (i-1)), EDGE1)
        elif i == 31:
            axi_write_reg(dut, sourcecfgBase + (0x4 * (i-1)), EDGE1)
        else:
            axi_write_reg(dut, sourcecfgBase + (0x4 * (i-1)), DELEGATE_SRC)
        await Timer(randint(3,4), units="ns")
        

    # Interrupts 13, 17, 31 target configuration
    axi_write_reg(dut, targetBase + (0x4 * (13-1)), 3)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, targetBase + (0x4 * (17-1)), 1)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, targetBase + (0x4 * (31-1)), 2)
    await Timer(randint(2,4), units="ns")

    # Interrupts 13, 31 enbaling
    axi_write_reg(dut, setienumBase, 13)
    await Timer(randint(3,4), units="ns")
    axi_write_reg(dut, setienumBase, 31)
    await Timer(randint(3,4), units="ns")

    # IDC configuration
    axi_write_reg(dut, ideliveryBase, 1)
    await Timer(randint(3,4), units="ns")
    axi_write_reg(dut, ithresholdBase, 0)
    await Timer(randint(3,4), units="ns")

    # Enable domain
    axi_write_reg(dut, domainBase, (1 << 8))
    await Timer(randint(3,4), units="ns")

    # Trigger interrupts
    # First, trigger interrupt 13 
    # (not delegated, enabled and prio = 3)
    # Is expected that topi has 13 and 3
    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 13, we trigger interrupt 31 
    # (not delegated, enbaled and prio = 2, higher)
    # Is expected that topi has 31 and 2
    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[31])
    dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 31, we trigger interrupt 17 
    # (not delegated, disabled and prio = 1, higher)
    # Is expected that topi has 31 and 2
    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[17])
    dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 31, we trigger interrupt 21 
    # (delegated, XXX and XXX)
    # Is expected that topi has 31 and 2 AND irq_deleg has the 21 bit high
    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[21])
    dut.i_irq_sources.value         = input.i_irq_sources

    # Claiming interrupt
    # To claim an interrupt we just need to read from claimi reg
    # Claim interrupt 31
    await Timer(randint(2,7), units="ns")
    axi_read_reg(dut, claimiBase)
    # # Claim interrupt 13
    await Timer(randint(2,7), units="ns")
    axi_disable_read(dut)
    await Timer(randint(2,7), units="ns")
    axi_read_reg(dut, claimiBase)
    await Timer(randint(2,7), units="ns")
    axi_disable_read(dut)   
    ### EXPECTED VALUES ###

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

    await cocotb.start(debug_config(dut))
    
    await Timer(500, units="ns")
    