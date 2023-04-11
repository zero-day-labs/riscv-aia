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
MODE                    = "DIRECT"

SRC_PER_BIT             = 1
IDC_PER_BIT             = 1
TARGET_W                = 32
IDELIVERY_W             = 1
IFORCE_W                = 1
ITHRESHOLD_W            = 3
TOPI_W                  = 26
TOPI_INTP_ID            = 16
TOPI_INTP_PRIO          = 0
 
# interrupt sources macros
# Just to make the code more readable
class CSources:
    SRC = list(range(0, NR_SRC))

intp = CSources()

class CIDCs:
    ID = list(range(0, NR_IDC))

idc = CIDCs()

class CInputs:
    domaincfgIE         = 0
    setip_q             = 0
    setie_q             = 0
    target_q            = 0
    idelivery           = 0
    iforce              = 0
    ithreshold          = 0

class CInternals:
    has_valid_intp      = 0
    hart_index          = 0

class COutputs:
    topi_sugg           = 0
    topi_update         = 0
    Xeip_targets        = 0

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

async def test_direct_mode(dut):
    # Disable domain interrupts 
    dut.i_domaincfgIE.value = 0

    # Set pending bit for interrupt 17
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[17])
    dut.i_setip_q.value         = input.setip_q
    # Set pending bit for interrupt 13
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_setip_q.value         = input.setip_q
    # Set pending bit for interrupt 31
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[31])
    dut.i_setip_q.value         = input.setip_q
    
    # Make sure that interrupt 17 is disable
    input.setie_q               = set_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[17])
    dut.i_setie_q.value         = input.setie_q
    # Set enable bit for interrupt 13
    input.setie_q               = set_or_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_setie_q.value         = input.setie_q
    # Set enable bit for interrupt 31
    input.setie_q               = set_or_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[31])
    dut.i_setie_q.value         = input.setie_q

    # Set priority 1 to interrupt 17
    input.target_q               = set_or_reg(input.target_q, 1, TARGET_W, intp.SRC[17])
    dut.i_target_q.value         = input.target_q
    # Set priority 2 to interrupt 13
    input.target_q               = set_or_reg(input.target_q, 2, TARGET_W, intp.SRC[13])
    dut.i_target_q.value         = input.target_q
    # Set priority 3 to interrupt 31 
    input.target_q               = set_or_reg(input.target_q, 3, TARGET_W, intp.SRC[31])
    dut.i_target_q.value         = input.target_q
    
    # IDC configuration
    # Enable interrupt delivery for IDC 0
    input.idelivery              = set_reg(input.idelivery, 1, IDELIVERY_W, idc.ID[0])
    dut.i_idelivery.value        = input.idelivery
    # Make sure iforce is 0 for IDC 0
    input.iforce                 = set_reg(input.iforce, 1, IFORCE_W, idc.ID[0])
    dut.i_iforce.value           = input.iforce
    # Make sure ithreshold is 0 for IDC 0 -> enable all interrupts priorities
    input.ithreshold             = set_reg(input.ithreshold, 0, ITHRESHOLD_W, idc.ID[0])
    dut.i_ithreshold.value       = input.ithreshold

    # Enable domain interrupts
    input.domaincfgIE = 1
    dut.i_domaincfgIE.value = input.domaincfgIE

    await Timer(1, units="ns")
    #### EXPECTED VALUES #####
    outputs.topi_update         = set_reg(outputs.topi_update, 1, IDC_PER_BIT, idc.ID[0])
    outputs.topi_sugg           = set_reg(outputs.topi_sugg, (17 << TOPI_INTP_ID) | (1 << TOPI_INTP_PRIO), TOPI_W, idc.ID[0])
    outputs.Xeip_targets        = set_reg(outputs.Xeip_targets, 1, IDC_PER_BIT, idc.ID[0])

