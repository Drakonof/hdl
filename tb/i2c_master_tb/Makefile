SIM?=verilator
TOPLEVEL_LANG?=verilog
WAVES?=0

COCOTB_HDL_TIMEUNIT=1ns
COCOTB_HDL_TIMEPRECISION=1ns

SRC_DIR=../../rtl
DUT=i2c_master
TOPLEVEL=$(DUT)
MODULE=$(DUT)_tb

VERILOG_SOURCES+=$(SRC_DIR)/$(DUT).sv 

# COMPILE_ARGS+=-P$(TOPLEVEL).PRESC_WIDTH=16
# COMPILE_ARGS+=-P$(TOPLEVEL).DATA_WIDTH=8
EXTRA_ARGS += --trace --trace-structs

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