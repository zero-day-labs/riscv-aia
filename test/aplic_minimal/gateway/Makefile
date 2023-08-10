# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

# Notifier Makefile

CLEAN =

# defaults
SIM ?= verilator
EXTRA_ARGS += --trace --trace-structs
TOPLEVEL_LANG ?= verilog

AXI_FOLDER = $(PWD)/../../../vendor/
TEST_FOLDER = $(currdir) 
SRC_FOLDER = $(PWD)/../../../rtl/
WRAPPER_SRC = $(TEST_FOLDER)./wrap.sv
APLIC_FOLDER = $(SRC_FOLDER)/aplic
APLIC_COMMON_FOLDER = $(APLIC_FOLDER)/common
APLIC_MINIMAL_FOLDER = $(APLIC_FOLDER)/minimal
APLIC_SCALABLE_FOLDER = $(APLIC_FOLDER)/scalable

VERILOG_SOURCES += $(AXI_FOLDER)reg_intf_pkg.sv
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/aplic_defines.svh
VERILOG_SOURCES += $(APLIC_MINIMAL_FOLDER)/aplic_domain_regctl.sv
VERILOG_SOURCES += $(APLIC_MINIMAL_FOLDER)/aplic_regmap.sv
VERILOG_SOURCES += $(APLIC_MINIMAL_FOLDER)/aplic_domain_gateway.sv
VERILOG_SOURCES += $(WRAPPER_SRC)

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = aplic_domain_gateway_wrapper

# MODULE is the basename of the Python test file
MODULE = aplic_domain_gateway_tb

ifeq ($(CLEAN),)
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
else
all:
	rm -rf $(PWD)/__pycache__
	rm -rf $(PWD)/sim_build
	rm $(PWD)/results.xml
	rm $(PWD)/dump.vcd
endif