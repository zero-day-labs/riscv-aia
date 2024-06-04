# SPDX-License-Identifier: Apache-2.0
# Copyright © 2023-2024 Francisco Marques & Zero-Day Labs, Lda. All rights reserved.
#
# Author: F.Marques <fmarques_00@protonmail.com>

include $(shell cocotb-config --makefiles)/Makefile.sim

generate:
	python3 generate_aia_define.py

run: generate
	$(MAKE) -f run.mk runme

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
	@echo "			1 - make generate"
	@echo "			2 - make run -j$(nproc)"
	@echo "Notes:"
	@echo "			Make sure you have configured the AIA as you intended in aia_pkg.sv before running any rule."
	@echo "			Generate rule will make use of aia_pkg.sv to determine the AIA test framework."

clean-all:
	$(MAKE) -f run.mk clean 
	rm -rf $(PWD)/__pycache__
	rm -rf $(PWD)/results.xml
	rm -rf $(PWD)/aia_define.py
	rm -rf $(PWD)/aia_define.mk