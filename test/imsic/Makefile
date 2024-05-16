# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>
# Gateway Makefile

include $(shell cocotb-config --makefiles)/Makefile.sim

# defaults
SIM ?= verilator
EXTRA_ARGS += --trace --trace-structs
TOPLEVEL_LANG ?= verilog

AXI_FOLDER = $(PWD)/../../vendor/
TEST_FOLDER = $(currdir) 
SRC_FOLDER = $(PWD)/../../rtl/

VERILOG_SOURCES += $(AXI_FOLDER)axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)ariane_axi_pkg.sv
VERILOG_SOURCES += $(AXI_FOLDER)axi_lite_slave.sv

VERILOG_SOURCES += $(SRC_FOLDER)/imsic/island/imsic_top.sv
VERILOG_SOURCES += $(SRC_FOLDER)/imsic/island/imsic_regmap.sv
VERILOG_SOURCES += $(SRC_FOLDER)/aplic/common/axi4_lite_write_master.sv
VERILOG_SOURCES += $(TEST_FOLDER)./wrap.sv

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = imsic_top_wrapper

# MODULE is the basename of the Python test file
MODULE = imsic_top_tb

clean-all:
	rm -rf $(PWD)/__pycache__
	rm $(PWD)/results.xml