from os import setpgid
from readline import set_pre_input_hook
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import math
from aia_define import APLIC_TYPE, IRQC_TYPE

APLIC_MINIMAL = 1
APLIC_SCALABLE = 2

IRQC_APLIC = 1
IRQC_AIA = 2
IRQC_IEAIA = 3

ONE_CYCLE               = 2

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

# Genmsi macros
GENMSI_M_BASE           = APLIC_M_BASE + 0x3000
GENMSI_S_BASE           = APLIC_S_BASE + 0x3000

# IDC macros
IDELIVERY_M_BASE        = APLIC_M_BASE + 0x4000 + 0x00
IDELIVERY_S_BASE        = APLIC_S_BASE + 0x4000 + 0x00
IFORCE_M_BASE           = APLIC_M_BASE + 0x4000 + 0x04
IFORCE_S_BASE           = APLIC_S_BASE + 0x4000 + 0x04
ITHRESHOLD_M_BASE       = APLIC_M_BASE + 0x4000 + 0x08
ITHRESHOLD_S_BASE       = APLIC_S_BASE + 0x4000 + 0x08
CLAIMI_M_BASE           = APLIC_M_BASE + 0x4000 + 0x1C
CLAIMI_S_BASE           = APLIC_S_BASE + 0x4000 + 0x1C

# IMSIC macros
EDELIVERY               = 0X70
EITHRESHOLD             = 0X72
EIE0                    = 0xC0

M_MODE                  = 3 
S_MODE                  = 1

ENABLE_INTP_FILE        = 1
DISABLE_INTP_FILE       = 0

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
RESET = "\033[0m"

class CInputs:
    i_ready                    = 0
    i_addr                     = 0
    i_data                     = 0
    i_select_imsic             = 0
    i_priv_lvl                 = 0
    i_vgein                    = 0
    i_imsic_addr               = 0
    i_imsic_data               = 0
    i_imsic_we                 = 0
    i_imsic_claim              = 0
    reg_intf_req_a32_d32_addr  = 0
    reg_intf_req_a32_d32_write = 0
    reg_intf_req_a32_d32_wdata = 0
    reg_intf_req_a32_d32_wstrb = 0
    reg_intf_req_a32_d32_valid = 0

class COutputs:
    reg_intf_resp_d32_rdata = 0
    reg_intf_resp_d32_error = 0
    reg_intf_resp_d32_ready = 0

input                   = CInputs()
outputs                 = COutputs()

def clog2(x):
    if x <= 0:
        raise ValueError("Input must be a positive integer")
    return math.floor(math.log2(x))

def set_or_reg(reg, hexa, reg_width, reg_num):
    reg     = reg | (hexa << reg_width*reg_num)
    return reg

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

def organize_topi(array, nr_idcs = 0, nr_domains = 0, length=25):
    index = 0
    organized_data = []
    final_result = []

    if (nr_idcs == 0 or nr_domains == 0):
        raise("NR_IMSIC or NR_INTP_FILES lower than 1")
    
    for i in range(nr_idcs):
        for j in range(nr_domains):
            subrange = array[index:index + length]
            index = index + length + 1
            organized_data.append(subrange)
        organized_data.reverse()
        final_result.append(organized_data)
        organized_data = []

    final_result.reverse()
    return final_result

