#!/usr/bin/python

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Random_state_generator_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def reset(self):
        self.dut.s_rst_n_i.value = 0
        await RisingEdge(self.dut.clk_i)
        self.dut.s_rst_n_i.value = 1

    async def start_gen(self, num):
        for addr in range(num):
            data = self.dut.state_o.value
            await RisingEdge(self.dut.clk_i)
            

@cocotb.test()
async def main(dut):
    num = 800

    cocotb.log.info("Start of simulation")

    tb = Random_state_generator_tb(dut)
    await tb.reset()
    await tb.start_gen(num)
    

    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())