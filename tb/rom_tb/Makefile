SIM?=verilator
TOPLEVEL_LANG?=verilog
WAVES?=0

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=rom_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=rom_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/rom.sv

EXTRA_ARGS += --trace --trace-structs
EXTRA_ARGS += -GADDR_WIDTH=3
EXTRA_ARGS += -GDATA_WIDTH=8

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

clean::
	rm -rf *.vcd