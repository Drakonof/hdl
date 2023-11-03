#!/usr/bin/python

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Tb(object):
    def __init__(self, dut):
        self.highest_addr = 8
        self.max_rand_val = 7
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def read(self, addr):
        self.dut.addr_i.value = addr
        await RisingEdge(self.dut.clk_i)
        await RisingEdge(self.dut.clk_i)
        return self.dut.data_o.value

    async def read_rand(self):
        self.dut.wr_en_i.value = 0
        rand_addr = random.randint(0, self.max_rand_val)
        cocotb.log.info(f"Random address to read: {rand_addr}  Data: {await self.read(rand_addr)}")

    #todo: compare with file content 
    async def read_whole(self):
        self.dut.wr_en_i.value = 0
        for addr in range(0, self.highest_addr):
            cocotb.log.info(f"Address to read: {addr}  Data: {await self.read(addr)}")

    async def write(self, addr, data):
        self.dut.addr_i.value = addr
        self.dut.data_i.value = data
        await RisingEdge(self.dut.clk_i)

    async def write_rand(self, data, byte_valid):
        self.dut.wr_en_i.value = 1
        self.dut.byte_valid_i.value = byte_valid
        rand_addr = random.randint(0, self.max_rand_val)
        cocotb.log.info(f"Random address to write: {rand_addr}  Data: {data}")
        await self.write(rand_addr, data)

    #todo: compare with file content 
    async def write_whole(self, data, byte_valid):
        self.dut.byte_valid_i.value = byte_valid
        self.dut.wr_en_i.value = 1
        for addr in range(0, self.highest_addr):
            await self.write(addr, addr + data)
        self.dut.wr_en_i.value = 0
            

@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.read_whole()
    await tb.read_rand()
    await tb.read_rand()

    await tb.write_whole(5, 3)
    await tb.read_whole()
    await tb.write_rand(0xABCD, 1)
    await tb.read_whole()

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())