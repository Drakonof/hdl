SIM?=verilator
TOPLEVEL_LANG?=verilog

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=bit_rate_meter_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=bit_rate_meter_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/bit_rate_meter.sv

EXTRA_ARGS += --trace --trace-structs
#EXTRA_ARGS += -G

GFLAGS=-S gtkwave.tcl

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

clean::
	rm -rf *.vcd