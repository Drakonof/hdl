import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class Rom_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 10, units="ns").start())

    async def reading_whole_mem(self):
        for addr in range(8):
            await RisingEdge(self.dut.clk_i)
            self.dut.addr_i.value = addr
            ret_v = self.dut.data_o.value 

@cocotb.test()
async def reading_mem(dut):
    tb = Rom_tb(dut)
    await tb.reading_whole_mem()
        