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

# interrupt sources macros
# Just to make the code more readable
class CSources:
    SRC = list(range(0, NR_SRC))

intp = CSources()

SOURCECFD_W             = 11

INACTIVE                = 0
DETACHED                = 1
EDGE1                   = 4
EDGE0                   = 5
LEVEL1                  = 6
LEVEL0                  = 7

INACTIVE_C              = 0
DETACHED_C              = 1
EDGEX_C                 = 2
LEVELXDM0_C             = 3
LEVELXDM1_C             = 4

FROM_RECTIFIER          = 0
FROM_EDGE_DETECTOR      = 1

SRC_PER_BIT             = 1

class CInputs:
    source              = 0
    sourcecfg           = 0
    setip               = 0
    active              = 0
    claimed             = 0

class CInternals:
    rectified_src       = 0
    new_intp            = 0 # DO NOT READ THIS REGISTER IT WILL BREAK COCOTB (2D ARRAY SOLVED ONLY FOR INTERFACE)
    rectified_src_qi    = 0
    new_intp_src        = 0
    intp_pen_src        = 0 # DO NOT READ THIS REGISTER IT WILL BREAK COCOTB (2D ARRAY SOLVED ONLY FOR INTERFACE)

class COutputs:
    intp_pen            = 0
    rectified_src       = 0

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

async def debug_config(dut):
    # Set Domain config Delivery Mode to 0: meaning Direct 
    dut.i_domaincfgDM.value = 0
    
    # Set the maximum value in reg 4 (index 3) in sourcecfg
    # Wait
    # set registers 3, 2, 1 with easy identifiable numbers 
    input.sourcecfg = set_or_reg(input.sourcecfg, 0x7FF, SOURCECFD_W, intp.SRC[3])
    dut.i_sourcecfg.value       = input.sourcecfg
    await Timer(1, units="ns")
    input.sourcecfg = set_or_reg(input.sourcecfg, 0x03, SOURCECFD_W, intp.SRC[2])
    input.sourcecfg = set_or_reg(input.sourcecfg, 0x02, SOURCECFD_W, intp.SRC[1])
    input.sourcecfg = set_or_reg(input.sourcecfg, 0x01, SOURCECFD_W, intp.SRC[0])
    dut.i_sourcecfg.value       = input.sourcecfg

    # Set setip, a 2D array, with 0xbebecafe
    await Timer(1, units="ns")
    input.setip = set_or_reg(input.setip, 0xbebecafe, NR_BITS_SRC, intp.SRC[0]) 
    dut.i_sugg_setip.value           = input.setip 

    # Set active, a 2D array, with 0xbebecafe
    await Timer(1, units="ns")
    input.active = set_or_reg(input.active, 0xbebecafe, NR_BITS_SRC, intp.SRC[0]) 
    dut.i_active.value          = input.active 

    # Set claimed, a 2D array, with 0xbebecafe
    await Timer(1, units="ns")
    input.claimed = set_or_reg(input.claimed, 0xbebecafe, NR_BITS_SRC, intp.SRC[0]) 
    dut.i_claimed.value         = input.claimed 

async def test_control_unit(dut):
    # Set Domain config Delivery Mode to 0: meaning Direct 
    dut.i_domaincfgDM.value     = 0
    
    # Set the maximum value in reg 4 (index 3) in sourcecfg
    await Timer(1, units="ns")
    # Source 0 will always be INACTIVE. Ensured by Register Control
    input.sourcecfg             = set_or_reg(input.sourcecfg, INACTIVE, SOURCECFD_W, intp.SRC[0])
    input.sourcecfg             = set_or_reg(input.sourcecfg, EDGE1, SOURCECFD_W, intp.SRC[1])
    input.sourcecfg             = set_or_reg(input.sourcecfg, LEVEL0, SOURCECFD_W, intp.SRC[2])
    input.sourcecfg             = set_or_reg(input.sourcecfg, EDGE0, SOURCECFD_W, intp.SRC[52])
    dut.i_sourcecfg.value       = input.sourcecfg

    # The expected values in new_intp_src are:
    await Timer(1, units="ns")
    internal.new_intp_src       = set_or_reg(internal.new_intp_src, 0x00, SRC_PER_BIT, intp.SRC[0])
    internal.new_intp_src       = set_or_reg(internal.new_intp_src, 0x01, SRC_PER_BIT, intp.SRC[1])
    internal.new_intp_src       = set_or_reg(internal.new_intp_src, 0x00, SRC_PER_BIT, intp.SRC[2])
    internal.new_intp_src       = set_or_reg(internal.new_intp_src, 0x01, SRC_PER_BIT, intp.SRC[52])

async def test_gatway_source1(dut):
    # Set Domain config Delivery Mode to 0: meaning Direct 
    dut.i_domaincfgDM.value = 0

    # Source 1 is configured to receive rising edge interrupts
    input.sourcecfg             = set_or_reg(input.sourcecfg, EDGE1, SOURCECFD_W, intp.SRC[1])
    dut.i_sourcecfg.value       = input.sourcecfg

    # Source 1 is not pending
    input.setip                 = set_or_reg(input.setip, 0, SRC_PER_BIT, intp.SRC[1])
    dut.i_sugg_setip.value           = input.setip

    # Source 1 was not claimed
    input.claimed               = set_or_reg(input.claimed, 0, SRC_PER_BIT, intp.SRC[1])
    dut.i_claimed.value         = input.claimed

    # Make Source 1 active
    input.active                = set_or_reg(input.active, 1, SRC_PER_BIT, intp.SRC[1])
    dut.i_active.value          = input.active

    await Timer(random.randint(3,7), units="ns")
    input.source                = set_or_reg(input.source, 1, SRC_PER_BIT, intp.SRC[1])
    dut.i_sources.value         = input.source
    
    await Timer(1, units="ns")
    # After it receives the interrupt, the pending bit becomes one
    aux                         = read_bit_from_reg(dut.o_intp_pen, intp.SRC[1]) 
    input.setip                 = set_or_reg(input.setip, aux, SRC_PER_BIT, intp.SRC[1])
    dut.i_sugg_setip.value           = input.setip
    # Clear the source interrupt
    input.source                = set_reg(input.source, 0, SRC_PER_BIT, intp.SRC[1])
    dut.i_sources.value         = input.source

    await Timer(random.randint(3,5), units="ns")
    input.claimed               = set_or_reg(input.claimed, 1, SRC_PER_BIT, intp.SRC[1])
    dut.i_claimed.value         = input.claimed

    # Expected Values
    internal.new_intp_src       = set_or_reg(internal.new_intp_src, 0x01, 1, intp.SRC[1])
    
async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
        dut.i_clk.value = 0
        await Timer(1, units="ns")
        dut.i_clk.value = 1
        await Timer(1, units="ns")

@cocotb.test()
async def gateway_unit_test(dut):
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
    #await cocotb.start(test_control_unit(dut))
    await cocotb.start(test_gatway_source1(dut))

    await Timer(15, units="ns")
    #TODO Add asserts for outputs
    assert dut.i_sourcecfg.value    == input.sourcecfg  , "Oh boy, you mess it up in sourcecfg!"
    assert dut.i_sugg_setip.value        == input.setip      , "Oh boy, you mess it up in setip!"
    assert dut.i_active.value       == input.active     , "Oh boy, you mess it up in active!"
    assert dut.i_claimed.value      == input.claimed    , "Oh boy, you mess it up in claimed!"
    assert dut.aplic_domain_gateway_i.new_intp_src.value == internal.new_intp_src  , "Oh boy, you mess it up in new_intp_src!"