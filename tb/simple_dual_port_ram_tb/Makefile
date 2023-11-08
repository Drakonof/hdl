SIM?=verilator
TOPLEVEL_LANG?=verilog
WAVES?=0

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=simple_dual_port_ram_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=simple_dual_port_ram_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/simple_dual_port_ram.sv

EXTRA_ARGS += --trace --trace-structs
EXTRA_ARGS += -GADDR_WIDTH=3
EXTRA_ARGS += -GDATA_WIDTH=16


GFLAGS=-S gtkwave.tcl

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

clean::
	rm -rf *.vcd