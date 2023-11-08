#!/usr/bin/python

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.runner import get_runner
import os


class Rom_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def read_addr(self, addr):
        self.dut.addr_i.value = addr
        await RisingEdge(self.dut.clk_i)
        await RisingEdge(self.dut.clk_i)
        return self.dut.data_o.value

    async def read_rand_addr(self, max_range):
        rand_addr = random.randint(0, max_range)
        cocotb.log.info(f"Random address: {rand_addr}  Data: {await self.read_addr(rand_addr)}")

    #todo: compare with file content 
    async def reading_whole_mem(self, max_range):
        for addr in range(0, max_range):
            cocotb.log.info(f"Address: {addr}  Data: {await self.read_addr(addr)}")
            

@cocotb.test()
async def main(dut):
    highest_addr = 8
    max_rand_val = 7

    cocotb.log.info("Start of simulation")

    tb = Rom_tb(dut)
    await tb.reading_whole_mem(highest_addr)
    await tb.read_rand_addr(max_rand_val)
    await tb.read_rand_addr(max_rand_val)

    cocotb.log.info("End of simulation")

        
if __name__ == "__main__":
    sys.exit(main())