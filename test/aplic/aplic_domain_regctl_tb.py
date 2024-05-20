# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import aplic_addr
import aplic_axi
from aplic_addr import M_MODE, S_MODE, NR_SRC, NR_DOMAINS, NR_HART, MIN_PRIO
from aplic_addr import sourcecfg_SM
from aplic_addr import DELEGATE_SRC, INACTIVE, DETACHED, EDGE1, EDGE0, LEVEL1, LEVEL0
import random

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
RESET = "\033[0m"

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

def organize_by_src(array, nr_src = 0, length=11):
    index = 0
    organized_data = []

    if (nr_src == 0):
        raise("NR_SRC must be greater than 0")
    
    for i in range(nr_src-1):
        subrange = array[index:index + (length-1)]
        index = index + length
        organized_data.append(subrange)

    organized_data.reverse()

    return organized_data

async def domaincfg_test(dut):
    domain_expected_val = (0x80 << 24) | (1 << 8)
    aplic_axi.axi_write_reg(dut, aplic_addr.APLIC_M_BASE, 1<<8)
    await Timer(4, units="ns")
    aplic_axi.axi_write_reg(dut, aplic_addr.APLIC_S_BASE, 1<<8)
    await Timer(4, units="ns")

    domain_m_val = dut.i_aplic_domain_regctl.domaincfg_q.value[32:63]
    domain_s_val = dut.i_aplic_domain_regctl.domaincfg_q.value[0:31]

    try:
        assert domain_m_val == domain_expected_val , "domain[M] does not match expected value"
        print(f"{GREEN}PASSED: domaincfg[M] = {domain_m_val} {RESET}")
        assert domain_s_val == domain_expected_val , "domain[S] does not match expected value"
        print(f"{GREEN}PASSED: domaincfg[S] = {domain_s_val} {RESET}")

    except AssertionError as e:
        print(f"{RED}AssertionError: {e}{RESET}")

