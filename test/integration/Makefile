# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

# defaults
SIM ?= verilator
EXTRA_ARGS += --trace --trace-structs
TOPLEVEL_LANG ?= verilog

include $(shell cocotb-config --makefiles)/Makefile.sim

AXI_FOLDER = $(PWD)/../../vendor/
TEST_FOLDER = $(currdir) 
SRC_FOLDER = $(PWD)/../../rtl/
APLIC_FOLDER = $(SRC_FOLDER)/aplic
APLIC_COMMON_FOLDER = $(APLIC_FOLDER)/common
APLIC_MINIMAL_FOLDER = $(APLIC_FOLDER)/minimal
APLIC_SCALABLE_FOLDER = $(APLIC_FOLDER)/scalable
IMSIC_FOLDER = $(SRC_FOLDER)/imsic
IEAIA_FOLDER = $(SRC_FOLDER)/ieaia
WRAP_SRC := aia
NR_TARGET_SRC := 32

# AXI vendor files
VERILOG_SOURCES += $(AXI_FOLDER)reg_intf_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)ariane_axi_pkg.sv

ERROR_MSG = You must define the IRQC <APLIC, AIA, IEAIA> and APLIC <MINIMAL, SCALABLE>. Stopping...

ifeq ($(APLIC), minimal)
APLIC_SRC = $(APLIC_MINIMAL_FOLDER)
APLIC_REGMAP = aplic_$(APLIC)_regmap_$(NR_TARGET_SRC)_2
IMSIC_SRC = $(IMSIC_FOLDER)/island
GENERATE_APLIC_TYPE = APLIC_MINIMAL 
endif

ifeq ($(IRQC), aplic)
APLIC_TYPE = aplic_define_direct
GENERATE_IRQC_TYPE = IRQC_APLIC
endif

ifeq ($(IRQC), aia)
APLIC_TYPE = aplic_define_msi
APLIC_REGMAP = aplic_$(APLIC)_regmap_$(NR_TARGET_SRC)_0
GENERATE_IRQC_TYPE = IRQC_AIA
endif


ifeq ($(APLIC), scalable)
APLIC_SRC = $(APLIC_SCALABLE_FOLDER)
APLIC_REGMAP = aplic_$(APLIC)_regmap_$(NR_TARGET_SRC)_2
IMSIC_SRC = $(IMSIC_FOLDER)/island
GENERATE_APLIC_TYPE = APLIC_SCALABLE 
endif

ifeq ($(IRQC), ieaia)
WRAP_SRC := ieaia
APLIC_SRC = $(IEAIA_FOLDER)
IMSIC_SRC = $(IEAIA_FOLDER)
APLIC_TYPE = aplic_define_msi
APLIC_REGMAP = aplic_minimal_regmap_$(NR_TARGET_SRC)_0
GENERATE_APLIC_TYPE = APLIC_MINIMAL 
GENERATE_IRQC_TYPE = IRQC_AIA
endif

# APLIC source files
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/$(APLIC_TYPE).svh
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_regctl.sv
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/regmaps/$(APLIC_REGMAP).sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_gateway.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_notifier.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_domain_top.sv
VERILOG_SOURCES += $(APLIC_SRC)/aplic_top.sv

# IMSIC source files
ifneq ($(IRQC), aplic)
VERILOG_SOURCES += $(AXI_FOLDER)axi_lite_slave.sv
VERILOG_SOURCES += $(APLIC_COMMON_FOLDER)/axi4_lite_write_master.sv
VERILOG_SOURCES += $(IMSIC_SRC)/imsic_regmap.sv
VERILOG_SOURCES += $(IMSIC_SRC)/imsic_top.sv
endif

VERILOG_SOURCES += $(TEST_FOLDER)./$(WRAP_SRC)_wrap.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = $(WRAP_SRC)_wrapper

MODULE = aia_tb

generate:
	@if [ "$(IRQC)" = "" ] || ([ "$(IRQC)" != "ieaia" ] && [ "$(APLIC)" = "" ]); then echo "$(ERROR_MSG)"; \
	else python3 generate_aia_define.py $(GENERATE_IRQC_TYPE) $(GENERATE_APLIC_TYPE); fi

run: generate all 

help:
	@echo "Usage:"
	@echo "make <rule>"
	@echo "Available rules:"
	@echo "			clean-all - delete all simulation related files"
	@echo "			clean - delete simulation related files but keep cache info to speed up"
	@echo "			generate - to create the python file with AIA info"
	@echo "			all - run the simulation"
	@echo "			run - run the generate followed by all rule"
	@echo "Examples:"
	@echo "			1 - make run IRQC=ieaia -j$(nproc)"
	@echo "			2 - make run IRQC=aia APLIC=minimal -j$(nproc)"
	@echo "			3 - make run IRQC=aia APLIC=scalable -j$(nproc)"
	@echo "			4 - make run IRQC=aplic APLIC=minimal -j$(nproc)"
	@echo "			5 - make run IRQC=aplic APLIC=scalable -j$(nproc)"

clean-all: clean
	rm -rf $(PWD)/__pycache__
	rm $(PWD)/results.xml
	rm $(PWD)/aia_define.py