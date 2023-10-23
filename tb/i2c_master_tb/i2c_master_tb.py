import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


class I2c_master_tb(object):
    def __init__(self, dut):
        self.dut = dut
        cocotb.start_soon(Clock(self.dut.clk_i, 100, units="ns").start())

    async def clock_tick(self):
        await RisingEdge(self.dut.clk_i)
        
    async def reset(self):
        self.dut.s_rst_n_i = 0
        await RisingEdge(self.dut.clk_i)
        self.dut.s_rst_n_i = 1

    async def start(self):
        self.dut.en_i = 1
        self.dut.prescale_i = 8

    async def send_addr(self, addr):
        self.dut.slave_addr_i = addr
        self.dut.dir_i = 1

    async def send_data(self, data):
        self.dut.data_i = data

    async def check_start(self, rnge):
        for addr in range(rnge):
            await RisingEdge(self.dut.clk_i)


@cocotb.test()
async def main(dut):
    tb = I2c_master_tb(dut)

    await tb.reset()
    await tb.start()
    await tb.send_addr(0x58)
    await tb.send_data(0x64)
    await tb.clock_tick()
    await tb.check_start(300)


if __name__ == "__main__":
    sys.exit(main())