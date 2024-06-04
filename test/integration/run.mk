# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023-2024 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

# defaults
SIM ?= verilator
EXTRA_ARGS += --trace --trace-structs
TOPLEVEL_LANG ?= verilog

include aia_define.mk

include $(shell cocotb-config --makefiles)/Makefile.sim

AXI_FOLDER = $(PWD)/../../vendor
TEST_FOLDER = $(currdir) 
SRC_FOLDER = $(PWD)/../../rtl

IEAIA_FOLDER = $(SRC_FOLDER)/ieaia_dev

# AXI vendor files
VERILOG_SOURCES = $(AXI_FOLDER)/reg_intf_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)/axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)/ariane_axi_pkg.sv

# AIA packages
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/aia_define_$(AIA_TYPE).svh
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/aia_define_$(AIA_MODE).svh
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/aplic_domain_pkg.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/aia_pkg.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/imsic_pkg.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/imsic_protocol_pkg.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/package/aplic_pkg.sv

# IMSIC source files
ifeq ($(AIA_MODE), msi)
VERILOG_SOURCES += $(AXI_FOLDER)/axi_lite_slave.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/util/axi4_lite_write_master.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/imsic_regmap.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/imsic_top.sv
endif

# APLIC source files
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_domain_regctl.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_regmap.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_domain_gateway.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_domain_notifier.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_domain_top.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/util/synchronizer.sv
VERILOG_SOURCES += $(IEAIA_FOLDER)/aplic_top.sv

VERILOG_SOURCES += $(TEST_FOLDER)./ieaia_wrap.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = ieaia_wrapper

MODULE = aia_tb

runme: all