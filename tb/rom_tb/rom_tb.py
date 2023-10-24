#!/usr/bin/python

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Rom_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def clock_tick(self):
        await RisingEdge(self.dut.clk_i)

    def read_addr(self, addr):
        self.dut.addr_i.value = addr
        return self.dut.data_o.value

    #todo: compare with file content 
    async def reading_whole_mem(self):
        for addr in range(8):
            data = self.read_addr(addr)
            await RisingEdge(self.dut.clk_i)

@cocotb.test()
async def reading_mem(dut):
    tb = Rom_tb(dut)
    await tb.reading_whole_mem()
    await tb.reading_whole_mem()
        