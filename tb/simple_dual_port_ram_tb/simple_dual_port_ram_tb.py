#!/usr/bin/python

import random
#import threading

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Tb(object):
    def __init__(self, dut):
        self.highest_addr = 8
        self.max_rand_val = 7
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.wr_clk_i, 10, units="ns").start())
        cocotb.start_soon(Clock(self.dut.rd_clk_i, 10, units="ns").start())

    async def read(self, addr):
        self.dut.rd_addr_i.value = addr
        await RisingEdge(self.dut.rd_clk_i)
        await RisingEdge(self.dut.rd_clk_i)
        return self.dut.rd_data_o.value

    async def read_rand(self):
        self.dut.rd_en_i.value = 1
        await RisingEdge(self.dut.rd_clk_i)
        rand_addr = random.randint(0, self.max_rand_val)
        cocotb.log.info(f"Random address to read: {rand_addr}  Data: {await self.read(rand_addr)}")
        self.dut.rd_en_i.value = 0

    #todo: compare with file content 
    async def read_whole(self):
        self.dut.rd_en_i.value = 1
        await RisingEdge(self.dut.rd_clk_i)
        for addr in range(0, self.highest_addr):
            cocotb.log.info(f"Address to read: {addr}  Data: {await self.read(addr)}")
        self.dut.rd_en_i.value = 0

    async def write(self, addr, data):
        self.dut.wr_addr_i.value = addr
        self.dut.wr_data_i.value = data
        await RisingEdge(self.dut.wr_clk_i)

    async def write_rand(self, data, byte_valid):
        self.dut.wr_en_i.value = 1
        self.dut.wr_byte_valid_i.value = byte_valid
        rand_addr = random.randint(0, self.max_rand_val)
        cocotb.log.info(f"Random address to write: {rand_addr}  Data: {bin(data)}")
        await self.write(rand_addr, data)
        self.dut.wr_en_i.value = 0

    #todo: compare with file content 
    async def write_whole(self, data, byte_valid):
        self.dut.wr_byte_valid_i.value = byte_valid
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

    # cocotb.log.info(f"Starting threads...")

    # write_thread = threading.Thread(target=cocotb.scheduler.run, args=(tb.write_whole(5, 3),))
    # read_thread = threading.Thread(target=cocotb.scheduler.run, args=(tb.read_whole(),))

    # write_thread.start()
    # read_thread.start()

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())