##############################################
# Before running this test make sure that:
# NR_IMSICS = 4
# NR_VS_FILES_PER_IMSIC = 1
##############################################
async def aia_msi(dut):
    #######################################################################################################
    # Configurable variables
    #######################################################################################################
    TARGET_INTP = [30, 10, 3] # <0...255>
    TARGET_HART = [1, 3, 4] # <1...4>
    TARGET_LEVEL = [M_MODE, S_MODE, S_MODE] # <M_MODE, S_MODE>
    TARGET_GUEST = [0, 1, 0] # <0, 1> 
    #######################################################################################################
    IMSIC_MAX_SRC = 64
    NR_VS_FILES_IMSIC = 1
    NR_IMSICS = 4
    NR_FILES_IMSIC = 2 + NR_VS_FILES_IMSIC

    for i in range(3):
        if ((TARGET_GUEST[i] == 1) and (TARGET_LEVEL[i] != S_MODE)):
            raise ValueError('Wrong value for TARGET_GUEST[{}]. It only make sense to set the guest to 1 if the TARFET_LEVEL is S_MODE'.format(i))

    XLEN = 64
    EIE_OFF = [(TARGET_INTP[0]//XLEN)*2, (TARGET_INTP[1]//XLEN)*2, (TARGET_INTP[2]//XLEN)*2]
    # needs refact. Is TARGET_APLIC_MODE needed?
    TARGET_APLIC_MODE = [APLIC_M_BASE, APLIC_M_BASE, APLIC_M_BASE]
    for i in range(3):
        if (TARGET_LEVEL[i] == S_MODE):
            TARGET_APLIC_MODE[i] = APLIC_S_BASE


    # Enable interrupt delivering in IMSICs
    for i in range(3):
        imsic_write_reg(dut, TARGET_HART[i], EDELIVERY, ENABLE_INTP_FILE, TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE, units="ns")

    # Enable target interrupts in IMSICs interrupt files 
    for i in range(3):
        imsic_write_reg(dut, TARGET_HART[i], EIE0+EIE_OFF[i], 1<<(TARGET_INTP[i]%XLEN), TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE, units="ns")

    # Enable M domain in MSI mode
    axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")
    # Enable S domain in MSI mode
    axi_write_reg(dut, DOMAINCFG_S_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")

    # configure the sourcecfg registers in APLIC for the target interrupts
    for i in range(3):
        if (TARGET_APLIC_MODE[i] == APLIC_S_BASE):
            axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), DELEGATE_SRC)
            await Timer(4, units="ns")
            axi_write_reg(dut, SOURCECFG_S_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
        else:
            axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
        await Timer(4, units="ns")

    # configure the target registers in APLIC for the target interrupts
    for i in range(3):
        if(TARGET_LEVEL[i] == M_MODE):
            axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_INTP[i] << 0))
        else:
            axi_write_reg(dut, TARGET_S_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_GUEST[i] << 12) | (TARGET_INTP[i] << 0))
        await Timer(4, units="ns")

    # enable target interrupts in their respective domain
    for i in range(3):
        if(TARGET_LEVEL[i] == M_MODE):
            axi_write_reg(dut, SETIENUM_M_BASE, TARGET_INTP[i])
        else:
            axi_write_reg(dut, SETIENUM_S_BASE, TARGET_INTP[i])
        await Timer(4, units="ns")

    # We now start triggering the interrupts
    if(TARGET_LEVEL[0] == M_MODE):
        axi_write_reg(dut, SETIPNUM_M_BASE, TARGET_INTP[0])
    else:
        axi_write_reg(dut, SETIPNUM_S_BASE, TARGET_INTP[0])
    await Timer(4, units="ns")
    # Write to domain (or other register really) to reset the write lines
    # This is a bug in the tests and not the hw
    # We intend to fix this in the future :) 
    axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")
    
    # set interrupt 23 (to trigger the raising edge)
    source                = 0
    source                = set_or_reg(source, 1, 1, TARGET_INTP[1])
    dut.i_sources.value   = source
    await Timer(4, units="ns")
    # reset source lines
    source                = 0
    dut.i_sources.value   = source
    await Timer(10, units="ns")

    # set interrupt 1 (to trigger the raising edge)
    source                = set_or_reg(source, 1, 1, TARGET_INTP[2])
    dut.i_sources.value   = source
    await Timer(4, units="ns")
    # reset source lines
    source                = 0
    dut.i_sources.value   = source
    await Timer(10, units="ns")

    xtopei_array = organize_xtopei(dut.xtopei.value, NR_IMSICS, NR_FILES_IMSIC, clog2(IMSIC_MAX_SRC-1))

    for i in range(3):
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
    for i in range(3):
        imsic_write_xtopei(dut, TARGET_HART[i], TARGET_LEVEL[i], TARGET_GUEST[i])
        await Timer(ONE_CYCLE*3, units="ns")
        imsic_stop_write(dut)
        await Timer(ONE_CYCLE, units="ns")

    xtopei_array = organize_xtopei(dut.xtopei.value, NR_IMSICS, NR_FILES_IMSIC, clog2(IMSIC_MAX_SRC-1))

    for i in range(3):
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

