# from os import setpgid
# from readline import set_pre_input_hook
import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import math
import warnings
from user_define import *
from aia_define import *
from aia_regmap import *
import aplic_axi
from imsic_csr_channel import *

ONE_CYCLE = 2
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
RESET = "\033[0m"
NR_TESTS_INTP = len(TARGET_INTP)
TARGET_INTP_EN = [1] * NR_TESTS_INTP
NR_FILES_IMSIC = 2 + IMSIC_NR_VS_FILES


def clog2(x):
    if x <= 0:
        raise ValueError("Input must be a positive integer")
    return math.floor(math.log2(x))

def set_or_reg(reg, hexa, reg_width, reg_num):
    reg     = reg | (hexa << reg_width*reg_num)
    return reg

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

def get_expected_topi (target_hart, target_level):
    prev_prio = 255
    topi = 0
    cur_highest_intp = -1

    for i in range(NR_TESTS_INTP):
        if ((TARGET_HART[i] == target_hart) and (TARGET_LEVEL[i] == target_level)):
            if (TARGET_PRIO[i] < prev_prio):
                if (TARGET_INTP_EN[i] == 1):
                    prev_prio = TARGET_PRIO[i]
                    cur_highest_intp = TARGET_INTP[i]

    if (cur_highest_intp != -1):
        topi = (cur_highest_intp << 16) | prev_prio 

    return topi

def claim_interrupt (target_hart, target_level):
    topi = get_expected_topi(target_hart, target_level)
    topi_iid = topi >> 16
    if (topi != 0):
        for i in range(NR_TESTS_INTP):
            if (TARGET_HART[i] == target_hart and 
                TARGET_LEVEL[i] == target_level and 
                TARGET_INTP[i] == topi_iid):
                TARGET_INTP_EN[i] = 0

