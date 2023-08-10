# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

from os import setpgid
from readline import set_pre_input_hook
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer

APLIC_M_BASE            = 0xc000000
APLIC_S_BASE            = 0xd000000

DOMAINCFG_M_BASE        = APLIC_M_BASE + 0x0000
DOMAINCFG_S_BASE        = APLIC_S_BASE + 0x0000

# Sourcecfg base macro
SOURCECFG_M_BASE        = APLIC_M_BASE + 0x0004
SOURCECFG_S_BASE        = APLIC_S_BASE + 0x0004
SOURCECFG_OFF           = 0x0004
DELEGATE_SRC            = 0x400
INACTIVE                = 0
DETACHED                = 1
EDGE1                   = 4
EDGE0                   = 5
LEVEL1                  = 6
LEVEL0                  = 7
# Target base macros
TARGET_M_BASE           = APLIC_M_BASE + 0x3004
TARGET_S_BASE           = APLIC_S_BASE + 0x3004
TARGET_OFF              = 0x0004

# Pending operations macros
SETIPNUM_M_BASE         = APLIC_M_BASE + 0x1CDC
SETIPNUM_S_BASE         = APLIC_S_BASE + 0x1CDC
CLRIPNUM_M_BASE         = APLIC_M_BASE + 0x1DDC
CLRIPNUM_S_BASE         = APLIC_S_BASE + 0x1DDC
SETIP_M_BASE            = APLIC_M_BASE + 0x1C00
SETIP_S_BASE            = APLIC_S_BASE + 0x1C00
INCLRIP_M_BASE          = APLIC_M_BASE + 0x1D00
INCLRIP_S_BASE          = APLIC_S_BASE + 0x1D00

# Enable operations macros
SETIENUM_M_BASE         = APLIC_M_BASE + 0x1EDC
SETIENUM_S_BASE         = APLIC_S_BASE + 0x1EDC
CLRIENUM_M_BASE         = APLIC_M_BASE + 0x1FDC
CLRIENUM_S_BASE         = APLIC_S_BASE + 0x1FDC

# IDC macros
IDELIVERY_M_BASE        = APLIC_M_BASE + 0x4000 + 0x00
IDELIVERY_S_BASE        = APLIC_S_BASE + 0x4000 + 0x00
IFORCE_M_BASE           = APLIC_M_BASE + 0x4000 + 0x04
IFORCE_S_BASE           = APLIC_S_BASE + 0x4000 + 0x04
ITHRESHOLD_M_BASE       = APLIC_M_BASE + 0x4000 + 0x08
ITHRESHOLD_S_BASE       = APLIC_S_BASE + 0x4000 + 0x08
CLAIMI_M_BASE           = APLIC_M_BASE + 0x4000 + 0x1C
CLAIMI_S_BASE           = APLIC_S_BASE + 0x4000 + 0x1C

class CInputs:
    reg_intf_req_a32_d32_addr = 0
    reg_intf_req_a32_d32_write = 0
    reg_intf_req_a32_d32_wdata = 0
    reg_intf_req_a32_d32_wstrb = 0
    reg_intf_req_a32_d32_valid = 0
    i_rectified_src            = 0

class COutputs:
    reg_intf_resp_d32_rdata = 0
    reg_intf_resp_d32_error = 0
    reg_intf_resp_d32_ready = 0

input                   = CInputs()
outputs                 = COutputs()

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

def axi_read_reg(dut, addr):
    input.reg_intf_req_a32_d32_addr = addr
    input.reg_intf_req_a32_d32_valid = 1
    input.reg_intf_req_a32_d32_write = 0

    dut.reg_intf_req_a32_d32_addr.value = input.reg_intf_req_a32_d32_addr
    dut.reg_intf_req_a32_d32_write.value = input.reg_intf_req_a32_d32_write
    dut.reg_intf_req_a32_d32_valid.value = input.reg_intf_req_a32_d32_valid 

    outputs.reg_intf_resp_d32_rdata = dut.reg_intf_resp_d32_rdata.value
    return outputs.reg_intf_resp_d32_rdata 

