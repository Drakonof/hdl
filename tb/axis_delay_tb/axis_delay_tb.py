#!/usr/bin/python

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())

    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def set_ready(self):
        for _ in range(10):
            for _ in range(random.randint(0, 10)):
                self.dut.m_axis_tready.value = 1
                await RisingEdge(self.dut.clk)

            for _ in range(random.randint(0, 5)):
                self.dut.m_axis_tready.value = 0
                await RisingEdge(self.dut.clk)

    async def run(self):
        self.dut.s_axis_tlast.value = 0

        for _ in range(5):
            for i in range(10):
                while  True:
                    if self.dut.s_axis_tready.value == 1:
                        break
                    else:
                        await RisingEdge(self.dut.clk)
                self.dut.s_axis_tdata.value = i
                self.dut.s_axis_tstrb.value = random.randint(0, 0xff)
                self.dut.s_axis_tvalid.value = random.randint(0, 1)
                await RisingEdge(self.dut.clk)

        self.dut.s_axis_tdata.value = 9
        self.dut.s_axis_tlast.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.s_axis_tvalid.value = 0
        self.dut.s_axis_tlast.value = 0
        await RisingEdge(self.dut.clk)


@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)

    ready_thread = cocotb.fork(tb.set_ready())
    run_thread = cocotb.fork(tb.run())

    # Wait for the test to complete
    await cocotb.triggers.Combine(run_thread, ready_thread)

    await Timer(1000, units='ns')

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())