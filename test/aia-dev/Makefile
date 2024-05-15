# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

# Notifier Makefile

run =

# defaults
SIM ?= verilator
EXTRA_ARGS += --trace --trace-structs
TOPLEVEL_LANG ?= verilog

AXI_FOLDER = $(PWD)/../../vendor/
TEST_FOLDER = $(currdir) 
SRC_FOLDER = $(PWD)/../../rtl/
WRAPPER_SRC = $(TEST_FOLDER)./wrap.sv
APLIC_FOLDER = $(SRC_FOLDER)/aplic
APLIC_COMMON_FOLDER = $(APLIC_FOLDER)/common
APLIC_MINIMAL_FOLDER = $(APLIC_FOLDER)/minimal
APLIC_SCALABLE_FOLDER = $(APLIC_FOLDER)/scalable
IMSIC_FOLDER = $(SRC_FOLDER)/imsic

# AXI vendor files
VERILOG_SOURCES += $(AXI_FOLDER)reg_intf_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)ariane_axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)axi_lite_slave.sv

ifeq ($(clean),)
ifeq ($(APLIC),)
$(error You must define the APLIC type <MINIMAL, SCALABLE>. Stopping...)
endif

ifeq ($(APLIC),MINIMAL)
APLIC_SRC = $(APLIC_MINIMAL_FOLDER)
APLIC_REGMAP = aplic_regmap_32_2
IMSIC_SRC = $(IMSIC_FOLDER)
GENERATE_APLIC_TYPE = APLIC_MINIMAL 
endif

ifeq ($(IRQC), APLIC)
APLIC_TYPE = aplic_define_direct
GENERATE_IRQC_TYPE = IRQC_APLIC
endif

ifeq ($(IRQC), AIA)
APLIC_TYPE = aplic_define_msi
APLIC_REGMAP = aplic_regmap_32_0
GENERATE_IRQC_TYPE = IRQC_AIA
endif

ifeq ($(APLIC),SCALABLE)
APLIC_SRC = $(APLIC_SCALABLE_FOLDER)
APLIC_REGMAP = aplic_regmap
IMSIC_SRC = $(IMSIC_FOLDER)
GENERATE_APLIC_TYPE = APLIC_SCALABLE 
endif

ifeq ($(IRQC),)
$(error You must define the IRQC type <APLIC, AIA>. Stopping...)
endif
endif

# APLIC source files
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/$(APLIC_TYPE).svh
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/axi4_lite_write_master.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_regctl.sv
VERILOG_SOURCES += $(APLIC_SRC)/$(APLIC_REGMAP).sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_gateway.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_notifier.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_top.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_top.sv

# IMSIC source files
VERILOG_SOURCES += $(IMSIC_SRC)/island/imsic_regmap.sv
VERILOG_SOURCES += $(IMSIC_SRC)/island/imsic_top.sv

VERILOG_SOURCES += $(WRAPPER_SRC)

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = aia_wrapper

MODULE = aia_tb

ifeq ($(clean),)
ifneq ($(generate),)
generate:
	python3 generate_aia_define.py $(GENERATE_IRQC_TYPE) $(GENERATE_APLIC_TYPE)
else
include $(shell cocotb-config --makefiles)/Makefile.sim
endif
else
all:
	rm -rf $(PWD)/__pycache__
	rm -rf $(PWD)/sim_build
	rm $(PWD)/results.xml
	rm $(PWD)/dump.vcd

endif