async def test_msi_mode(dut):
    # In this test 3 intp (13, 17, 31) are set pending and enable in the following
    # order: 17, 13, 31. When seting the enable bit between interrupts is an await
    # function for one clock cycle. So is expected that the intps are delivery in the
    # order that they get enabled. 
    # Since there are non slave to complete the AXI transaction, only the first appear
    # to be sent.
    # The intp priorities has no effect here!

    # Disable domain interrupts 
    dut.i_domaincfgIE.value = 0
    
    # Set pending bit for interrupt 17
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[17])
    dut.i_setip_q.value         = input.setip_q
    # Set pending bit for interrupt 13
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_setip_q.value         = input.setip_q
    # Set pending bit for interrupt 31
    input.setip_q               = set_or_reg(input.setip_q, 1, SRC_PER_BIT, intp.SRC[31])
    dut.i_setip_q.value         = input.setip_q
    
    # Enable domain interrupts
    input.domaincfgIE = 1
    dut.i_domaincfgIE.value = input.domaincfgIE

    # Set enable bit for interrupt 17
    input.setie_q               = set_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[17])
    dut.i_setie_q.value         = input.setie_q
    await Timer(1, units="ns")
    # Set enable bit for interrupt 13
    input.setie_q               = set_or_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[13])
    dut.i_setie_q.value         = input.setie_q
    await Timer(1, units="ns")
    # Set enable bit for interrupt 31
    input.setie_q               = set_or_reg(input.setie_q, 1, SRC_PER_BIT, intp.SRC[31])
    dut.i_setie_q.value         = input.setie_q

    # Set priority 1 to interrupt 17
    input.target_q               = set_or_reg(input.target_q, 1, TARGET_W, intp.SRC[17])
    dut.i_target_q.value         = input.target_q
    # Set priority 2 to interrupt 13
    input.target_q               = set_or_reg(input.target_q, 2, TARGET_W, intp.SRC[13])
    dut.i_target_q.value         = input.target_q
    # Set priority 3 to interrupt 31 
    input.target_q               = set_or_reg(input.target_q, 3, TARGET_W, intp.SRC[31])
    dut.i_target_q.value         = input.target_q

    await Timer(1, units="ns")

async def generate_clock(dut):
    """Generate clock pulses."""

    for cycle in range(10):
        dut.i_clk.value = 0
        await Timer(1, units="ns")
        dut.i_clk.value = 1
        await Timer(1, units="ns")

@cocotb.test()
async def notifier_unit_test(dut):
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

    # await cocotb.start(test_direct_mode(dut))

    await cocotb.start(test_msi_mode(dut))

    await Timer(15, units="ns")
    # assert dut.i_domaincfgIE.value      == input.domaincfgIE    , "Oh boy, you mess it up in domaincfgIE!"
    # assert dut.i_setip_q.value          == input.setip_q        , "Oh boy, you mess it up in setip_q!"
    # assert dut.i_setie_q.value          == input.setie_q        , "Oh boy, you mess it up in setie_q!"
    # assert dut.i_target_q.value         == input.target_q       , "Oh boy, you mess it up in target_q!"
    # assert dut.i_idelivery.value        == input.idelivery      , "Oh boy, you mess it up in idelivery!"
    # assert dut.i_iforce.value           == input.iforce         , "Oh boy, you mess it up in iforce!"
    # assert dut.i_ithreshold.value       == input.ithreshold     , "Oh boy, you mess it up in ithreshold!"

    # # assert dut.aplic_domain_notifier_i.has_valid_intp_i.value     == internal.has_valid_intp    , "Oh boy, you mess it up in has_valid_intp!"
    # # assert dut.aplic_domain_notifier_i.hart_index_i.value         == internal.hart_index        , "Oh boy, you mess it up in hart_index!"

    # assert dut.o_topi_update.value      == outputs.topi_update  , "Oh boy, you mess it up in topi_update!"
    # assert dut.o_topi_sugg.value        == outputs.topi_sugg    , "Oh boy, you mess it up in topi_sugg!"
    # assert dut.o_Xeip_targets.value     == outputs.Xeip_targets , "Oh boy, you mess it up in Xeip_targets!"