async def sourcecfg_test(dut):
    global sourcecfg_m_val_org
    global sourcecfg_s_val_org

    expected_SM_M = []
    expected_SM_S = []
    for i in range(NR_SRC-1):
        config_id = random.randint(0, len(sourcecfg_SM)-1)
        expected_SM_M.append(sourcecfg_SM[config_id])
        
        aplic_axi.axi_write_reg(dut, aplic_addr.sourcecfg(i+1, M_MODE), sourcecfg_SM[config_id])
        await Timer(4, units="ns")

        if (sourcecfg_SM[config_id] == DELEGATE_SRC):
            expected_SM_S.append(EDGE1) 
        
            aplic_axi.axi_write_reg(dut, aplic_addr.sourcecfg(i+1, S_MODE), EDGE1)
            await Timer(4, units="ns")
        else:
            expected_SM_S.append(INACTIVE) 

    sourcecfg_m_val = dut.i_aplic_domain_regctl.sourcecfg_full.value[(11*(NR_SRC-1)):(11*(NR_SRC-1)*NR_DOMAINS)-1]
    sourcecfg_s_val = dut.i_aplic_domain_regctl.sourcecfg_full.value[0:(11*(NR_SRC-1))-1]
    sourcecfg_m_val_org = organize_by_src(sourcecfg_m_val, NR_SRC, 11)
    sourcecfg_s_val_org = organize_by_src(sourcecfg_s_val, NR_SRC, 11)

    for i in range(NR_SRC-1):
        try:
            assert sourcecfg_m_val_org[i] == expected_SM_M[i] , "sourcecfg[M] does not match expected value"
            print(f"{GREEN}PASSED: sourcecfg[M][{i+1}] = {sourcecfg_m_val_org[i]} {RESET}")
            assert sourcecfg_s_val_org[i] == expected_SM_S[i] , "sourcecfg[S] does not match expected value"
            print(f"{GREEN}PASSED: sourcecfg[S][{i+1}] = {sourcecfg_s_val_org[i]} {RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

async def target_test(dut):
    expected_target_M = []
    expected_target_S = []

    for i in range(NR_SRC-1):
        target_hart_m = random.randint(0, NR_HART-1) 
        target_hart_s = random.randint(0, NR_HART-1) 
        target_prio_m = random.randint(0, MIN_PRIO-1) # we allow to target prio to be 0, and in such cases, 
        target_prio_s = random.randint(0, MIN_PRIO-1) # we expect that hardware set it to 1 

        if ((sourcecfg_m_val_org[i] != DELEGATE_SRC) and (sourcecfg_m_val_org[i] != INACTIVE)):
            if (target_prio_m != 0):
                expected_target_M.append((target_hart_m<<18) | target_prio_m)
            else:
                expected_target_M.append((target_hart_m<<18) | 1)

        else:
            expected_target_M.append(0)
        
        if ((sourcecfg_s_val_org[i] != DELEGATE_SRC) and (sourcecfg_s_val_org[i] != INACTIVE)):
            if (target_prio_s != 0):
                expected_target_S.append((target_hart_s<<18) | target_prio_s)
            else:
                expected_target_S.append((target_hart_s<<18) | 1)
                
        else:
            expected_target_S.append(0)
        
        aplic_axi.axi_write_reg(dut, aplic_addr.target(i+1, M_MODE), expected_target_M[i])
        await Timer(4, units="ns")
        aplic_axi.axi_write_reg(dut, aplic_addr.target(i+1, S_MODE), expected_target_S[i])
        await Timer(4, units="ns")
    
    target_m_val = dut.i_aplic_domain_regctl.target_full.value[(32*(NR_SRC-1)):(32*(NR_SRC-1)*NR_DOMAINS)-1]
    target_s_val = dut.i_aplic_domain_regctl.target_full.value[0:(32*(NR_SRC-1))-1]
    target_m_val_org = organize_by_src(target_m_val, NR_SRC, 32)
    target_s_val_org = organize_by_src(target_s_val, NR_SRC, 32)

    for i in range(NR_SRC-1):
        try:
            assert target_m_val_org[i] == expected_target_M[i] , "target[M] does not match expected value"
            print(f"{GREEN}PASSED: target[M][{i+1}] = {target_m_val_org[i]} {RESET}")
            assert target_s_val_org[i] == expected_target_S[i] , "target[S] does not match expected value"
            print(f"{GREEN}PASSED: target[S][{i+1}] = {target_s_val_org[i]} {RESET}")

        except AssertionError as e:
            print(f"{RED}AssertionError: {e}{RESET}")

async def idc_test(dut):

    for i in range(NR_HART):
        aplic_axi.axi_write_reg(dut, aplic_addr.idc(i, aplic_addr.IDELIVERY, M_MODE), 1)
        await Timer(4, units="ns")
        aplic_axi.axi_write_reg(dut, aplic_addr.idc(i, aplic_addr.IDELIVERY, S_MODE), 1)
        await Timer(4, units="ns")

    for i in range(NR_HART):
        aplic_axi.axi_write_reg(dut, aplic_addr.idc(i, aplic_addr.IFORCE, M_MODE), 1)
        await Timer(4, units="ns")
        aplic_axi.axi_write_reg(dut, aplic_addr.idc(i, aplic_addr.IFORCE, S_MODE), 1)
        await Timer(4, units="ns")
    
    iforce = dut.i_aplic_domain_regctl.iforce_q.value

    try:
        assert iforce == 0b1111 , "iforce does not match expected value"
        print(f"{GREEN}PASSED: iforce = {iforce} {RESET}")

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

    await cocotb.start(domaincfg_test(dut))
    await Timer(500, units="ns")

    await cocotb.start(sourcecfg_test(dut))
    await Timer(10000, units="ns")

    await cocotb.start(target_test(dut))
    await Timer(10000, units="ns")
    
    await cocotb.start(idc_test(dut))
    await Timer(500, units="ns")