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
from  addrBases import CaddrBases

ONE_CYCLE              = 2
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

APLIC_M_BASE            = 0xc000000
APLIC_S_BASE            = 0xd000000

EDELIVERY       = 0X70
EITHRESHOLD     = 0X72
EIE0            = 0xC0

M_MODE          = 3 
S_MODE          = 1

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
    i_priv_lvl                  = 0
    i_vgein                     = 0
    i_imsic_addr                = 0
    i_imsic_data                = 0
    i_imsic_we                  = 0
    i_imsic_claim               = 0

class COutputs:
    reg_intf_resp_d32_rdata = 0
    reg_intf_resp_d32_error = 0
    reg_intf_resp_d32_ready = 0
    o_Xeip_targets = 0
    o_imsic_data                = 0   
    o_xtopei                    = 0
    o_imsic_exception           = 0 

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
    if (addr >= APLIC_M_BASE):
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

def axi_read_reg(dut, addr):
    if (addr >= APLIC_M_BASE):
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

def imsic_write_reg(dut, addr, data, priv_lvl, vgein = 0):
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
    input.i_imsic_claim = 0
    input.i_imsic_we = 0

    dut.i_imsic_claim.value = input.i_imsic_claim
    dut.i_imsic_we.value = input.i_imsic_we

def imsic_write_xtopei(dut, priv_lvl, vgein = 0):
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

