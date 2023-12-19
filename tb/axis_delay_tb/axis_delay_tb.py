#!/usr/bin/python

import random
import queue

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


class Tb(object):
    def __init__(self, dut):
        self.dut = dut
        self.ref_queue = queue.Queue()
        self.errors = 1
        cocotb.start_soon(Clock(self.dut.clk, 10, units="ns").start())

    async def clk_tick(self):
        await RisingEdge(self.dut.clk)

    async def set_ready(self):
        while  True:
            for _ in range(random.randint(0, 10)):
                self.dut.m_axis_tready.value = 1
                await RisingEdge(self.dut.clk)

            for _ in range(random.randint(0, 5)):
                self.dut.m_axis_tready.value = 0
                await RisingEdge(self.dut.clk)

    async def run(self):
        self.dut.s_axis_tlast.value = 0

        while  True:
            for i in range(10):
                while  True:
                    if self.dut.s_axis_tready.value == 1:
                        break
                    else:
                        await RisingEdge(self.dut.clk)

                self.dut.s_axis_tdata.value = i
                self.ref_queue.put(i)
                cocotb.log.info(f'PUT: {i}')
                self.dut.s_axis_tstrb.value = random.randint(0, 0xff)
                self.dut.s_axis_tvalid.value = random.randint(0, 1)
                await RisingEdge(self.dut.clk)

            self.dut.s_axis_tdata.value = 9
            self.dut.s_axis_tlast.value = 1
            await RisingEdge(self.dut.clk)
            self.dut.s_axis_tvalid.value = 0
            self.dut.s_axis_tlast.value = 0
            await RisingEdge(self.dut.clk)

    async def check_data(self):
        self.errors = 0

        while  True:
            while  True:
                if self.dut.m_axis_tvalid.value == 1:
                    break
                else:
                    await RisingEdge(self.dut.clk)

            get_data = self.ref_queue.get()
            cocotb.log.info(f'GET: {get_data}')

            if self.dut.m_axis_tdata.value != get_data:
                self.errors += 1

            await RisingEdge(self.dut.clk)


@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)

    cocotb.start_soon(tb.set_ready())
    cocotb.start_soon(tb.run())
    cocotb.start_soon(tb.check_data())

    await Timer(1000, units='ns')

    if tb.errors != 0:
        cocotb.log.error(f'Failed with errors {tb.errors}')
    else:
        cocotb.log.info("Done succesfully")


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())