def check_user_test():    
    for i in range(NR_TESTS_INTP):
        if (TARGET_INTP[i] < 0 or TARGET_INTP[i] >= APLIC_NR_SRC):
            raise ValueError(f'{RED}Wrong value for TARGET_INTP[{i}]: {TARGET_INTP[i]}. It must be in the range [0, UserNrSources-1]. The later is the number of sources implemented by the AIA IP, and can be configured in aia_pkg.sv.{RESET}')
        if (AIA_MODE == DOMAIN_IN_MSI_MODE):
            if (TARGET_HART[i] < 0 or TARGET_HART[i] > IMSIC_NR_HARTS):
                raise ValueError(f'{RED}Wrong value for TARGET_HART[{i}]: {TARGET_HART[i]}. It must be in the range [0, UserNrHartsImsic-1]. The later is the number of IMSICs implemented by the AIA IP, and can be configured in aia_pkg.sv.{RESET}')
        elif (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
            if (TARGET_HART[i] < 0 or TARGET_HART[i] > APLIC_NR_HARTS):
                raise ValueError(f'{RED}Wrong value for TARGET_HART[{i}]: {TARGET_HART[i]}. It must be in the range [0, UserNrSources-1]. The later is the number of IDCs implemented by the AIA IP, and can be configured in aia_pkg.sv.{RESET}')
        if ((TARGET_LEVEL[i] != M_MODE) and (TARGET_LEVEL[i] != S_MODE)):
            raise ValueError(f'{RED}Wrong value for TARGET_LEVEL[{i}]: {TARGET_LEVEL[i]}. It must be M_MODE or S_MODE.{RESET}')
        if (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
            if (TARGET_PRIO[i] < 0 or TARGET_PRIO[i] > APLIC_MIN_PRIO):
                raise ValueError(f'{RED}Wrong value for TARGET_PRIO[{i}]: {TARGET_PRIO[i]}. It must be in the range [0, UserMinPrio-1]. The later is the min. priority that an interrupt can have (in aia spec. means the max. number), and can be configured in aia_pkg.sv.{RESET}')
            elif (TARGET_PRIO[i] == 0):
                TARGET_PRIO[i] = 1
                warnings.warn( f'{YELLOW}TARGET_PRIO[{i}] was configured as 0. Hardware will force it to 1. Changing TARGET_PRIO[{i}] expected value from 0 to 1...{RESET}', UserWarning )
        else:
            warnings.warn( f'{YELLOW}Ignoring TARGET_PRIO because AIA is functioning in MSI Mode{RESET}', UserWarning )
        if (AIA_MODE == DOMAIN_IN_MSI_MODE):
            if (TARGET_GUEST[i] < 0 or TARGET_GUEST[i] > IMSIC_NR_VS_FILES):
                raise ValueError(f'{RED}Wrong value for TARGET_GUEST[{i}]: {TARGET_GUEST[i]}. It must be in the range [0, UserNrVSIntpFiles-1]. The later is the number of VS files implemented per hart by the AIA IP, and can be configured in aia_pkg.sv.{RESET}')
            if ((TARGET_GUEST[i] == 1) and (TARGET_LEVEL[i] != S_MODE)):
                raise ValueError(f'{RED}Wrong value for TARGET_GUEST[{i}]. It only make sense to set the guest to 1 if the TARFET_LEVEL is S_MODE{RESET}')
        else:
            warnings.warn( f'{YELLOW}Ignoring TARGET_GUEST because AIA is functioning in DIRECT Mode{RESET}', UserWarning )

async def aia_integration(dut):
    number_of_necessary_claims = 0

    # Check if the variables set by user are inside the ranges defined in aia_pkg
    check_user_test()

    # Iterate over the hart and level to find matching pairs
    if (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
        for i in range(len(TARGET_HART)):
            for j in range(i + 1, len(TARGET_HART)):
                if TARGET_HART[i] == TARGET_HART[j] and TARGET_LEVEL[i] == TARGET_LEVEL[j]:
                    number_of_necessary_claims += 1
    EIE_OFF = []
    for i in range(NR_TESTS_INTP):
        eie_off_subrange = (TARGET_INTP[i]//RISCV_XLEN)*2 
        EIE_OFF.append(eie_off_subrange)

    if (AIA_MODE == DOMAIN_IN_MSI_MODE):
        print(f"{YELLOW}Strating IMSICs configurations...{RESET}")
        # Enable interrupt delivering in IMSICs
        for i in range(NR_TESTS_INTP):
            imsic_write_reg(dut, TARGET_HART[i], EDELIVERY, ENABLE_INTP_FILE, TARGET_LEVEL[i], TARGET_GUEST[i])
            await Timer(ONE_CYCLE, units="ns")

        # Enable target interrupts in IMSICs interrupt files 
        for i in range(NR_TESTS_INTP):
            imsic_write_reg(dut, TARGET_HART[i], EIE0+EIE_OFF[i], 1<<(TARGET_INTP[i]%RISCV_XLEN), TARGET_LEVEL[i], TARGET_GUEST[i])
            await Timer(ONE_CYCLE, units="ns")
        #are missing assertations here
    elif (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
        print(f"{YELLOW}Strating IDCs configurations...{RESET}")
        # Enable IDCs
        for i in range(NR_TESTS_INTP):
            if (TARGET_LEVEL[i] == M_MODE):        
                aplic_axi.axi_write_reg(dut, IDELIVERY_M_BASE + (0x20*(TARGET_HART[i]-1)), (1 << 0))
            elif (TARGET_LEVEL[i] == S_MODE):
                aplic_axi.axi_write_reg(dut, IDELIVERY_S_BASE + (0x20*(TARGET_HART[i]-1)), (1 << 0))
            await Timer(4, units="ns")  
        #are missing assertations here

    print(f"{YELLOW}Strating APLIC domains configurations...{RESET}")

    print(f"{YELLOW}    domaincfg sanity...{RESET}")
    domaincfg_expected_val = (0x80 << 24) | (1 << 8)
    domaincfg_val = (1 << 8)
    if (AIA_MODE == DOMAIN_IN_MSI_MODE):
        domaincfg_expected_val |= (1 << 2)
        domaincfg_val |= (1 << 2)
    
    # Enable M domain
    aplic_axi.axi_write_reg(dut, DOMAINCFG_M_BASE, domaincfg_val)
    await Timer(ONE_CYCLE*2, units="ns")
    aplic_axi.axi_stop(dut)
    await Timer(ONE_CYCLE*3, units="ns")
    aplic_axi.axi_read_reg(dut, DOMAINCFG_M_BASE)
    await Timer(ONE_CYCLE*2, units="ns")

    try:
        assert dut.reg_intf_resp_d32_rdata.value == domaincfg_expected_val, "M domaincfg does not match expected value"
        print(f"{GREEN}PASSED: domaincfg[M] = {hex(domaincfg_expected_val)}{RESET}")
    except AssertionError as e:
        print(f"{RED}AssertionError: {e}{RESET}")

    # Enable S domain
    aplic_axi.axi_write_reg(dut, DOMAINCFG_S_BASE, domaincfg_val)
    await Timer(ONE_CYCLE, units="ns")
    aplic_axi.axi_stop(dut)
    await Timer(ONE_CYCLE*3, units="ns")
    aplic_axi.axi_read_reg(dut, DOMAINCFG_M_BASE)
    await Timer(ONE_CYCLE*2, units="ns")

    try:
        assert dut.reg_intf_resp_d32_rdata.value == domaincfg_expected_val, "S domaincfg does not match expected value"
        print(f"{GREEN}PASSED: domaincfg[S] = {hex(domaincfg_expected_val)}{RESET}")
    except AssertionError as e:
        print(f"{RED}AssertionError: {e}{RESET}")

    print(f"{YELLOW}    sourcecfg sanity...{RESET}")
    # configure the sourcecfg registers in APLIC for the target interrupts
    sourcecfg_m_expected_val = []
    sourcecfg_s_expected_val = []
    for i in range(NR_TESTS_INTP):
        if (TARGET_LEVEL[i] == S_MODE):
            aplic_axi.axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), (DELEGATE_SRC | 0x0))
            sourcecfg_m_expected_val.append((DELEGATE_SRC | 0x0))
            await Timer(ONE_CYCLE, units="ns")
            aplic_axi.axi_stop(dut)
            await Timer(ONE_CYCLE*3, units="ns")
            aplic_axi.axi_write_reg(dut, SOURCECFG_S_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
            sourcecfg_s_expected_val.append(4)
        else:
            aplic_axi.axi_write_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)), 4)
            sourcecfg_m_expected_val.append(4)
            sourcecfg_s_expected_val.append(0)
        await Timer(ONE_CYCLE, units="ns")
        aplic_axi.axi_stop(dut)
        await Timer(ONE_CYCLE*3, units="ns")

    # Read the sourcecfg to validate the logic of rebuilding sourcecfg register
    for i in range(NR_TESTS_INTP):
        aplic_axi.axi_read_reg(dut, SOURCECFG_M_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)))
        await Timer(ONE_CYCLE*4, units="ns")
        cur_axi_read_val = dut.reg_intf_resp_d32_rdata.value 
        aplic_axi.axi_stop(dut)
        await Timer(ONE_CYCLE*4, units="ns")
        
        try:
            assert cur_axi_read_val == sourcecfg_m_expected_val[i], "sourcecfg in M does not match the expected value"
            print(f"{GREEN}PASSED: sourcecfg[M][{TARGET_INTP[i]}] = {hex(sourcecfg_m_expected_val[i])}{RESET}")
        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

        aplic_axi.axi_read_reg(dut, SOURCECFG_S_BASE+(SOURCECFG_OFF * (TARGET_INTP[i]-1)))
        await Timer(ONE_CYCLE*4, units="ns")
        cur_axi_read_val = dut.reg_intf_resp_d32_rdata.value 
        aplic_axi.axi_stop(dut)
        await Timer(ONE_CYCLE*4, units="ns")

        try:
            assert cur_axi_read_val == sourcecfg_s_expected_val[i], "sourcecfg in S does not match the expected value"
            print(f"{GREEN}PASSED: sourcecfg[S][{TARGET_INTP[i]}] = {hex(sourcecfg_s_expected_val[i])}{RESET}")
        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

    # configure the target registers in APLIC for the target interrupts
    for i in range(NR_TESTS_INTP):
        if (AIA_MODE == DOMAIN_IN_MSI_MODE):
            if(TARGET_LEVEL[i] == M_MODE):
                aplic_axi.axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_INTP[i] << 0))
            else:
                aplic_axi.axi_write_reg(dut, TARGET_S_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_GUEST[i] << 12) | (TARGET_INTP[i] << 0))
        elif (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
            if(TARGET_LEVEL[i] == M_MODE):
                aplic_axi.axi_write_reg(dut, TARGET_M_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_PRIO[i] << 0))
            else:
                aplic_axi.axi_write_reg(dut, TARGET_S_BASE+(TARGET_OFF * (TARGET_INTP[i]-1)), ((TARGET_HART[i]-1) << 18) | (TARGET_PRIO[i] << 0))

        await Timer(ONE_CYCLE, units="ns")
        aplic_axi.axi_stop(dut)
        await Timer(ONE_CYCLE*3, units="ns")
    # are missing target asserts

    # enable target interrupts in their respective domain
    for i in range(NR_TESTS_INTP):
        if(TARGET_LEVEL[i] == M_MODE):
            aplic_axi.axi_write_reg(dut, SETIENUM_M_BASE, TARGET_INTP[i])
        else:
            aplic_axi.axi_write_reg(dut, SETIENUM_S_BASE, TARGET_INTP[i])
        await Timer(ONE_CYCLE, units="ns")
        aplic_axi.axi_stop(dut)
        await Timer(ONE_CYCLE*3, units="ns")

    # We now start triggering the interrupts
    if(TARGET_LEVEL[0] == M_MODE):
        aplic_axi.axi_write_reg(dut, SETIPNUM_M_BASE, TARGET_INTP[0])
    else:
        aplic_axi.axi_write_reg(dut, SETIPNUM_S_BASE, TARGET_INTP[0])
    await Timer(ONE_CYCLE, units="ns")
    aplic_axi.axi_stop(dut)
    await Timer(ONE_CYCLE*3, units="ns")
    # Write to domain (or other register really) to reset the write lines
    # This is a bug in the tests and not the hw
    # We intend to fix this in the future :) 
    aplic_axi.axi_write_reg(dut, DOMAINCFG_M_BASE, (1 << 8) | (1 << 2))
    await Timer(ONE_CYCLE, units="ns")
    aplic_axi.axi_stop(dut)
    await Timer(ONE_CYCLE*3, units="ns")
    
    for i in range(1, NR_TESTS_INTP):
        source                = 0
        source                = set_or_reg(source, 1, 1, TARGET_INTP[i])
        dut.i_sources.value   = source
        await Timer(4, units="ns")
        # reset source lines
        source                = 0
        dut.i_sources.value   = source
        await Timer(10, units="ns")

    if (AIA_MODE == DOMAIN_IN_MSI_MODE):
        print(f"{YELLOW}    xtopei sanity...{RESET}")
        xtopei_array = organize_xtopei(dut.xtopei.value, IMSIC_NR_HARTS, NR_FILES_IMSIC, clog2(IMSIC_NR_SRC-1))

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

        print(f"{YELLOW}    Strat interrupts claiming...{RESET}")
        print(f"{YELLOW}    xtopei sanity...{RESET}")
        # Clear the pending interrupt
        for i in range(NR_TESTS_INTP):
            imsic_write_xtopei(dut, TARGET_HART[i], TARGET_LEVEL[i], TARGET_GUEST[i])
            await Timer(ONE_CYCLE*3, units="ns")
            imsic_stop_write(dut)
            await Timer(ONE_CYCLE, units="ns")

        xtopei_array = organize_xtopei(dut.xtopei.value, IMSIC_NR_HARTS, NR_FILES_IMSIC, clog2(IMSIC_NR_SRC-1))

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

    # are missing assertations for cpu line
    elif (AIA_MODE == DOMAIN_IN_DIRECT_MODE):
        print(f"{YELLOW}    topi and CPU line sanity...{RESET}")
        # target = dut.o_eintp_cpu.value

        # this part is trying to evaluate the cpu line and the topi value
        # Since an interrupt can be configured for the same hart and same domain level
        # we repeat this test "number_of_necessary_claims" times (for all harts and domains, for sanity porpuses)
        # What "number_of_necessary_claims" means? 
        # At the function start we search for how many matching pairs (TARGET_HART and TARGET_LEVEL) across the various
        # interrupt indexes. This is, if determine how many interrupts have the same target hart and same level.
        # Why not just clami that interrupt specifically and evaluate only that hart and level?
        # We could, but we dont... Sanity check porpuse.
        w = 0
        while w <= number_of_necessary_claims:
            
            print(f"{YELLOW}    starting round {w} of {number_of_necessary_claims}...{RESET}")

            for i in range(APLIC_NR_HARTS):
                for j in range(APLIC_NR_DOMAINS):
                    if (j == 0):
                        TOPI_BASE = CLAIMI_M_BASE
                        MODE = M_MODE
                    else:
                        TOPI_BASE = CLAIMI_S_BASE
                        MODE = S_MODE

                    target = dut.o_eintp_cpu.value
                    aplic_axi.axi_read_reg(dut, TOPI_BASE + (0x20 * i))
                    await Timer(ONE_CYCLE, units="ns")
                    cur_axi_read_val = dut.reg_intf_resp_d32_rdata.value 
                    expected_topi_val = get_expected_topi(i+1, MODE)
                    if (expected_topi_val != 0):
                        expected_cpu_line_val = 1
                    else:
                        expected_cpu_line_val = 0
                    claim_interrupt(i+1, MODE)
                    aplic_axi.axi_stop(dut)
                    await Timer(ONE_CYCLE*4, units="ns")

                    try:
                        assert expected_cpu_line_val == target[APLIC_NR_DOMAINS-j-1][APLIC_NR_HARTS-i-1], f"cpu_line[{j}][{i}] does not match the expected value"
                        print(f"{GREEN}PASSED: cpu_line[{j}][{i}] = {expected_cpu_line_val}{RESET}")
                        assert cur_axi_read_val == expected_topi_val, f"topi[{j}][{i}] does not match the expected value"
                        print(f"{GREEN}PASSED: topi[{j}][{i}] = {hex(expected_topi_val)}{RESET}")
                    except AssertionError as e:
                        print(f"{RED}AssertionError: {e}{RESET}")
                    
            w += 1

        print(f"{YELLOW}    topi and CPU line sanity after claiming every interrupt...{RESET}")
        # for each hart in each domain, check if all interrupts were claimed
        for i in range(APLIC_NR_HARTS):
            for j in range(APLIC_NR_DOMAINS):
                if (j == 0):
                    TOPI_BASE = TOPI_M_BASE
                    MODE = M_MODE
                else:
                    TOPI_BASE = TOPI_S_BASE
                    MODE = S_MODE

                aplic_axi.axi_read_reg(dut, TOPI_BASE + (0x20 * i))
                await Timer(ONE_CYCLE*4, units="ns")
                cur_axi_read_val = dut.reg_intf_resp_d32_rdata.value 
                expected_topi_val = get_expected_topi(i+1, MODE)
                aplic_axi.axi_stop(dut)
                await Timer(ONE_CYCLE*4, units="ns")

                try:
                    assert cur_axi_read_val == expected_topi_val, f"topi[{j}][{i}] does not match the expected value"
                    print(f"{GREEN}PASSED: topi[{j}][{i}] = {hex(expected_topi_val)}{RESET}")
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
    
    await cocotb.start(aia_integration(dut))
    await Timer(10000, units="ns")