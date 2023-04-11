from os import setpgid
from readline import set_pre_input_hook
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

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

TOPI_W                  = 26
TOPI_INTP_ID            = 16
TOPI_INTP_PRIO          = 0

APLIC_BASE              = 0xc000000
SOURCECFG_BASE          = APLIC_BASE + 0x0004
SOURCECFG_OFF           = 0x0004
SETIPNUM_BASE           = APLIC_BASE + 0x1CDC
CLRIPNUM_BASE           = APLIC_BASE + 0x1DDC
SETIP_BASE              = APLIC_BASE + 0x1C00
SETIP_OFF               = 0x0004
INCLRIP_BASE            = APLIC_BASE + 0x1D00

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
    i_intp_pen = 0
    i_rectified_src = 0
    i_topi_sugg = 0
    i_topi_update = 0

class CInternals:
    setie_select_i = 0
    setip_select_i = 0
    topi_update_i = 0

class COutputs:
    reg_intf_resp_d32_rdata = 0
    reg_intf_resp_d32_error = 0
    reg_intf_resp_d32_ready = 0
    o_sourcecfg = 0
    o_sugg_setip = 0
    o_domaincfgDM = 0
    o_active = 0
    o_claimed_forwarded = 0
    o_domaincfgIE = 0
    o_setip_q = 0
    o_setie_q = 0
    o_target_q = 0
    o_idelivery = 0
    o_iforce = 0
    o_ithreshold = 0

input                   = CInputs()
internal                = CInternals()
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

def axi_read_reg(dut, addr):
    input.reg_intf_req_a32_d32_addr = addr
    input.reg_intf_req_a32_d32_valid = 1
    input.reg_intf_req_a32_d32_write = 0

    dut.reg_intf_req_a32_d32_addr.value = input.reg_intf_req_a32_d32_addr
    dut.reg_intf_req_a32_d32_write.value = input.reg_intf_req_a32_d32_write
    dut.reg_intf_req_a32_d32_valid.value = input.reg_intf_req_a32_d32_valid 

    outputs.reg_intf_resp_d32_rdata = dut.reg_intf_resp_d32_rdata.value
    return outputs.reg_intf_resp_d32_rdata 
    

async def debug_config(dut):
    
    ## Test claimed and forwarded register
    input.i_topi_sugg = set_reg(input.i_topi_sugg, (13 << TOPI_INTP_ID) | (1 << TOPI_INTP_PRIO), TOPI_W, idc.ID[0])
    dut.i_topi_sugg.value = input.i_topi_sugg
    input.i_topi_update = set_reg(input.i_topi_update, 1, IDC_PER_BIT, idc.ID[0])
    dut.i_topi_update.value = input.i_topi_update

    await Timer(1, units="ns")
    # reading claimi should make 
    axi_read_reg(dut, 0x401c+APLIC_BASE)

    #### EXPECTED VALUES #####
    outputs.o_claimed_forwarded = set_reg(outputs.o_claimed_forwarded, 1, SRC_PER_BIT, intp.SRC[13])
    #...

async def test_pending(dut):
    ## From gateway intp 13 is pending
    input.i_intp_pen = set_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_intp_pen.value = input.i_intp_pen

    await Timer(1, units="ns")
    # Set pending bit for interrupt 1
    axi_write_reg(dut, SETIPNUM_BASE, 1)
    input.i_intp_pen = set_or_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[1])
    dut.i_intp_pen.value = input.i_intp_pen
    await Timer(1, units="ns")
    # clear pending bit for interrupt 1
    axi_write_reg(dut, CLRIPNUM_BASE, 1)
    input.i_intp_pen = set_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_intp_pen.value = input.i_intp_pen
    # Clear the write enable bit
    await Timer(1, units="ns")
    axi_read_reg(dut, APLIC_BASE)

    await Timer(1, units="ns")
    ## Write to setip: set 13 and 17
    axi_write_reg(dut, SETIP_BASE, (1<<17) | (1<<13))
    input.i_intp_pen = set_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[17])
    input.i_intp_pen = set_or_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_intp_pen.value = input.i_intp_pen
    # Clear the write enable bit
    await Timer(1, units="ns")
    axi_read_reg(dut, APLIC_BASE)

    await Timer(1, units="ns")
    ## Write to in_clrip: clr 17
    axi_write_reg(dut, INCLRIP_BASE, (1<<17))
    input.i_intp_pen = set_reg(input.i_intp_pen, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_intp_pen.value = input.i_intp_pen
    # Clear the write enable bit
    await Timer(1, units="ns")
    axi_read_reg(dut, APLIC_BASE)

    #### EXPECTED VALUES #####
    outputs.o_sugg_setip = input.i_intp_pen

async def test_active(dut):
    # Make source 13 active, edge-sensitive rising edge
    axi_write_reg(dut, SOURCECFG_BASE+(SOURCECFG_OFF * 13), 4)
    # 
    #### EXPECTED VALUES #####
    outputs.o_active = set_reg(outputs.o_active, 1, SRC_PER_BIT, intp.SRC[13])
    outputs.o_sourcecfg = set_reg(outputs.o_sourcecfg, 4, SRCCFG_W, intp.SRC[13])
    #...

async def test_domaincfg(dut):
    # Disable domain
    axi_write_reg(dut, APLIC_BASE, 1)
    await Timer(3, units="ns")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
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

    #await cocotb.start(debug_config(dut))
    #await cocotb.start(test_pending(dut))
    #await cocotb.start(test_active(dut))
    await cocotb.start(test_domaincfg(dut))
    
    await Timer(11, units="ns")
    
    assert dut.o_sourcecfg.value     == outputs.o_sourcecfg , "Oh boy, you mess it up in o_sourcecfg!"
    assert dut.o_sugg_setip.value    == outputs.o_sugg_setip, "Oh boy, you mess it up in o_sugg_setip!"
    #assert dut.o_active.value        == outputs.o_active, "Oh boy, you mess it up in o_active!"