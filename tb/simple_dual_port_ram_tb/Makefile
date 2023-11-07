SIM?=verilator
TOPLEVEL_LANG?=verilog
WAVES?=0

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl
DUT=simple_dual_port_ram
TOPLEVEL=$(DUT)
MODULE=$(DUT)_tb

VERILOG_SOURCES+=$(SRC_DIR)/$(DUT).sv

DATA_WIDTH?=16
ADDR_WIDTH?=3
#INIT_FILE?=$(shell pwd)/rom_init.txt
EXTRA_ARGS += --trace --trace-structs

# COMPILE_ARGS+=-P$(TOPLEVEL).DATA_WIDTH=$(DATA_WIDTH)
# COMPILE_ARGS+=-P$(TOPLEVEL).ADDR_WIDTH=$(ADDR_WIDTH)
#COMPILE_ARGS+=-P$(TOPLEVEL).INIT_FILE=$(INIT_FILE)

ifeq ($(WAVES), 1)
	VERILOG_SOURCES+=iverilog_dump.v
	COMPILE_ARGS+=-s iverilog_dump
else
	GFLAGS=-S gtkwave.tcl
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	rm -rf *.vcd