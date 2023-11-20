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

    async def reset(self):
        self.dut.s_rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.s_rst_n.value = 1

    async def start(self):
        ref_bit_rate = 0
        en_time = 0
        dis_time = 0

        en_time = random.randint(70, 120)
        dis_time = random.randint(0, 100)

        self.dut.data_valid.value = 1

        for i in range(en_time):
            ref_bit_rate = ref_bit_rate + 1
            await RisingEdge(self.dut.clk)

        self.dut.data_valid.value = 0

        for i in range(dis_time):
            await RisingEdge(self.dut.clk)

        print(f"Ref: {hex(ref_bit_rate)} bit_rate:{hex(self.dut.bit_rate.value)}")

            
@cocotb.test()
async def main(dut):
    cocotb.log.info("Start of simulation")

    tb = Tb(dut)
    await tb.reset()
    await tb.start()

    


    cocotb.log.info("End of simulation")
        
if __name__ == "__main__":
    sys.exit(main())