async def aia_direct(dut):
    #######################################################################################################
    # Configurable variables
    #######################################################################################################
    TARGET_INTP = [30, 10, 3] # <0...255>
    TARGET_HART = [1, 2, 1] # <1...4>
    TARGET_LEVEL = [M_MODE, S_MODE, S_MODE] # <M_MODE, S_MODE>
    TARGET_PRIO = [0, 0, 0] # <0, 1> 
    #######################################################################################################
    NR_IDCs = 2
    NR_DOMAINS = 2

    # Enable M domain in MSI mode
    axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")
    # Enable S domain in MSI mode
    axi_write_reg(dut, DOMAINCFG_S_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")

    # Enable IDCs
    for i in range(3):
        if (TARGET_LEVEL[i] == M_MODE):        
            axi_write_reg(dut, IDELIVERY_M_BASE + (0x20*(TARGET_HART[i]-1)), (1 << 0))
        elif (TARGET_LEVEL[i] == S_MODE):
            axi_write_reg(dut, IDELIVERY_S_BASE + (0x20*(TARGET_HART[i]-1)), (1 << 0))
        await Timer(4, units="ns")    

    # configure the sourcecfg registers in APLIC for the target interrupts
    for i in range(3):
        if (TARGET_LEVEL[i] == S_MODE):
            axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), DELEGATE_SRC)
            await Timer(4, units="ns")
            axi_write_reg(dut, SOURCECFG_S_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
        else:
            axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
        await Timer(4, units="ns")

    # configure the target registers in APLIC for the target interrupts
    for i in range(3):
        if(TARGET_LEVEL[i] == M_MODE):
            axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_PRIO[i] << 0))
        else:
            axi_write_reg(dut, TARGET_S_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_PRIO[i] << 0))
        await Timer(4, units="ns")

    # enable target interrupts in their respective domain
    for i in range(3):
        if(TARGET_LEVEL[i] == M_MODE):
            axi_write_reg(dut, SETIENUM_M_BASE, TARGET_INTP[i])
        else:
            axi_write_reg(dut, SETIENUM_S_BASE, TARGET_INTP[i])
        await Timer(4, units="ns")

    # We now start triggering the interrupts
    if(TARGET_LEVEL[0] == M_MODE):
        axi_write_reg(dut, SETIPNUM_M_BASE, TARGET_INTP[0])
    else:
        axi_write_reg(dut, SETIPNUM_S_BASE, TARGET_INTP[0])
    await Timer(4, units="ns")
    # Write to domain (or other register really) to reset the write lines
    # This is a bug in the tests and not the hw
    # We intend to fix this in the future :) 
    axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8) | (1 << 2))
    await Timer(4, units="ns")
    
    # set interrupt 23 (to trigger the raising edge)
    source                = 0
    source                = set_or_reg(source, 1, 1, TARGET_INTP[1])
    dut.i_sources.value   = source
    await Timer(4, units="ns")
    # reset source lines
    source                = 0
    dut.i_sources.value   = source
    await Timer(10, units="ns")

    # set interrupt 1 (to trigger the raising edge)
    source                = set_or_reg(source, 1, 1, TARGET_INTP[2])
    dut.i_sources.value   = source
    await Timer(4, units="ns")
    # reset source lines
    source                = 0
    dut.i_sources.value   = source
    await Timer(10, units="ns")

    target_per_domains = []
    index = 0

    if (APLIC_TYPE == APLIC_MINIMAL):
        topi = organize_topi(dut.aplic_top_i.i_aplic_generic_domain_top.i_aplic_domain_regctl_minimal.topi_q.value, NR_IDCs, NR_DOMAINS, 25)
        target = dut.aplic_top_i.o_Xeip_targets.value
    elif (APLIC_TYPE == APLIC_SCALABLE):
        topi_m_q = dut.aplic_top_i.i_aplic_m_domain_top.i_aplic_domain_regctl.topi_q.value
        topi_s_q = dut.aplic_top_i.i_aplic_s_domain_top.i_aplic_domain_regctl.topi_q.value
        topi_m = organize_topi(topi_m_q, NR_IDCs, 1, 25)
        topi_s = organize_topi(topi_s_q, NR_IDCs, 1, 25)
        target = dut.aplic_top_i.o_Xeip_targets.value

    for i in range(NR_DOMAINS):
        subrange = target[index:index+(NR_DOMAINS-1)]
        index = index+(NR_DOMAINS*(i+1))
        target_per_domains.append(subrange)
        target_per_domains.reverse()
    target_per_domains.reverse()

    for i in range(3):
        try:
            if (TARGET_LEVEL[i] == M_MODE):
                assert target_per_domains[0][TARGET_HART[i]-1] == 1, "xtarget does not match with expected value"
                if (APLIC_TYPE == APLIC_MINIMAL):
                    assert topi[0][TARGET_HART[i]-1] == (TARGET_INTP[i] << 16) | (TARGET_PRIO[i] << 0), "topi does not match with expected value"
                else:
                    assert topi_m[TARGET_HART[i]-1][0] == (TARGET_INTP[i] << 16) | (TARGET_PRIO[i] << 0), "topi does not match with expected value"
                print(f"{GREEN}PASSED: topi[{TARGET_HART[i]-1}][M][x:16] = {TARGET_INTP[i]}{RESET}")
            else:
                assert target_per_domains[1][TARGET_HART[i]-1] == 1, "xtarget does not match with expected value"
                if (APLIC_TYPE == APLIC_MINIMAL):
                    assert topi[1][TARGET_HART[i]-1] == (TARGET_INTP[i] << 16) | (TARGET_PRIO[i] << 0), "topi does not match with expected value"
                else:
                    assert topi_s[TARGET_HART[i]-1][0] == (TARGET_INTP[i] << 16) | (TARGET_PRIO[i] << 0), "topi does not match with expected value"
                print(f"{GREEN}PASSED: topi[{TARGET_HART[i]-1}][S][x:16] = {TARGET_INTP[i]}{RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

    print(f"{YELLOW}Strat claiming interrupts...")
    
    for i in range(3):
        if (TARGET_LEVEL[i] == M_MODE):
            axi_read_reg(dut, (CLAIMI_M_BASE+(0x20*(TARGET_HART[i]-1))))
        else:
            axi_read_reg(dut, (CLAIMI_S_BASE+(0x20*(TARGET_HART[i]-1))))
        await Timer(4, units="ns")

    if (APLIC_TYPE == APLIC_MINIMAL):
        topi = organize_topi(dut.aplic_top_i.i_aplic_generic_domain_top.i_aplic_domain_regctl_minimal.topi_q.value, NR_IDCs, NR_DOMAINS, 25)
        target = dut.aplic_top_i.o_Xeip_targets.value
    elif (APLIC_TYPE == APLIC_SCALABLE):
        topi_m_q = dut.aplic_top_i.i_aplic_m_domain_top.i_aplic_domain_regctl.topi_q.value
        topi_s_q = dut.aplic_top_i.i_aplic_s_domain_top.i_aplic_domain_regctl.topi_q.value
        topi_m = organize_topi(topi_m_q, NR_IDCs, 1, 25)
        topi_s = organize_topi(topi_s_q, NR_IDCs, 1, 25)
        target = dut.aplic_top_i.o_Xeip_targets.value

    index = 0
    target_per_domains = []
    for i in range(NR_DOMAINS):
        subrange = target[index:index+(NR_DOMAINS-1)]
        index = index+(NR_DOMAINS*(i+1))
        target_per_domains.append(subrange)
        target_per_domains.reverse()
    target_per_domains.reverse()

    for i in range(3):
        try:
            if (TARGET_LEVEL[i] == M_MODE):
                assert target_per_domains[0][TARGET_HART[i]-1] == 0, "xtarget does not match with expected value"
                if (APLIC_TYPE == APLIC_MINIMAL):
                    assert topi[0][TARGET_HART[i]-1] == 0, "topi does not match with expected value"
                else:
                    assert topi_m[TARGET_HART[i]-1][0] == 0, "topi does not match with expected value"
                print(f"{GREEN}PASSED: topi[{TARGET_HART[i]-1}][M][x:16] = 0{RESET}")
            else:
                assert target_per_domains[1][TARGET_HART[i]-1] == 0, "xtarget does not match with expected value"
                if (APLIC_TYPE == APLIC_MINIMAL):
                    assert topi[1][TARGET_HART[i]-1] == 0, "topi does not match with expected value"
                else:
                    assert topi_s[TARGET_HART[i]-1][0] == 0, "topi does not match with expected value"
                print(f"{GREEN}PASSED: topi[{TARGET_HART[i]-1}][S][x:16] = 0{RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

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
    
    if (IRQC_TYPE == IRQC_APLIC):
        await cocotb.start(aia_direct(dut))
    else:
        await cocotb.start(aia_msi(dut))
    
    await Timer(10000, units="ns")