async def test_notifier(dut):
    # Enable M domain in direct mode
    axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8))
    await Timer(4, units="ns")
    # Enable S domain in direct mode
    axi_write_reg(dut, DOMAINCFG_S_BASE, (1 << 8))
    await Timer(4, units="ns")

    # Make idelivery active in M domain
    axi_write_reg(dut, IDELIVERY_M_BASE, 1)
    await Timer(4, units="ns")
    # Make idelivery active in S domain
    axi_write_reg(dut, IDELIVERY_S_BASE, 1)
    await Timer(4, units="ns")

    # Make ithreshold 6 in M domain
    axi_write_reg(dut, ITHRESHOLD_M_BASE, 6)
    await Timer(4, units="ns")
    # Make ithreshold 0 in S domain (allow all intps)
    axi_write_reg(dut, ITHRESHOLD_M_BASE, 0)
    await Timer(4, units="ns")

    # Make source 14 active in M domain, edge-sensitive rising edge
    axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * 13), EDGE1)
    await Timer(4, units="ns")
    # delegate intp 23 to S domain
    axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * 22), DELEGATE_SRC)
    await Timer(4, units="ns")
    # Make source 23 active in S domain, edge-sensitive rising edge
    axi_write_reg(dut, SOURCECFG_S_BASE+(SOURCECFG_OFF * 22), EDGE1)
    await Timer(4, units="ns")

    # Make TARGET 14 in M domain, hart = 0, prio =  2
    axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * 13), (0 << 18) | (2 << 0))
    await Timer(4, units="ns")
    # Make TARGET 23 in S domain, hart = 0, prio =  6
    axi_write_reg(dut, TARGET_S_BASE+(TARGET_OFF * 22), (0 << 18) | (6 << 0))
    await Timer(4, units="ns")

    # Write value 14 for setipnum in M domain
    axi_write_reg(dut, SETIPNUM_M_BASE, 14)
    await Timer(4, units="ns")
    # Write value 14 for setienum in M domain
    axi_write_reg(dut, SETIENUM_M_BASE, 14)
    await Timer(4, units="ns")

    # Write value 23 for setipnum in S domain
    axi_write_reg(dut, SETIPNUM_S_BASE, 23)
    await Timer(4, units="ns")
    # Write value 23 for setienum in S domain
    axi_write_reg(dut, SETIENUM_S_BASE, 23)
    await Timer(4, units="ns")

    # Lets activate a new intp (3) in M domain with prio 1 (higher than intp prio 14)
    # The intp domain should mantain the CPU line up, but change the topi value
    # Make source 3 active in M domain, edge-sensitive rising edge
    axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * 2), 4)
    await Timer(4, units="ns")
    # Make TARGET 3 in M domain, hart = 0, prio = 1
    axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * 2), (0 << 18) | (1 << 0))
    await Timer(4, units="ns")
    # Write value 3 for setipnum in M domain
    axi_write_reg(dut, SETIPNUM_M_BASE, 3)
    await Timer(4, units="ns")
    # Write value 3 for setienum in M domain
    axi_write_reg(dut, SETIENUM_M_BASE, 3)
    await Timer(4, units="ns")

    # Disable the S domain interrupt
    # We should see the CPU line to go low and the topi reseted
    # Write value 23 for clrienum in S domain
    axi_write_reg(dut, CLRIENUM_S_BASE, 23)
    await Timer(4, units="ns")

    # Force an interrupt in S domain by writing to iforce
    axi_write_reg(dut, IFORCE_S_BASE, 1)
    await Timer(4, units="ns")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(100000):
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

    # await cocotb.start(test_domaincfg(dut))
    await cocotb.start(test_notifier(dut))
    
    await Timer(10000, units="ns")