SIM?=verilator
TOPLEVEL_LANG?=verilog

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl

DUT=random_state_generator_tb_wrapper
TOPLEVEL=$(DUT)
MODULE=random_state_generator_tb

VERILOG_SOURCES+=$(DUT).sv
VERILOG_SOURCES+=$(SRC_DIR)/random_state_generator.sv

EXTRA_ARGS += --trace --trace-structs
EXTRA_ARGS += -GSTATE_0_MIN_VAL=100
EXTRA_ARGS += -GSTATE_0_MAX_VAL=150
EXTRA_ARGS += -GSTATE_1_MIN_VAL=30
EXTRA_ARGS += -GSTATE_1_MAX_VAL=180

GFLAGS=-S gtkwave.tcl

include $(shell cocotb-config --makefiles)/Makefile.sim

all:
	echo $(COMPILE_ARGS)
	gtkwave $(GFLAGS) *.vcd 2>/dev/null || $(GTKWAVE_OSX) $(GFLAGS) *.vcd 2>/dev/null

clean::
	rm -rf *.vcd