async def test_msi(dut):
    # Enable interrupt delivering for S-File and M-File
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE, 1)
    await Timer(ONE_CYCLE, units="ns")
    imsic_write_reg(dut, EDELIVERY, 1, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_write_reg(dut, EDELIVERY, 1, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 13 and 31 in M-File
    imsic_write_reg(dut, EIE0, 0x80002000, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 21 in S-File
    imsic_write_reg(dut, EIE0, 0x200000, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")
    # Enable interrupt 3 in VS-File
    imsic_write_reg(dut, EIE0, 0x8, S_MODE, 1)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    # Disable domain m domain
    axi_write_reg(dut, CaddrBases.domainBase(APLIC_M_BASE), (1<<2))
    await Timer(3, units="ns")
    # Disable domain s domain
    axi_write_reg(dut, CaddrBases.domainBase(APLIC_S_BASE), (1<<2))
    await Timer(3, units="ns")

    # Interrupts source configuration
    # Configure interrupts 13, 31 and 17 for M domain.
    # Configure interrupts 21, 3 and 7 for S domain.
    # Other interrupts are delegated to S domain
    for i in range(NR_SRC):
        if i == 21:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), DELEGATE_SRC)
            await Timer(3, units="ns")
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_S_BASE) + (0x4 * (i-1)), EDGE1)
        elif i == 3:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), DELEGATE_SRC)
            await Timer(3, units="ns")
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_S_BASE) + (0x4 * (i-1)), EDGE1)
        elif i == 7:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), DELEGATE_SRC)
            await Timer(3, units="ns")
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_S_BASE) + (0x4 * (i-1)), EDGE1)
        elif i == 13:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), EDGE1)
        elif i == 17:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), EDGE1)
        elif i == 31:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), EDGE1)
        elif (i == 0 | i == 1):
            axi_read_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE))
        else:
            axi_write_reg(dut, CaddrBases.sourcecfgBase(APLIC_M_BASE) + (0x4 * (i-1)), INACTIVE)
        await Timer(randint(3,4), units="ns")
        

    # Interrupts 13, 17, 31 target configuration
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_M_BASE) + (0x4 * (13-1)), 13)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_M_BASE) + (0x4 * (17-1)), 17)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_M_BASE) + (0x4 * (31-1)), 31)
    await Timer(randint(2,4), units="ns")

    # Interrupts 3, 7, 21 target configuration
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_S_BASE) + (0x4 * (3-1)), (1<<12)|3)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_S_BASE) + (0x4 * (7-1)), 7)
    await Timer(randint(2,4), units="ns")
    axi_write_reg(dut, CaddrBases.targetBase(APLIC_S_BASE) + (0x4 * (21-1)), 21)
    await Timer(randint(2,4), units="ns")

    # Interrupts 13, 31 enbaling
    axi_write_reg(dut, CaddrBases.setienumBase(APLIC_M_BASE), 13)
    await Timer(ONE_CYCLE, units="ns")#randint(3,4), units="ns")
    axi_write_reg(dut, CaddrBases.setienumBase(APLIC_M_BASE), 31)
    await Timer(ONE_CYCLE, units="ns")

    # Interrupts 3, 21 enbaling
    axi_write_reg(dut, CaddrBases.setienumBase(APLIC_S_BASE), 3)
    await Timer(randint(3,4), units="ns")
    axi_write_reg(dut, CaddrBases.setienumBase(APLIC_S_BASE), 21)
    await Timer(randint(3,4), units="ns")

    # IDC configuration m domain
    axi_write_reg(dut, CaddrBases.ideliveryBase(APLIC_M_BASE), 1)
    await Timer(randint(3,4), units="ns")
    axi_write_reg(dut, CaddrBases.ithresholdBase(APLIC_M_BASE), 0)
    await Timer(randint(3,4), units="ns")

    # IDC configuration s domain
    axi_write_reg(dut, CaddrBases.ideliveryBase(APLIC_S_BASE), 1)
    await Timer(randint(3,4), units="ns")
    axi_write_reg(dut, CaddrBases.ithresholdBase(APLIC_S_BASE), 0)
    await Timer(randint(3,4), units="ns")

    # Enable domain
    axi_write_reg(dut, CaddrBases.domainBase(APLIC_M_BASE), (1 << 8) | (1<<2))
    await Timer(randint(3,4), units="ns")
    # Enable domain
    axi_write_reg(dut, CaddrBases.domainBase(APLIC_S_BASE), (1 << 8) | (1<<2))
    await Timer(randint(3,4), units="ns")

    # Trigger interrupts
    # First, trigger interrupt 13 
    # (not delegated, enabled and prio = 3)
    # Is expected that topi has 13 and 3
    await Timer(2, units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 13, we trigger interrupt 31 
    # (not delegated, enbaled and prio = 2, higher)
    # Is expected that topi has 31 and 2
    # await Timer(randint(2,7), units="ns")
    # input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[31])
    # dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 31, we trigger interrupt 17 
    # (not delegated, disabled and prio = 1, higher)
    # Is expected that topi has 31 and 2
    # await Timer(randint(1,3), units="ns")
    # input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[17])
    # dut.i_irq_sources.value         = input.i_irq_sources
    # Whithout claming interrupt 31, we trigger interrupt 21 
    # (delegated, enbaled and prio = )
    # Is expected that topi from m domain has 31 and 2 
    # AND irq_deleg has the 21 bit high. Thus, 
    await Timer(6, units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[21])
    dut.i_irq_sources.value         = input.i_irq_sources

    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 0, SRC_PER_BIT, intp.SRC[21])
    dut.i_irq_sources.value         = input.i_irq_sources

    #clear the pending interrupt 13
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, M_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    #clear the pending interrupt 21
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, S_MODE)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    await Timer(6, units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[3])
    dut.i_irq_sources.value         = input.i_irq_sources

    await Timer(randint(2,7), units="ns")
    input.i_irq_sources             = set_reg(input.i_irq_sources, 0, SRC_PER_BIT, intp.SRC[3])
    dut.i_irq_sources.value         = input.i_irq_sources

    #clear the pending interrupt 3
    await Timer(ONE_CYCLE*3, units="ns")
    imsic_write_xtopei(dut, S_MODE, 1)
    await Timer(ONE_CYCLE, units="ns")
    imsic_stop_write(dut)
    await Timer(ONE_CYCLE, units="ns")

    i = 0
    while (i < 15 ):
        await Timer(randint(2,7), units="ns")
        input.i_irq_sources             = set_reg(input.i_irq_sources, 1, SRC_PER_BIT, intp.SRC[21])
        dut.i_irq_sources.value         = input.i_irq_sources

        await Timer(randint(2,7), units="ns")
        input.i_irq_sources             = set_reg(input.i_irq_sources, 0, SRC_PER_BIT, intp.SRC[21])
        dut.i_irq_sources.value         = input.i_irq_sources

        #clear the pending interrupt 21
        await Timer(ONE_CYCLE*3, units="ns")
        imsic_write_xtopei(dut, S_MODE)
        await Timer(ONE_CYCLE, units="ns")
        imsic_stop_write(dut)
        await Timer(ONE_CYCLE, units="ns")



async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(1000):
        dut.i_clk.value = 0
        await Timer(1, units="ns")
        dut.i_clk.value = 1
        await Timer(1, units="ns")

@cocotb.test()
async def top_unit_test(dut):
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

    # await cocotb.start(debug_config(dut))
    await cocotb.start(test_msi(dut))
    
    await Timer(500, units="ns")
    